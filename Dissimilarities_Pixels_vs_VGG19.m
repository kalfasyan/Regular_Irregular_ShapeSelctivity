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

% Setting the layer names for vgg19
layer = {'conv1_1','relu1_1','conv1_2','relu1_2','pool1','conv2_1','relu2_1','conv2_2','relu2_2','pool2', ...
        'conv3_1','relu3_1','conv3_2','relu3_2','conv3_3','relu3_3','conv3_4','relu3_4','pool3','conv4_1', ...
        'relu4_1','conv4_2','relu4_2','conv4_3','relu4_3','conv4_4','relu4_4','pool4','conv5_1','relu5_1', ...
        'conv5_2','relu5_2','conv5_3','relu5_3','conv5_4','relu5_4','pool5','fc6','relu6','fc7','relu7','fc8'};
    
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
pixeldissimilarity = squareform(pdist(stimuli_in1D,'Euclidean'));
pixels = getUpperDiagElements(pixeldissimilarity);
figure; imagesc(pixeldissimilarity); title('Pixel dissimilarity Matrix');
set(gca,'XTick',linspace(1,length(stimList),length(stimList)),'XTickLabel', stimNames,'XTickLabelRotation',90);
set(gca,'YTick',linspace(1,length(stimList),length(stimList)),'YTickLabel', stimNames);

% ------------------------------------------
% dissimilarity matrix of deepnet layers
% Choosing the network to use
network = 'untrainedVGG';
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
    subplot(6,7,i);
    imagesc(D{i});
    title([layer{i} '-' network]);
end
set(gca,'XTick',linspace(1,length(stimList),length(stimList)),'XTickLabel', stimNames,'XTickLabelRotation',90);
set(gca,'YTick',linspace(1,length(stimList),length(stimList)),'YTickLabel', stimNames);
% ------------------------------------------
clear D
% dissimilarity matrix of deepnet layers
% Choosing the network to use
network = 'vgg19';
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
    subplot(6,7,i);
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
% saveas(gcf,['./figures/NEW' network '_' stimchoice '_corrs.bmp'])
















% %% mds
% choice = 'fc8';
% IndexC = strcmp(layer, choice);
% Index = find(IndexC>0);
% Ds = D{Index};
% [y,stress] = mdscale(Ds,2,'Criterion','stress','Start','random','Replicates',500);
% 
% % Figure MDS on selected (Ds) Deepnet layer
% figure;
% title(choice);
% scatter(y(:,1),y(:,2));
% for i=1:length(stimuli_in1D)
%     text(y(i,1),y(i,2),stimList{i}(8:end-4));
% end
% title(choice)
% saveas(gcf,['./figures/' network '_' stimchoice '_mds_' choice '.bmp'])
% 
% %% Figure MDS on Pixel dissimilarity
% y= mdscale(pixeldissimilarity,2,'Criterion','stress','Start','random','Replicates',500);
% figure;
% scatter(y(:,1),y(:,2));
% for i=1:length(stimuli_in1D)
%     text(y(i,1),y(i,2),stimList{i}(8:end-4));
% end
% title('PIXELS');
% saveas(gcf,['./figures/Pixel_mds.bmp'])
