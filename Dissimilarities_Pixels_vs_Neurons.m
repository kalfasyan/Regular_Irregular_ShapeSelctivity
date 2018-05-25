clear;
% ---------------------------------------------------------------------------------
% Source for MDS dimension selection: http://www.analytictech.com/networks/mds.htm
% The degree of correspondence between the distances among points implied by MDS map 
% and the matrix input by the user is measured (inversely) by a stress function.
% ---------------------------------------------------------------------------------
% Can't use pinksearch stimuli since sometimes the pinknoise background is the
% same, so there is high pixel similarity
% 
% addpath /data/local/software/Body_Patches/foos
addpath /media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/myFunctions/
addpath /media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/myFunctions/export_fig


% Choosing the images to use
stimchoice = 'regularIrregular';

% Creating a list of names for the images
stimList = natsort(getAllFiles(['./' stimchoice '/']));
% Ordering in the same way as the paper
stimList = vertcat(stimList(49:end), stimList(1:48));
for i=1:numel(stimList)
    stimNames{i} = stimList{i}(20:end-4);
end

% Some preprocessing/resizing of the images
for i=1:numel(stimList)
    tmp = imread(stimList{i});
%     tmp = imresize(tmp,[245 245]);
    stimuli_in1D(i,:) = single(tmp(:));
end

% Pixel dissimilarity matrix of stimuli_in1D
pixeldissimilarity = squareform(pdist(stimuli_in1D,'Euclidean'));
pixels = getUpperDiagElements(pixeldissimilarity)';

[~, vv] = sort(pixeldissimilarity(:));
[~, vv] = sort(vv);
[~, jj, kk] = unique(pixeldissimilarity(:), 'first');
pixeldissimilarity = reshape(vv(jj(kk)), size(pixeldissimilarity));

imagesc(pixeldissimilarity);
M_no0 = pixeldissimilarity(:); M_no0(M_no0==1) = [];
caxis([min(M_no0) max(M_no0)]);

%title('Pixel dissimilarity Matrix');
% set(gca,'XTick',linspace(1,length(stimList),length(stimList)),'XTickLabel', stimNames,'XTickLabelRotation',90);
% set(gca,'YTick',linspace(1,length(stimList),length(stimList)),'YTickLabel', stimNames);
set(gca,'XTick',[])
set(gca,'XTickLabel',[])
set(gca,'YTick',[])
set(gca,'YTickLabel',[])
color = get(gcf,'Color');
set(gca,'XColor',color,'YColor',color,'TickDir','out')
set(gca,'Visible','off')
export_fig(['/media/yannis/HGST_4TB/Ubudirs/Figures_Regireg/' 'pixels.eps'])


%%
load('regular_irregular_SPIKES_yannis.mat');
shapenames = regular_irregular_SPIKES_yannis.Properties.VariableNames;
shapenames = shapenames(3:end);

REGIRREG = table2array(regular_irregular_SPIKES_yannis);
REGIRREG = REGIRREG(:,3:end);

% Standarization / Normalization / zscore
% for i=1:size(REGIRREG,1)
%     tmp = zscore(REGIRREG(i,:));
%     %tmp = (tmp-mean(tmp))/std(tmp);
%     REGIRREGspikes(i,:) = tmp;
% end

Dreg = squareform(pdist(REGIRREG','euclidean'));
spikes = getUpperDiagElements(Dreg)';

[~, vv] = sort(Dreg(:));
[~, vv] = sort(vv);
[~, jj, kk] = unique(Dreg(:), 'first');
Dreg = reshape(vv(jj(kk)), size(Dreg));

imagesc(Dreg);
M_no0 = Dreg(:); M_no0(M_no0==1) = [];
caxis([min(M_no0) max(M_no0)]);

% Dreg = squareform(pdist(REGIRREGspikes','euclidean'));
%title('Spikes dissimilarity Matrix');
% set(gca,'XTick',linspace(1,length(shapenames),length(shapenames)),'XTickLabel', shapenames,'XTickLabelRotation',90);
% set(gca,'YTick',linspace(1,length(shapenames),length(shapenames)),'YTickLabel', shapenames);
set(gca,'XTick',[])
set(gca,'XTickLabel',[])
set(gca,'YTick',[])
set(gca,'YTickLabel',[])
color = get(gcf,'Color');
set(gca,'XColor',color,'YColor',color,'TickDir','out')
set(gca,'Visible','off')
export_fig(['/media/yannis/HGST_4TB/Ubudirs/Figures_Regireg/' 'IT_neurons.eps'])


disp(['PEARSON CORRELATION OF UPPER DIAGONALS: ', num2str(corr(pixels,spikes,'Type','Spearman'))])