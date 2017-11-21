function [ Result ] = unitest_GroupNamesChecking( network, layer )
% unitest_GroupNamesChecking: Checks if the stimuli names that Yannis used to create the 64xN 
%                             matrix of features, is in the same order as Kayaert's data.

[~, featList] = regireg_getDeepX(network, layer{end});
namesFromFunction = cell(1,numel(featList));
for i=1:numel(featList)
    tmp = strsplit(featList{i},'/');
    tmp = tmp{end}(1:end-4);
    namesFromFunction{i} = tmp;
end

load('regular_irregular_SPIKES_yannis.mat'); % Kayaert's data, names changed to english and verified by Rufin
namesFromKayaert = regular_irregular_SPIKES_yannis.Properties.VariableNames;
namesFromKayaert = namesFromKayaert(3:end);

Result = isequal(namesFromFunction, namesFromKayaert);

