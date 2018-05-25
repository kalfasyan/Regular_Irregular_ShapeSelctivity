function [DistsR, DistsIC, DistsISC, DistsISS, DistsISCa_ISSa, DistsISCb_ISSb] = get_GroupDists(X)

% Stimuli are in columns (R1a, R1b, R2a, R2b, ... ISS8a,ISS8b)
R_group   = X(:,1:16);
IC_group  = X(:,17:32);
ISC_group = X(:,33:48);
ISS_group = X(:,49:64);
ISCa_ISSa = X(:,[33,49,35,51,37,53,39,55,41,57,43,59,45,61,47,63]);
ISCb_ISSb = X(:,[34,50,36,52,38,54,40,56,42,58,44,60,46,62,48,64]);

% eupairdist will take an index (for a column-stimulus responses)
% and calculate the euclidean distance between them.
c = 1;
for i=1:2:16
    DistsR(c)          = eupairdist(R_group,i);
    DistsIC(c)         = eupairdist(IC_group ,i);
    DistsISC(c)        = eupairdist(ISC_group ,i);
    DistsISS(c)        = eupairdist(ISS_group ,i);
    DistsISCa_ISSa(c)  = eupairdist(ISCa_ISSa ,i);
    DistsISCb_ISSb(c)  = eupairdist(ISCb_ISSb ,i);
    c = c+1;
end