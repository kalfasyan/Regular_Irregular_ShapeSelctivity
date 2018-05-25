clear;
%% Regular-Irregular spike matrix and the Distances (euclidean)
load('regular_irregular_SPIKES_yannis.mat');
shapenames = regular_irregular_SPIKES_yannis.Properties.VariableNames;
shapenames = shapenames(3:end);

groupnames = {'R','IC','ISC','ISS','ISCa\_ISSa','ISCb\_ISSb'};%,'ISC\_ISS'};%

REGIRREG = table2array(regular_irregular_SPIKES_yannis);
REGIRREG = 4 .* REGIRREG; % (spikes per second?)
% for i=1:119
%     REGIRREG(i,:) = REGIRREG(i,:) / max(REGIRREG(i,:));
% end

R_group   = REGIRREG(:,3:18);
IC_group  = REGIRREG(:,19:34);
ISC_group = REGIRREG(:,35:50);
ISS_group = REGIRREG(:,51:66);
ISCa_ISSa = REGIRREG(:, [35,51,37,53,39,55,41,57,43,59,45,61,47,63,49,65]);
ISCb_ISSb = REGIRREG(:, [36,52,38,54,40,56,42,58,44,60,46,62,48,64,50,66]);

ISC_ISS = horzcat(ISCa_ISSa, ISCb_ISSb);

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
% c=1;
% for i=1:2:32
%     DistsISC_ISS(c)  = eupairdist(ISC_ISS ,i);
%     c=c+1;
% end
    
M(:,1) = DistsR;
M(:,2) = DistsIC;
M(:,3) = DistsISC;
M(:,4) = DistsISS;
% M(:,5) = mean([DistsISCb_ISSb; DistsISCa_ISSa]);
M(:,5) = DistsISCa_ISSa;
M(:,6) = DistsISCb_ISSb;

N(:,1) = DistsR;
N(:,2) = DistsIC;
N(:,3) = DistsISC;
N(:,4) = DistsISS;
N(:,5) = mean([DistsISCb_ISSb; DistsISCa_ISSa]);

humanM  = [10.6; 1.4; 2.05; 3.95; 21.7];
hmaxM   = [0.42; 0.3268; 0.2625; 0.3196; 0.3406];
pixelsM = [38.38; 41.18; 38.91; 38.11; 31.18;];

zz(1) = corr(hmaxM, mean(N)');
zz(2) = corr(pixelsM, mean(N)');
zz(3) = corr(hmaxM, humanM);
zz(4) = corr(pixelsM, humanM);

bar(zz)