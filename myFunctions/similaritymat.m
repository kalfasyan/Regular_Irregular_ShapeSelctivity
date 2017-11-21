function [D] = similaritymat(layerchoice,network,stimchoice,distType)
% network = alexnet/vgg19
tic;
fprintf('Time for layer: %s \t', layerchoice);
addpath /data/local/myFunctions/
% getting a list with the extracted features for the preprocessed images
% each image.mat file has the features (or activations of the network's
% unit's) for each layer separately. We ignore the 'relu' layers, since
% they are not layers, but just an activation function thresholding at 0.

featdir = ['/data/local/Conv_NN/features/' network '_' stimchoice '/'];
featList = natsort(getAllFiles(featdir));
if strcmp(stimchoice,'regularIrregular') || strcmp(stimchoice,'regularIrregularSmall2x')
    featList = vertcat(featList(49:end), featList(1:48)); % moving Regular first
end

% Load a random image from featdir to find the index of the given layer
% (layerchoice)
fnames = dir(featdir);
load([featdir fnames(3).name]);
IndexC = strcmp(feature(:,2), layerchoice);
Index = find(IndexC>0);

% Initialize and create a matrix where:
% Rows :    all the images (48 with the mirrored ones)
% Columns:  all features/activations for given layer(layerchoice)
X = [];
for i=1:numel(featList)
    load(featList{i});
    X(i,:) = feature{Index,1}(:);
end

% CHECKING DISTRIBUTION OF UNITS
% z = randi([1 35781],1,49);
% for i =1:numel(z)
%     subplot(7,7,i); histogram(X(:,z(i))); hold on
% end

% % see 'doc pdist' in matlab documentation
D = pdist(X,distType);
D = squareform(D);

fprintf('--> %.2f seconds\n', toc)
end