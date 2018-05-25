clear;
% This script will create the dissimilarity matrices for all layers of
% a chosen deep neural network of our stimuli (regularIrregular)
addpath ./myFunctions

stimchoice = 'regularIrregularSmall2x';%'regularIrregular';
distType = 'euclidean';%'spearman';%
network = 'vgg19';
disp(network)

% Select which network to use
if strcmp(network,'alexnet') || strcmp(network,'untrained')
    layer = getLayersFromNetwork(network)';
elseif strcmp(network,'vgg19') || strcmp(network,'untrainedVGG')
    layer = getLayersFromNetwork(network)';
elseif strcmp(network,'vgg16') || strcmp(network,'untrainedvgg16')
    layer = getLayersFromNetwork(network)';
else
    error('Wrong network input given.');
end
%% Dissimilarity matrices for all layers will be stored in a cell array 'D'
D = cell(0);
tic;
for i = 1:numel(layer)
    D{i} = similaritymat(layer{i},network,stimchoice,distType);
end

save([network '_D_' stimchoice '_' distType '.mat'],'D')
