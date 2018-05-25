clear;
addpath /media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/myFunctions/

% SETTINGS
quantify   = 1; % This will make a line plot for all layers instead of barplots for each (quantify=1 gives you the last figure from the paper)
cortype    = 'Pearson'; % to correlate means of barplots for each layer with mean of neural/human data
choice     = 'alexnet'; dim1 = 4; % set dim1 to 4 for alexnet and 5 for vgg
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

for hum1_nrn2_hmax3_pxl4 = 1:4 % human = 1, neural = 2, hmax = 3, pixel = 4
    disp(['Processing: ' num2str(hum1_nrn2_hmax3_pxl4)]);
    for ww = 1%:numel(networks) % for trained and untrained version
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

            % To compare with the human data, the last two groups (ISC_ISS) are
            % averaged into one, to M matrix has to be 8x5 instead of 8x6 as
            % the neural data comparison.
            % -----------------------------------------------------------
            % for human data, we have 5 groups. The 5th group is the last
            % two groups, averaged into one. Same is true for hmax
            %-------------------------------------------------------------------------------------
            if hum1_nrn2_hmax3_pxl4 == 1
                groupnames = {'R','IC','ISC','ISS','ISC_ISS'};
                [M, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb);
                
                humanM  = [10.6; 1.4; 2.05; 3.95; 21.7];
                hh{ww,qq} = corr(mean(M)', humanM,'Type',cortype);     

                if ~quantify
                    plot_notquantify(M,dim1,qq,SE, layerchoice, layer)
                end
                
            %-------------------------------------------------------------------------------------
            elseif hum1_nrn2_hmax3_pxl4 == 2
                % for neural data, we have 6 groups
                groupnames = {'R','IC','ISC','ISS','ISCa\_ISSa','ISCb\_ISSb'};
                [N, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb);
                neuralN = [7.4958;    5.0244;    5.3185;    5.5513;    6.6415;   6.6724];          
                nn{ww,qq} = corr(mean(N)', neuralN,'Type',cortype);

                if ~quantify
                    plot_notquantify(N,dim1,qq,SE, layerchoice, layer)
                end
            
            %-------------------------------------------------------------------------------------
            elseif hum1_nrn2_hmax3_pxl4 == 3
                % for hmax data, we have 5 groups
                groupnames = {'R','IC','ISC','ISS','ISC_ISS'};
                [J, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb);
                hmaxM = [0.42; 0.3268; 0.2625; 0.3196; 0.3406];
                hmx{ww,qq} = corr(mean(J)', hmaxM,'Type',cortype);                 

                if ~quantify
                    plot_notquantify(J,dim1,qq,SE, layerchoice, layer)
                end
                
            %-------------------------------------------------------------------------------------
            elseif hum1_nrn2_hmax3_pxl4 == 4
                % for pixel data, we have 5 groups
                groupnames = {'R','IC','ISC','ISS','ISC_ISS'};
                [K, SE] = organize_GroupDists(groupnames,DistsR,DistsIC,DistsISC,DistsISS,DistsISCa_ISSa,DistsISCb_ISSb);
                pixelM = [38.38; 41.18; 38.91; 38.11; 31.18;];
                pxl{ww,qq} = corr(mean(K)', pixelM,'Type',cortype);          

                if ~quantify
                    plot_notquantify(K,dim1,qq,SE, layerchoice, layer)
                end
            end
            
            if quantify; clear M N; end
            fprintf('Time: %.2f seconds\n',toc);
        end
    end
end


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
