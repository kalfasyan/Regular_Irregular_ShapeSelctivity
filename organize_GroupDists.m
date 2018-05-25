function [M, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb)

if isequal(groupnames,{'R','IC','ISC','ISS','ISC_ISS'})
    M(:,1) = DistsR;
    M(:,2) = DistsIC;
    M(:,3) = DistsISC;
    M(:,4) = DistsISS;
    M(:,5)  = mean([DistsISCb_ISSb; DistsISCa_ISSa]);
elseif isequal(groupnames, {'R','IC','ISC','ISS','ISCa\_ISSa','ISCb\_ISSb'})
    M(:,1) = DistsR;
    M(:,2) = DistsIC;
    M(:,3) = DistsISC;
    M(:,4) = DistsISS;
    M(:,5) = DistsISCa_ISSa;
    M(:,6) = DistsISCb_ISSb;
else
    error('Wrong group names!');
end

SE = [];
for i=1:length(groupnames)
    SE(i) = std(M(:,i))/sqrt(size(M,1)); 
    % standard errors of the mean. we have 8 pairs for each
    % group (R,IC,ISC,ISS). The SE is calculated for the
    % mean of each pair
end