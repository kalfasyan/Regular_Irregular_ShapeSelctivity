function [ all_features, Lsize ] = getLayFeats_1D( layer, feats, stimulSize )
%getLayFeats_1D Given a specific layer from a CNN and the features
%               extracted from it for each stimulus, this function creates a nxp 
%               array where n is the number of stimuli and p is the length
%               of the 1D version of each CNN layer.


stimFeature = load(feats{1});
z = fieldnames(stimFeature); z = z{1}; stimFeature = stimFeature.(z); clear z 
findLayerStr = strfind(stimFeature(:,2),layer); 
indexOfLayer = find(not(cellfun('isempty',findLayerStr)));
if isempty(indexOfLayer)
    error('Wrong layer name given.');
end
layerFeatures = stimFeature{indexOfLayer,1};
clear stimFeature indexOfLayer findLayerStr
Lsize = size(layerFeatures);
s = prod(Lsize);

all_features = zeros(stimulSize, s);
all_features = single(all_features);
for i=1:numel(feats)
    stimFeature = load(feats{i}); % Load the features extracted from 'layer' for 'i' stimulus 
    z = fieldnames(stimFeature); z = z{1}; stimFeature = stimFeature.(z); clear z 
    % stimFeature has features from all layers
    findLayerStr = strfind(stimFeature(:,2),layer); % so, we find the layer we want features from
    indexOfLayer = find(not(cellfun('isempty',findLayerStr))); indexOfLayer = indexOfLayer(1);
    layerFeatures = stimFeature{indexOfLayer,1}; % it's this one.
    clear stimFeature indexOfLayer findLayerStr
    all_features(i,:) = single(reshape(layerFeatures, [1 s])); % we reshape and add it 
end