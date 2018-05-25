function [ layers, layersizes ] = getLayersFromNetwork( network )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% File contains cell arrays with alexnet/vgg16/vgg19 sizes and names of
% layers in columns respectively
layers = load('./network_layer_sizes.mat');

z = fieldnames(layers); 
indx = find(strcmp(z,network)>0); 
z = z{indx}; 
layers = layers.(z); 
layersizes = layers(:,1);
layers = layers(:,2); 
% Getting rid of 'prob' layers
if strcmp(layers(end),'prob')
    layers(end) = [];
    layersizes(end) = [];
end