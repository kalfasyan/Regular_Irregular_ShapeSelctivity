function [ X, featList ] = regireg_getDeepX( network, layerchoice, stimchoice )
% Given a network, layer of network and a directory with stimuli, this
% function creates an X matrix with rows corresponding to stimuli and
% columns corresponding to deep unit activations (deep artificial neurons)

% Make a list of the stimuli file names
featdir = ['/media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/features/' network '_' stimchoice '/'];
featList = natsort(getAllFiles(featdir));
featList = vertcat(featList(49:end), featList(1:48)); % moving Regular first like Kayaert's paper

% Load a random image from featdir to find the index of the given layer
% (layerchoice)
fnames = dir(featdir);
load([featdir fnames(3).name]);
IndexC = strcmp(feature(:,2), layerchoice);
Index = find(IndexC>0);

% Initialize and create a matrix where:
% Rows :    all the images
% Columns:  all features/activations for given layer(layerchoice)
X = [];
for i=1:numel(featList)
    load(featList{i});
    X(i,:) = feature{Index,1}(:);
end