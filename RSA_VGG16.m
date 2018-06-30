clear; 
addpath ./myFunctions/
addpath ./myFunctions/export_fig/

stimchoice = 'regularIrregular';%'regularIrregularSmall2x';%
distType = 'euclidean'; % for neurons
normalize = 0;

%% VGG16 distance matrices (euclidean) for every layer
network = 'untrainedvgg16';%'vgg16';  %
stimchoice = 'regularIrregular'; %stimchoice = 'regularIrregularSmall2x';
layer = getLayersFromNetwork(network)';

dname = './distance_matrices/';
load([dname network '_D_' stimchoice '_' distType '.mat'])

for i=1:numel(D)
    DEEPuptrUN(:,i) = getUpperDiagElements(D{i});
end
clear network D

% -------------------------------------------------------------

network = 'vgg16'; stimchoice = 'regularIrregular';
load([dname network '_D_' stimchoice '_' distType '.mat'])

for i=1:numel(D)
    DEEPuptrTR(:,i) = getUpperDiagElements(D{i});
end
clear network D

%% Regular-Irregular spike matrix and the Distances (euclidean)
load('regular_irregular_SPIKES_yannis.mat');
shapenames = regular_irregular_SPIKES_yannis.Properties.VariableNames;
shapenames = shapenames(3:end);

REGIRREG = table2array(regular_irregular_SPIKES_yannis);
REGIRREG = REGIRREG(:,3:end);

if normalize
    % INCLUDING NORMALIZATION FOR NEURONS - R{i}-mean(R))/norm(x)
    for i=1:size(REGIRREG,1)
        tmp = REGIRREG(i,:);
        tmp = (tmp - mean(tmp)) / norm(tmp);
        REGIRREG(i,:) = tmp;
    end
end

REGIRREGspikes = REGIRREG;
% Dreg = squareform(pdist(REGIRREG,'euclidean'));
% imagesc(Dreg)
% set(gca,'XTick',linspace(1,length(shapenames),length(shapenames)),'XTickLabel', shapenames,'XTickLabelRotation',90);
% set(gca,'YTick',linspace(1,length(shapenames),length(shapenames)),'YTickLabel', shapenames);

%% Bootstrapping the number of neurons (i.e. the biological neurons)

nrnsREGIRREG = 1:size(REGIRREGspikes,1); % to sample the nr of neurons
corType = 'Spearman';
iterations = 10000;
[bootstrappedTR, bootstrappedUN] = deal(zeros(iterations,length(layer)));

