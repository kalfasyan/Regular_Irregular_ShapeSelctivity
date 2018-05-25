clear;
% ---------------------------------------------------------------------------------
% Source for MDS dimension selection: http://www.analytictech.com/networks/mds.htm
% The degree of correspondence between the distances among points implied by MDS map 
% and the matrix input by the user is measured (inversely) by a stress function.
% ---------------------------------------------------------------------------------
% Can't use pinksearch stimuli since sometimes the pinknoise background is the
% same, so there is high pixel similarity

% addpath /data/local/software/Body_Patches/foos
addpath ./myFunctions/

distType = 'euclidean';

% Setting the layer names for alexnet
layer = {'conv1','relu1','norm1','pool1','conv2','relu2','norm2','pool2','conv3','relu3', ...
            'conv4','relu4','conv5','relu4','pool5','fc6','relu6','fc7','relu7','fc8'};
    
% Chooseing the images to use
stimchoice = 'regularIrregular';

% Creating a list of names for the images
stimList = natsort(getAllFiles(['./' stimchoice '/']));
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
pixeldissimilarity = squareform(pdist(stimuli_in1D,distType));
pixels = getUpperDiagElements(pixeldissimilarity);
 
Dreg_no0 = pixeldissimilarity(:); Dreg_no0(Dreg_no0==0) = [];
figure; imagesc(pixeldissimilarity);
caxis([min(Dreg_no0) max(Dreg_no0)]);
set(gca,'XTick',[]);
set(gca,'XTickLabel',[]);
set(gca,'YTick',[]);
set(gca,'YTickLabel',[])
color = get(gcf,'Color');
set(gca,'XColor',color,'YColor',color,'TickDir','out');
set(gca,'Visible','off');
export_fig(['/media/yannis/HGST_4TB/Ubudirs/Figures_Regireg/pixels_DisMat.eps'])

% title('Pixel dissimilarity Matrix');
% set(gca,'XTick',linspace(1,length(stimList),length(stimList)),'XTickLabel', stimNames,'XTickLabelRotation',90);
% set(gca,'YTick',linspace(1,length(stimList),length(stimList)),'YTickLabel', stimNames);

% ------------------------------------------
% dissimilarity matrix of deepnet layers
% Choosing the network to use
network = 'untrained';
load([network '_D_' stimchoice '_' distType '.mat'])
% figure;
for i=1:numel(D)
    DEEPuptr1(i,:) = getUpperDiagElements(D{i});
    z1{i} = corr(pixels',DEEPuptr1(i,:)','Type','Spearman');
%     subplot(5,5,i); imagesc(D{i}); colorbar; title(layer{i});
end

% % dissimilarity matrix of last deepnet layer FC8
figure;
for i=1:numel(layer)
    subplot(5,5,i);
    imagesc(D{i});
    title([layer{i} '-' network]);
end
set(gca,'XTick',linspace(1,length(stimList),length(stimList)),'XTickLabel', stimNames,'XTickLabelRotation',90);
set(gca,'YTick',linspace(1,length(stimList),length(stimList)),'YTickLabel', stimNames);
% ------------------------------------------
clear D
% dissimilarity matrix of deepnet layers
% Choosing the network to use
network = 'alexnet';
load([network '_D_' stimchoice '_' distType '.mat'])
% figure;
for i=1:numel(D)
    DEEPuptr2(i,:) = getUpperDiagElements(D{i});
    z2{i} = corr(pixels',DEEPuptr2(i,:)','Type','Spearman');
%     subplot(5,5,i); imagesc(D{i}); colorbar; title(layer{i});
end
% 
% % dissimilarity matrix of last deepnet layer FC8
figure;
for i=1:numel(layer)
    subplot(5,5,i);
    imagesc(D{i});
    title([layer{i} '-' network]);
end
set(gca,'XTick',linspace(1,length(stimList),length(stimList)),'XTickLabel', stimNames,'XTickLabelRotation',90);
set(gca,'YTick',linspace(1,length(stimList),length(stimList)),'YTickLabel', stimNames);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Figure -> correlation of pixel dissimilarity with each layer of the deepnet
figure; 
plot(cell2mat(z1));
hold on
plot(cell2mat(z2));
set(gca,'XTick',linspace(1,length(D),length(D)),'XTickLabel', layer,'XTickLabelRotation',90);
grid on
title([network '-' stimchoice])
legend('Untrained','Trained')
axis([0,length(D)+1,0,1])
