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
iterations = 10000; % bootstrap iterations

groupnames = {'R','IC','ISC','ISS','ISCa\_ISSa','ISCb\_ISSb'};
tic
D_N_boot = nan(iterations, 64.^2 / 2 - 32 );
neuralN_boot = nan(iterations, 6 );
%bootstrap number of neurons
for iter=1:iterations
    sample_N = datasample(1:size(N,2), size(N,2) ,'Replace',true );
    D_N_square = squareform(pdist( N(:,sample_N) ,distType));
    D_N_boot(iter,:) = getUpperDiagElements(D_N_square);
    
    [DistsR, DistsIC, DistsISC, DistsISS, DistsISCa_ISSa, DistsISCb_ISSb] = ...
        get_GroupDists( N(:,sample_N)' );
    [ALL_N, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb);
    neuralN_boot(iter,:) = mean(ALL_N);
end
toc

%%

for i = 1:numel(networks)
    network = networks{i};

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
    
    Xlist{i} = X;
end

%%
lcols = {[219, 218, 218]/255,...
    [148, 143, 143]/255,...
    [0, 0, 0]/255,...
    };
lcols = mat2cell(lines(3),[1,1,1],3);

for i = 1:numel(networks)
    network = networks{i};
    
    X = Xlist{i};
    
    [coeff,score,latent,tsquared,explained] = pca(X);
    cumexplained = cumsum(explained);

    D_ALL = pdist(X,distType);

    D_N = pdist(N,distType);

    corr_N_ALL = corr(D_N', D_ALL','Type',corType);

    sampl_npc = 1:63;% npc's
    sampl_percentages = cumexplained(sampl_npc); % pc explained variance
    sampl_labels = cellfun( @(x)sprintf('%0.f%%',x), num2cell(sampl_percentages),'uniformoutput',false)';

    bootstrappedFEWER = zeros(iterations, length(sampl_percentages));
    bootstrappedFEWER_group = zeros(iterations, length(sampl_percentages));

    for smpl = 1:numel(sampl_percentages)
        fprintf('Percentage', sampl_percentages(smpl));

        X_fewer_smpld = score(:,1:sampl_npc(smpl));
        D_fewer_square = squareform(pdist( X_fewer_smpld ,distType));
        D_fewer = getUpperDiagElements(D_fewer_square);

        tic;
        bootstrappedFEWER(:, smpl) = corr(D_N_boot',D_fewer','Type',corType);
        fprintf('Time: %.2f seconds\n', toc);
        
        [DistsR, DistsIC, DistsISC, DistsISS, DistsISCa_ISSa, DistsISCb_ISSb] = ...
            get_GroupDists( score(:,1:sampl_npc(smpl))' );
        groupnames = {'R','IC','ISC','ISS','ISCa\_ISSa','ISCb\_ISSb'};
        [ALL_N, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb);
        bootstrappedFEWER_group(:,smpl) = corr( neuralN_boot', mean(ALL_N)','Type','Pearson');
    end
    fprintf('total units: %.f \n', size(X,2))

    if sum(sum(isnan(bootstrappedFEWER))) > 0
        warning('There are NaN correlations!')
    end
    
    CI{i} = prctile(bootstrappedFEWER,[2.5 97.5]);
    Y{i} = median(bootstrappedFEWER);
    CI2{i} = prctile(bootstrappedFEWER_group,[2.5 97.5]);
    Y2{i} = median(bootstrappedFEWER_group);
    EXP{i} = cumexplained;
    
end

%%
figure('color','w','units','centimeter','position',[15 10 18 12]);

tmp = repmat({''},63,1);
tmp([1 5:5:60 63]) = cellfun(@(x)num2str(x), num2cell([1 5:5:60 63]),'uniformoutput',false);
xticklab = tmp;

tmp = repmat({''},63,1);
tmp([1 10:10:60 63]) = cellfun(@(x)num2str(x), num2cell([1 10:10:60 63]),'uniformoutput',false);
xticklab = {xticklab,tmp};

mark = {'x','.'};
marksize = [5,11];
xlabs = {'Spearman rho','Pearson r'};

networks = {'Alexnet - relu6','VGG16 - relu5.2','VGG19 - conv5.4'};

for i = 1:numel(networks)
    for j = 1:2
        switch j
            case 1
                CItmp = CI;
                Ytmp = Y;
                pre = 1:10;
                post = [62,63];
                
                xticklab = [1 5:5:pre(end) post(end)];
                
                %subplot(2,4,1+i); hold off;
                xoff = (i-1)*.2;
                axes('position',[.07+xoff,.63,.18,.3]);
                gap = 1;
            case 2
                CItmp = CI2;
                Ytmp = Y2;
                pre = 1:40;
                post = [62,63];
                
                xticklab = [1 10:10:pre(end) post(end)];
                
                %subplot(2,3,3+i); hold off;
                xoff = (i-1)*.31;
                axes('position',[.07+xoff,.1,.29,.3]);
                gap = 2.25;
        end
        hold off;
        x = linspace(0.5,length(pre)-0.5,length(pre));
        xend = x(end)+[0,1]+gap;
        xtickloc = [x(xticklab(1:end-1)) xend(end)];

        q1 = CItmp{i}(1,pre);
        q2 = CItmp{i}(2,pre);
        y = Ytmp{i}(pre);

        q1end = CItmp{i}(1,post);
        q2end = CItmp{i}(2,post);
        yend = Ytmp{i}(post);

        fill( [x,fliplr(x)], [q1,fliplr(q2)], [1,1,1]*.9, 'edgecolor','none'); hold on;
        fill( [xend,fliplr(xend)], [q1end,fliplr(q2end)], [1,1,1]*.9, 'edgecolor','none');
        for k = 1:numel(networks)
            plot(x,Ytmp{k}(pre),'color', [1,1,1]*.7);
            plot(xend,Ytmp{k}(post),'color', [1,1,1]*.7);
        end
        plot(x, y,'linewidth',1,'color',lcols{i});
        plot(x(end), y(end),mark{j},'markersize',marksize(j),'color',lcols{i},'linewidth',1.5);
        plot(xend, yend,'linewidth',1,'color',lcols{i});
        hold off; box off;

        title(networks{i})

        set(gca,...
            'xlim',[0,xend(end)+.5],...
            'ylim',[0,1],...
            'xtick',xtickloc,...[x,xend(end)],...
            'xticklabel',xticklab);%xticklab{j}([pre,post(end)]))
        
        if i==1
            ylabel(xlabs{j})
            xlabel('Principal components')
        else
            set(gca,'yticklabel',[])
        end   

    end
        
end

axh = axes('position',[.77,.63,.22,.3]);
hold on;
for i = 1:numel(networks)
    
    cumexplained = EXP{i};

    plot( cumexplained,'linewidth',1,'color',lcols{i});
    
    for j = 1:2
        switch j
            case 1
                pre = 1:10;
            case 2
                pre = 1:40;
        end
        plot( sampl_npc(pre(end)) ,cumexplained(sampl_npc(pre(end))),...
            mark{j},'markersize',marksize(j),'color',lcols{i},'linewidth',1.5);
    end
end
    
set( axh, 'xlim',[.5 63.5])
xlabel('Principal components')
ylabel({'% explained explained'})

