clear;
addpath ./myFunctions/

% SETTINGS
quantify   = 0; % This will make a line plot for all layers instead of barplots for each (quantify=1 gives you the last figure from the paper)
cortype    = 'Pearson'; % to correlate means of barplots for each layer with mean of neural/human data
choice     = 'alexnet'; dim1 = 4; % set dim1 to 4 for alexnet and 5 for vgg
stimchoice = 'regularIrregular';

% Layer names depending on the network chosen.
switch choice
    case 'alexnet'
        layer = getLayersFromNetwork(choice)';
        networks = {'alexnet','untrained'};
    case 'vgg16'
        layer = getLayersFromNetwork(choice)';
        networks = {'vgg16','untrainedvgg16'};
    case 'vgg19'
        layer = getLayersFromNetwork(choice)';
        networks ={'vgg19','untrainedVGG'};
    otherwise
        error('wrong network given!');
end

for ww = 1:numel(networks) % for trained and untrained version
    network = networks{ww};
    disp(network);
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

        [DistsR, DistsIC, DistsISC, DistsISS, DistsISCa_ISSa, DistsISCb_ISSb] = get_GroupDists(X);

        for hum1_nrn2 = 1:2 % human = 1, neural = 2
            % To compare with the human data, the last two groups (ISC_ISS) are
            % averaged into one, to M matrix has to be 8x5 instead of 8x6 as
            % the neural data comparison.
            % -----------------------------------------------------------
            % for human data, we have 5 groups. The 5th group is the last
            % two groups, averaged into one. Same is true for hmax
            %-------------------------------------------------------------------------------------
            if hum1_nrn2 == 1
                groupnames = {'R','IC','ISC','ISS','ISC_ISS'};
                [M, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb);
                
                humanM  = [10.6; 1.4; 2.05; 3.95; 21.7];
                hh{ww,qq} = corr(mean(M)', humanM,'Type',cortype);     

                if ~quantify
                    plot_notquantify(M,dim1,qq,SE, layerchoice, layer)
                end
                
            %-------------------------------------------------------------------------------------
            elseif hum1_nrn2 == 2
                % for neural data, we have 6 groups
                groupnames = {'R','IC','ISC','ISS','ISCa\_ISSa','ISCb\_ISSb'};
                [N, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb);
                neuralN = [7.4958;    5.0244;    5.3185;    5.5513;    6.6415;   6.6724];          
                nn{ww,qq} = corr(mean(N)', neuralN,'Type',cortype);

                if ~quantify
                    plot_notquantify(N,dim1,qq,SE, layerchoice, layer)
                end
            
            end
        end

        %if quantify; clear M N; end
        fprintf('Time: %.2f seconds\n',toc);
    end
end


%% PLOTTING
% save(['FIG4_' choice '.mat'],'hh','nn','layer')
if quantify
   figure;
   linesize = 3;
   plot(cell2mat({hh{1,:}}),'-','Color',[0,0.1,0.9],'LineWidth',linesize)
   hold on
   plot(cell2mat({hh{2,:}}),':','Color',[0,0.1,0.9],'LineWidth',linesize)
   hold on
   plot(cell2mat({nn{1,:}}),'-','Color',[0.9,0.1,0],'LineWidth',linesize)
   hold on
   plot(cell2mat({nn{2,:}}),':','Color',[0.9,0.1,0],'LineWidth',linesize)
   hold on
   plot(cell2mat({hmx{1,:}}),'-','Color',[0.1,0.9,0],'LineWidth',linesize)
   hold on
   plot(cell2mat({hmx{2,:}}),':','Color',[0.1,0.9,0],'LineWidth',linesize)
   hold on
   plot(cell2mat({pxl{1,:}}),'-','Color',[0.5,0.5,0.5],'LineWidth',linesize)
   hold on
   plot(cell2mat({pxl{2,:}}),':','Color',[0.5,0.5,0.5],'LineWidth',linesize)   
   
   set(gca,'XTick',1:numel(layer),'XTickLabel',layer,'XTickLabelRotation',90);
   axis([0.5,length(layer)+0.5,-1,1]);
   title([networks{1} ' ' cortype ' correlations']);
   legend('TrainedCNN-human','UntrainedCNN-human','TrainedCNN-neural','UntrainedCNN-neural','TrainedCNN-hmax','UntrainedCNN-hmax','TrainedCNN-pixels','UntrainedCNN-pixels','Location','northwest')
   grid on
end
disp('Done!')