n_lay = length(layer);
parfor iter=1:iterations    
    smplREGIRREG = datasample(nrnsREGIRREG,length(nrnsREGIRREG),'Replace',true);
    % Sampling from 119 neurons and making a distance matrix for 64 stimuli
    REGIRREGdist = squareform(pdist(REGIRREGspikes(smplREGIRREG,:)',distType));
    REGIRREGuptr = getUpperDiagElements(REGIRREGdist)';

    for lay=1:n_lay % FOR PARFOR USE THE EXACT NUMBER INSTEAD OF VARIABLE
        bootstrappedUN(iter,lay) = corr(REGIRREGuptr,DEEPuptrUN(:,lay),'Type',corType);
        bootstrappedTR(iter,lay) = corr(REGIRREGuptr,DEEPuptrTR(:,lay),'Type',corType);
    end    

end

%% Noise ceiling
n = size(REGIRREGspikes,1);
ceilingNEUR = nan(iterations,1);
tic
for iter=1:iterations
    % split neural sample randomly in half
    I = randperm(n);
    g1 = I( 1:floor(n/2) );
    g2 = I( ceil(n/2):end );
    
    % calculate correlations between distance matrices for neural split
    % samples
    D1 = pdist(REGIRREGspikes(g1,:)',distType);
    D2 = pdist(REGIRREGspikes(g2,:)',distType);
    ceilingNEUR(iter) = corr(D1',D2','Type',corType);
end
toc
% spearman-brown correction
ceilingNEUR = (2*ceilingNEUR) ./ (1 + ceilingNEUR);

%% Analysis of Significance

% Trained vs untrained
pVals = mean((bootstrappedTR - bootstrappedUN)<=0);
FDR = mafdr(pVals,'BHFDR',true);
sigf = FDR<0.05;

% First vs Everything
p_values = mean((bootstrappedTR - repmat(bootstrappedTR(:,1),[1,size(bootstrappedTR,2)]) )<=0);
FDR2 = mafdr(p_values,'BHFDR',true);
sigf2 = FDR2<0.05;

layer(sigf2)
[m,i] = max(median(bootstrappedTR)); layer(i)

%% Plotting
% figure;
% colorUN = 'r';
% colorTR = 'g';
% alpha = 0.3;
% q1 = prctile(bootstrappedUN,2.5); % ciA(1,:)
% q2 = prctile(bootstrappedUN,97.5); % ciA(2,:)
% 
% x= 0.5:length(layer)-0.5;
% X=[x,fliplr(x)];                %#create continuous x value array for plotting
% Y=[q1,fliplr(q2)];              %#create y values for out and then back
% h1 = fill(X,Y,colorUN,'facealpha',alpha,'edgecolor','none');
% clear x X Y q1 q2
% hold on
% 
% %     scatter([0.5:length(layer)-0.5],mean(bootstrappedM),'.k'); 
% %     hold on
% q1 = prctile(bootstrappedTR,2.5); % ciM(1,:);%
% q2 = prctile(bootstrappedTR,97.5); % ciM(2,:);%
% x= 0.5:length(layer)-0.5;
% X=[x,fliplr(x)];                %#create continuous x value array for plotting
% Y=[q1,fliplr(q2)];              %#create y values for out and then back
% h2 = fill(X,Y,colorTR,'facealpha',alpha,'edgecolor','none');
% hold on
% 
% plot(linspace(0.5,length(layer)-0.5,length(layer)), median(bootstrappedTR), 'g')
% hold on
% plot(linspace(0.5,length(layer)-0.5,length(layer)), median(bootstrappedUN), 'r')
% hold on
% 
% 
% axis([0,length(layer),-0.2,1])
% legend([h1 h2],'untrained','trained')
% title(['Correlation type: ' corType ' -- Distance type: ' distType ' -- Stimuli: ' stimchoice]);
% set(gca,'XTick',linspace(0.5,length(layer)-0.5,length(layer)),'XTickLabel', layer,'XTickLabelRotation',90);
% grid on
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
q1 = prctile(bootstrappedTR,2.5); 
q2 = prctile(bootstrappedTR,97.5);
y = median(bootstrappedTR);
x = linspace(0.5,length(layer)-0.5,length(layer));

cci = prctile(ceilingNEUR,[2.5 97.5]);
cmu = median(ceilingNEUR);

hold on;
fill( [0,n_lay,n_lay,0] , cci([1,1,2,2]), [1,1,1]*.9, 'edgecolor','none' )
plot( [0,n_lay], [1,1]*cmu, '-k' )

hh = errorbar(x,y, q1-y,q2-y, 'ob');

set(gca,'XTick',linspace(0.5,length(layer)-0.5,length(layer)),'XTickLabel', layer,'XTickLabelRotation',90);


% figure;
hold on
q1 = prctile(bootstrappedUN,2.5);
q2 = prctile(bootstrappedUN,97.5);
y = median(bootstrappedUN);
x = linspace(0.5,length(layer)-0.5,length(layer));

hold on;
plot(x,y,'r')
errorbar(x,y, q1-y,q2-y, 'o')
set(gca,'XTick',linspace(0.5,length(layer)-0.5,length(layer)),'XTickLabel', layer,'XTickLabelRotation',90);
title(distType)
axis([0,length(layer),0.0,1])
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Significance stars
tmp1 = linspace(0.5,length(layer)-0.5,length(layer));
tmp2 = median(bootstrappedTR);
for i=1:length(layer)
    if sigf(i) > 0
        plot(tmp1(i)-.4, tmp2(i),'*k');
    end
    if sigf2(i) > 0
        plot(tmp1(i)+.4, tmp2(i),'+k');
    end    
end
