clear;
addpath /data/local/myFunctions/

% SETTINGS
quantify   = 1; % This will make a line plot for all layers instead of barplots for each (quantify=1 gives you the last figure from the paper)
cortype    = 'Pearson'; % to correlate means of barplots for each layer with mean of neural/human data
choice     = 'vgg16'; dim1 = 5; % set dim1 to 4 for alexnet and 5 for vgg
stimchoice = 'regularIrregular';

% Setting the layer names depending on the network chosen.
if strcmp(choice,'alexnet')
    layer = getLayersFromNetwork(choice)';
    networks = {'alexnet','untrained'};
elseif strcmp(choice, 'vgg16')
    layer = getLayersFromNetwork(choice)';
    networks = {'vgg16','untrainedvgg16'};
elseif strcmp(choice,'vgg19')
    layer = getLayersFromNetwork(choice)';
    networks ={'vgg19','untrainedVGG'};
else
    error('wrong input');
end

for hum1_nrn2 = 1:2             % human = 1, neural = 2
    for ww = 1:numel(networks) % for trained and untrained version
        network = networks{ww};
        % Check function documentation
    %     if ~unitest_GroupNamesChecking( network, layer )
    %         error('Something wrong with the name ordering of the stimuli files');
    %     end

        if ~quantify
            figure;
        end

        for qq=1:numel(layer) % for each layer

            tic;
            layerchoice = layer{qq};
            fprintf('Layer: %s\t',layerchoice);

            % get layer features into a (DeepUnits x Stimuli) matrix
            [X, featList] = regireg_getDeepX(network, layerchoice, stimchoice);
            X = X';

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

            % To compare with the human data, the last two groups (ISC_ISS) are
            % averaged into one, to M matrix has to be 8x5 instead of 8x6 as
            % the neural data comparison.
            % -----------------------------------------------------------
            % for human data, we have 5 groups. The 5th group is the last
            % two groups, averaged into one
            if hum1_nrn2 == 1
                groupnames = {'R','IC','ISC','ISS','ISC_ISS'};
                M(:,1) = DistsR;
                M(:,2) = DistsIC;
                M(:,3) = DistsISC;
                M(:,4) = DistsISS;
                M(:,5)  = mean([DistsISCb_ISSb; DistsISCa_ISSa]);
                humanM  = [10.6; 1.4; 2.05; 3.95; 21.7];
                hh{ww,qq} = corr(mean(M)', humanM,'Type',cortype);

                SE = [];
                for i=1:length(groupnames)
                    SE(i) = std(M(:,i))/sqrt(size(M,1)); 
                    % standard errors of the mean. we have 8 pairs for each
                    % group (R,IC,ISC,ISS). The SE is calculated for the
                    % mean of each pair
                end                   

                if ~quantify
                    % barplots showing the dissimilarities for each of the
                    % groups.
                    y = mean(M);
                    x = 1:length(y);

                    subplot(dim1,dim1+1,qq);
                    h = plot(x,y,'.');
                    axis([0.5,6.5,min(mean(M))-max(SE)*1.2,max(mean(M))+max(SE)*1.2]);
                    set(gca,'XTick',x, 'box', 'off');
                    title(layerchoice);
                    hold on
                    errorbar(x,y,SE,'.')
                    hold off
                    if qq == numel(layer)
                        saveas(gcf,['/home/luna.kuleuven.be/u0107087/Desktop/' network '_human.bmp'])
                    end
                end

                % -----------------------------------------------------------
                % for neural data, we have 6 groups
            elseif hum1_nrn2 == 2
                groupnames = {'R','IC','ISC','ISS','ISCa\_ISSa','ISCb\_ISSb'};
                N(:,1) = DistsR;
                N(:,2) = DistsIC;
                N(:,3) = DistsISC;
                N(:,4) = DistsISS;
                N(:,5) = DistsISCa_ISSa;
                N(:,6) = DistsISCb_ISSb;
                neuralN = [7.4958;    5.0244;    5.3185;    5.5513;    6.6415;   6.6724];          
                nn{ww,qq} = corr(mean(N)', neuralN,'Type',cortype);

                SE = [];
                for i=1:length(groupnames)
                    SE(i) = std(N(:,i))/sqrt(size(N,1)); 
                    % standard errors of the mean. we have 8 pairs for each
                    % group (R,IC,ISC,ISS). The SE is calculated for the
                    % mean of each pair
                end

                    if ~quantify
                        % barplots showing the dissimilarities for each of the
                        % groups.
                        y = mean(N);
                        x = 1:length(y);

                        subplot(dim1,dim1+1,qq);
                        h = plot(x,y,'.');
                        axis([0.5,6.5,min(mean(N))-max(SE)*1.2,max(mean(N))+max(SE)*1.2]);
                        set(gca,'XTick',x, 'box', 'off');
                        title(layerchoice);
                        hold on
                        errorbar(x,y,SE,'.')
                        hold off
                        if qq == numel(layer)                    
                            saveas(gcf,['/home/luna.kuleuven.be/u0107087/Desktop/' network '_neural.bmp'])
                        end
                    end
            end
            if quantify; clear M N; end
        end
        fprintf('Time: %.2f seconds\n',toc);
    end
end


% save(['FIG4_' choice '.mat'],'hh','nn','layer')
if quantify
   figure;
   plot(cell2mat({hh{1,:}}),'k')
   hold on
   plot(cell2mat({hh{2,:}}),'b')
   hold on
   plot(cell2mat({nn{1,:}}),'g')
   hold on
   plot(cell2mat({nn{2,:}}),'y')
   
   set(gca,'XTick',1:numel(layer),'XTickLabel',layer,'XTickLabelRotation',90);
   axis([0.5,length(layer)+0.5,-1,1]);
   title([networks{1} ' ' cortype ' correlations with Human data']);
   legend('Trained-human','Untrained-human','Trained-neural','Untrained-neural','Location','northwest')
   grid on
end
disp('Done!')
