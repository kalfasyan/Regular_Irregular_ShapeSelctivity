clear; 
addpath ./myFunctions/
addpath ./myFunctions/export_fig/

% Regular-Irregular spike matrix and the Distances
load('regular_irregular_SPIKES_yannis.mat');
shapenames = regular_irregular_SPIKES_yannis.Properties.VariableNames;
shapenames = shapenames(3:end);

REGIRREG = table2array(regular_irregular_SPIKES_yannis);
N = REGIRREG(:,3:end);
N = N';

%%
stimchoice = 'regularIrregular';%'regularIrregularSmall2x';
distType = 'euclidean'; % for neurons
networks = {'alexnet','vgg16','vgg19'};
corType = 'Spearman'; % correlation between Neural distance matrix and CNN's
iterations = 1000; % bootstrap iterations

for network = networks
    network = network{1};
    [layer, layersizes] = getLayersFromNetwork(network);

    switch network
        case 'alexnet'
            layersize = layersizes(find(strcmp(layer,'relu6')>0)); layersize = layersize{1};
            layer = layer{find(strcmp(layer,'relu6')>0)};
        case 'vgg16'
            layersize = layersizes(find(strcmp(layer,'relu5_2')>0)); layersize = layersize{1};
            layer = layer{find(strcmp(layer,'relu5_2')>0)};
        case 'vgg19'
            layersize = layersizes(find(strcmp(layer,'conv5_4')>0)); layersize = layersize{1};
            layer = layer{find(strcmp(layer,'conv5_4')>0)};
        otherwise
            error('wrong network given!');
    end

    
    fprintf('Network: %s Layer: %s\n', network,layer);
    tic;
    % removing units with std=0
    X = regireg_getDeepX(network,layer,stimchoice);
    thelist = [];
    for col = 1:size(X,2)
        if numel(unique(X(:,col))) == 1
            thelist(end+1) = col;
        end
    end
    X(:,thelist) = [];
%     disp(num2str(size(X)))
    fprintf('Gathered features in %.2f seconds. Now running bootstrap.\n',toc);

    D_ALL_square = squareform(pdist(X,distType));
    D_ALL = getUpperDiagElements(D_ALL_square);

    D_N_square = squareform(pdist(N,distType));
    D_N = getUpperDiagElements(D_N_square);

    corr_N_ALL = corr(D_N', D_ALL','Type',corType);

    %% Bootstrapping the number of neurons (i.e. the biological neurons)
    
    sampl_percentages = [20/100, 10/100, 1/100, 0.1/100];
    sampl_labels = {'20%','10%','1%','0.1%'};
    bootstrappedFEWER = zeros(iterations, length(sampl_percentages));

    for smpl = 1:numel(sampl_percentages)
        fprintf('Bootstrap for %.4f sample\t', sampl_percentages(smpl));
        tic;
        parfor iter=1:iterations

            units_sampled = round(size(X,2) * sampl_percentages(smpl));
            if units_sampled < 1 units_sampled = 1; end

            sample_fewer = datasample(1:size(X,2), units_sampled ,'Replace',false );
            X_fewer_smpld = X(:,sample_fewer);

            D_fewer_square = squareform(pdist(X_fewer_smpld,distType));
            D_fewer = getUpperDiagElements(D_fewer_square); 

            bootstrappedFEWER(iter, smpl) = corr(D_N',D_fewer','Type',corType);
            if isnan(bootstrappedFEWER(iter, smpl))
                bootstrappedFEWER(iter, smpl) = 0;
            end
            
        end
        fprintf('Time: %.2f seconds\n', toc);
    end
    fprintf('total units: %.f \n', size(X,2))

    if sum(sum(isnan(bootstrappedFEWER))) > 0
        warning('There are NaN correlations!')
    end 
    %% Plotting

%     figure;
    q1 = prctile(bootstrappedFEWER,2.5); 
    q2 = prctile(bootstrappedFEWER,97.5);
    y = median(bootstrappedFEWER);
    x = linspace(0.5,length(sampl_percentages)-0.5,length(sampl_percentages));
    plot(x,y)
    hh = errorbar(x,y, q1-y,q2-y, '.');
    set(gca,'XTick',linspace(0.5,length(sampl_percentages)-0.5, ...
        length(sampl_percentages)),'XTickLabel', ...
        sampl_labels,'XTickLabelRotation',90);
    axis([-0.5,length(sampl_percentages)+0.5,-0.2,1])
    hold on
    plot(0,corr_N_ALL,'*')
    text(-0.2,corr_N_ALL+0.1,network)
    title([num2str(4096) ' ' num2str(100352)])
    ylabel('Spearman Rho')
    hold on
%     clear bootstrappedFEWER x y hh q1 q2 X corr_N_ALL D_ALL_square D_N_square
end
