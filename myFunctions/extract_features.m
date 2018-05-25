function extract_features(imagepath,netFile)

addpath /media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/myFunctions
modelPath = '/media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/models/';
% setup MatConvNet
run  /media/yannis/HGST_4TB/Ubudirs/matconvnet-1.0-beta24/matlab/vl_setupnn

% All models are in /media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/models/
switch netFile
    case 'net-alex-untrained.mat'
        network = 'untrained';
    case 'imagenet-caffe-alex.mat'
        network = 'alexnet';
    case 'imagenet-vgg-verydeep-19.mat'
        network = 'vgg19';
    case 'untrained-vgg-verydeep-19.mat'
        network = 'untrainedVGG';
    case 'vgg16-animacy.mat'
        network = 'vgg16_animacy';
    case 'imagenet-vgg-verydeep-16.mat'
        network = 'vgg16';
    case 'untrained-vgg-verydeep-16.mat'
        network = 'untrainedvgg16';
    case 'imagenet-googlenet-dag.mat'
        network = 'googlenet';
    otherwise
        error('wrong network given!');
end

stimulist = natsort(getAllFiles(imagepath));

regularIrregularFLAG = strsplit(imagepath,'/');
if strcmp(regularIrregularFLAG(end),'regularIrregular')
    stimulist = vertcat(stimulist(49:end), stimulist(1:48));
end

fprintf('Nr. of stimuli: %s\t', num2str(length(stimulist)));

imgpathSplit = strsplit(imagepath,'/');
if strcmp(imgpathSplit(end),''); imgpathSplit = imgpathSplit(end-1); else imgpathSplit = imgpathSplit(end);end
imgpathSplit = imgpathSplit{1};

if exist(['/media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/features/' network '_' imgpathSplit '/'],'dir') ~= 7
    mkdir(['/media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/features/' network '_' imgpathSplit]);
else
    if numel(dir(['/media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/features/' network '_' imgpathSplit '/']))-2 == numel(stimulist)
        warning('Features have already been extracted. Check/Delete them and re-run.');
    end
end

if strcmp(network,'googlenet')
    netFile = 'imagenet-googlenet-dag.mat';
    net = dagnn.DagNN.loadobj(load([modelPath 'imagenet-googlenet-dag.mat'])) ;
    net.mode = 'test' ;
    net.conserveMemory = false;
    % net.device = 'gpu';
    Layernames = {net.vars.name};
else
    net = load([modelPath netFile]); %net = net.net;
    net = vl_simplenn_tidy(net);
    % Removing the cropping from preprocessing
    net.meta.normalization.border = [0 0];
    layerNames = net.layers;
    for i=1:length(layerNames)
        layerCell{i} = layerNames{i}.name;
    end
end

tic;


for i = 1:numel(stimulist)
    % load and preprocess an image
    im = imread(stimulist{i});
    im_ = single(im); % NOTE: 0-255 range
    im_ = imresize(im_, net.meta.normalization.imageSize(1:2)); % try Bilinear or Nearest
    im_ = bsxfun(@minus, im_, net.meta.normalization.averageImage);
% % TEST - DONT USE    im_ = single(mat2gray(im_));
    
    if strcmp(network,'googlenet')
        net.eval({'data', im_});
        for j=1:numel(Layernames)
            tmp = net.vars(net.getVarIndex(Layernames{j})).value;
            feature{j,1} = squeeze(gather(tmp));
            feature{j,2} = Layernames{j};
        end
    else
        % run the CNN
        % net.layers = net.layers(1:end-1);
        % FROM VL_SIMPLENN THE MODE IS SET AS 'TEST' TO IGNORE DROPOUT
        net.layers{end}.type = 'softmax';
        res = vl_simplenn(net, im_);
        for k=2:length(layerNames)+1
            feature{k-1,1} = res(k).x;
            feature{k-1,2} = layerCell{k-1};
        end
    end

    % Saving in feature directory

    imgnameSplit = strsplit(stimulist{i},'/');
    imgnameSplit = imgnameSplit{end}(1:end-4);
    
    save(['/media/yannis/HGST_4TB/Ubudirs/Regular_Irregular_ShapeSelectivity-master/features/' network '_' imgpathSplit '/' imgnameSplit '.mat'], ... 
            'feature');
end
clear stimulist feature res im im_
fprintf('Time: %.2f seconds\n', toc);
