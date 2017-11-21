function [ Eudist ] = eupairdist( Group, ind1 )
% Example: Group = Regular Group from fig 2. "Representation of regular and
%                  irregular shapes in macaque IT"
%          ind1  = Index given from previous script that will run through
%                  the pairs of fig 2.

n = size(Group,1); % nr of neurons

SumSigma = 0; % initialize matrix - [nr. of neurons x 1]
for i = 1:n
    % Calculate pair difference squared
    SumSigma = SumSigma + (Group(i,ind1) - Group(i,ind1+1)) ^ 2;
end

% Take the square root of the sum of above (the pair differences squared)
% normalized by the nr. of neurons
Eudist = sqrt(SumSigma / n );