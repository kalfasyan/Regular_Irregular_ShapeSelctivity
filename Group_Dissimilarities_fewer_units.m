clear;
addpath ./myFunctions/

% SETTINGS
cortype    = 'Pearson'; % to correlate means of barplots for each layer with mean of neural/human data
networks = {'vgg16'};%{'alexnet'};%,'vgg16','vgg19'};
stimchoice = 'regularIrregular';
iterations = 10000;
sampl_percentages = [20/100, 10/100, 1/100, 0.1/100];
sampl_labels = {'20%','10%','1%','0.1%'};

qq = 1;
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

    tic;
    fprintf('Layer: %s\t',layer);

    % get layer features into a (DeepUnits x Stimuli) matrix
    [X, featList] = regireg_getDeepX(network, layer, stimchoice);
    
    % removing units with std=0
    X = regireg_getDeepX(network,layer,stimchoice);
    thelist = [];
    for col = 1:size(X,2)
        if numel(unique(X(:,col))) == 1
            thelist(end+1) = col;
        end
    end
    X(:,thelist) = [];    
    disp(num2str(size(X,2)));
    % transposing X
    X = X';
    if size(X,1) < size(X,2)
        error('Transpose matrix X!');
    end

    [hh, nn] = deal(zeros(iterations, length(sampl_percentages)));
    humanH  = [10.6;      1.4;       2.05;      3.95;      21.7];
    neuralN = [7.4958;    5.0244;    5.3185;    5.5513;    6.6415;   6.6724]; 
    
    [DistsR, DistsIC, DistsISC, DistsISS, DistsISCa_ISSa, DistsISCb_ISSb] = get_GroupDists(X);
    groupnames = {'R','IC','ISC','ISS','ISCa\_ISSa','ISCb\_ISSb'};
    [ALL_N, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb);
    corr_ALL_N = corr(mean(ALL_N)', neuralN,'Type',cortype);
    
    groupnames = {'R','IC','ISC','ISS','ISC_ISS'};
    [ALL_H, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb);
    corr_ALL_H = corr(mean(ALL_H)', humanH,'Type',cortype);

    for smpl = 1:numel(sampl_percentages)

        parfor iter=1:iterations

            units_sampled = round(size(X,1) * sampl_percentages(smpl));
            if units_sampled < 1 units_sampled = 1; end

            sample_fewer = datasample(1:size(X,1), units_sampled ,'Replace',false );
            X_fewer_smpld = X(sample_fewer,:);

            [DistsR, DistsIC, DistsISC, DistsISS, DistsISCa_ISSa, DistsISCb_ISSb] = get_GroupDists(X_fewer_smpld);

            groupnames = {'R','IC','ISC','ISS','ISC_ISS'};
            [H, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb);
            hh(iter, smpl) = corr(mean(H)', humanH,'Type',cortype);     

            groupnames = {'R','IC','ISC','ISS','ISCa\_ISSa','ISCb\_ISSb'};
            [N, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb);   
            nn(iter, smpl) = corr(mean(N)', neuralN,'Type',cortype);

        end

    end
    fprintf('Time: %.2f seconds\n',toc);
    
%     figure;
    colors = {'g','r','k'};
    q1 = prctile(nn,2.5); 
    q2 = prctile(nn,97.5);
    y = median(nn);
    x = linspace(0.5,length(sampl_percentages)-0.5,length(sampl_percentages));
    plot(x,y)
    hh = errorbar(x,y, q1-y,q2-y, [colors{qq} '.']);
    set(gca,'XTick',linspace(0.5,length(sampl_percentages)-0.5, ...
        length(sampl_percentages)),'XTickLabel', ...
        sampl_labels,'XTickLabelRotation',90);
    axis([-0.5,length(sampl_percentages)+0.5,-0.9,1])
    hold on
    plot(0,corr_ALL_N,'*')
    text(-0.2,corr_ALL_N-0.1,network)
    title([num2str(size(X,1))])
    ylabel('Spearman Rho')
    hold on
    
    qq = qq+1;
end

%%
