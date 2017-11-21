clear;
% ---------------------------------------------------------------------------------
% Source for MDS dimension selection: http://www.analytictech.com/networks/mds.htm
% The degree of correspondence between the distances among points implied by MDS map 
% and the matrix input by the user is measured (inversely) by a stress function.
% ---------------------------------------------------------------------------------
% Can't use pinksearch stimuli since sometimes the pinknoise background is the
% same, so there is high pixel similarity

addpath /data/local/software/Body_Patches/foos
addpath /data/local/myFunctions/

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

figure; imagesc(pixeldissimilarity); title('Pixel dissimilarity Matrix');
set(gca,'XTick',linspace(1,length(stimList),length(stimList)),'XTickLabel', stimNames,'XTickLabelRotation',90);
set(gca,'YTick',linspace(1,length(stimList),length(stimList)),'YTickLabel', stimNames);


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

% Dreg = squareform(pdist(REGIRREGspikes','euclidean'));
figure; imagesc(Dreg); title('Spikes dissimilarity Matrix');
set(gca,'XTick',linspace(1,length(shapenames),length(shapenames)),'XTickLabel', shapenames,'XTickLabelRotation',90);
set(gca,'YTick',linspace(1,length(shapenames),length(shapenames)),'YTickLabel', shapenames);

disp(['PEARSON CORRELATION OF UPPER DIAGONALS: ', num2str(corr(pixels,spikes,'Type','Spearman'))])