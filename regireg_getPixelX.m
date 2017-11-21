function [ X ] = regireg_getPixelX( stimchoice )
addpath /data/local/myFunctions/

featdir = ['./' stimchoice];
featList = natsort(getAllFiles(featdir));
featList = vertcat(featList(49:end), featList(1:48)); % moving Regular first

% Initialize and create a matrix where:
% Rows :    all the images
% Columns:  all features/activations for given layer(layerchoice)
X = [];
for i=1:numel(featList)
    tmp    = imread(featList{i});
    X(i,:) = tmp(:);
end