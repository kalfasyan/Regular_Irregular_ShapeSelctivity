clear;
addpath ./myFunctions/

quantify   = 0;
cortype    = 'Pearson';
dim1 = 4;
stimchoice = 'regularIrregular';

% Check function documentation
%     if ~unitest_GroupNamesChecking( network, layer )
%         error('Something wrong with the name ordering of the stimuli files');
%     end

if ~quantify
    figure;
end


tic;

X = regireg_getPixelX(stimchoice);
X = X';

R_group   = X(:,1:16);
IC_group  = X(:,17:32);
ISC_group = X(:,33:48);
ISS_group = X(:,49:64);
ISCa_ISSa = X(:,[33,49,35,51,37,53,39,55,41,57,43,59,45,61,47,63]);
ISCb_ISSb = X(:,[34,50,36,52,38,54,40,56,42,58,44,60,46,62,48,64]);


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

% To compare with the human data, the last two groups (ISC_ISS) are
% averaged into one, to M matrix has to be 8x5 instead of 8x6 as
% the neural data comparison.
for hum1_nrn2 = 2 % human = 1, neural = 2
    if hum1_nrn2 == 1
        M(:,1) = DistsR;
        M(:,2) = DistsIC;
        M(:,3) = DistsISC;
        M(:,4) = DistsISS;
        groupnames = {'R','IC','ISC','ISS','ISC_ISS'};
        M(:,5)  = mean([DistsISCb_ISSb; DistsISCa_ISSa]);
        humanM  = [10.6; 1.4; 2.05; 3.95; 21.7];
        hh = corr(mean(M)', humanM,'Type',cortype);

        SE = [];
        for i=1:length(groupnames)
            SE(i) = std(M(:,i))/sqrt(size(M,1)); % standard errors of the mean
        end                   

        if ~quantify
            y = mean(M);
            x = 1:length(y);

            h = plot(x,y,'.');
            axis([0.5,6.5,min(mean(M))-max(SE)*1.2,max(mean(M))+max(SE)*1.2]);
            set(gca,'XTick',x, 'box', 'off');%,'XTickLabel',groupnames,'XTickLabelRotation',20);%,'FontSize', 7) %,
            hold on
            errorbar(x,y,SE,'.')
            hold off
        end

    elseif hum1_nrn2 == 2
        M(:,1) = DistsR;
        M(:,2) = DistsIC;
        M(:,3) = DistsISC;
        M(:,4) = DistsISS;
        groupnames = {'R','IC','ISC','ISS','ISCa\_ISSa','ISCb\_ISSb'};
        M(:,5) = DistsISCa_ISSa;
        M(:,6) = DistsISCb_ISSb;
        neuralM = [7.4958;    5.0244;    5.3185;    5.5513;    6.6415;   6.6724];          
        nn = corr(mean(M)', neuralM,'Type',cortype);

        SE = [];
        for i=1:length(groupnames)
            SE(i) = std(M(:,i))/sqrt(size(M,1)); % standard errors of the mean
        end    
        if ~quantify
            y = mean(M);
            x = 1:length(y);

            h = plot(x,y,'.');
            axis([0.5,6.5,min(mean(M))-max(SE)*1.2,max(mean(M))+max(SE)*1.2]);
            set(gca,'XTick',x, 'box', 'off');%,'XTickLabel',groupnames,'XTickLabelRotation',20);%,'FontSize', 7) %,
            hold on
            errorbar(x,y,SE,'.')
            hold off
        end
%         clear M
    end
    if quantify; clear M; end
end
fprintf('Time: %.2f seconds\n',toc);


% save(['FIG4_' choice '.mat'],'hh','nn','layer')
% if quantify
%    figure;
%    plot(cell2mat({hh{1,:}}),'k')
%    hold on
%    plot(cell2mat({hh{2,:}}),'b')
%    hold on
%    plot(cell2mat({nn{1,:}}),'g')
%    hold on
%    plot(cell2mat({nn{2,:}}),'y')
%    
%    set(gca,'XTick',1:numel(layer),'XTickLabel',layer,'XTickLabelRotation',90);
%    axis([0.5,length(layer)+0.5,-1,1]);
%    title([networks{1} ' ' cortype ' correlations with Human data']);
%    legend('Trained-human','Untrained-human','Trained-neural','Untrained-neural','Location','northwest')
%    grid on
% end
% disp('Done!')
