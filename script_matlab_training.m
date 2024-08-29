clear all;
close all;
rng(0)

%% Train the Network:
%---------------------------------------------------------------------------------------------------------------------------------------------------------
%Folder where the preprocessed mics are placed:
imDir1 = '/mnt/DATOS2/jvargas/ScipionUserData/projects/RNP_Vargas/Solo_Puntas/IMAGES_FILTERED/';
%Folder where the manually labelled  mics are placed:
pxDir1 = '/mnt/DATOS2/jvargas/ScipionUserData/projects/RNP_Vargas/Solo_Puntas/SEGMENTED/';

%Load the image data using an imageDatastore. An image datastore can efficiently represent a large 
%collection of images because images are only read into memory when needed. 
%We can include some operations to be done when the data is loaded by inlucing the 
%'ReadFcn' field. In this case we call to normy function (below) to do some normalization to the
%images to use.
imds = imageDatastore(imDir1,"FileExtensions",".png","ReadFcn",@(x)normy(x))

%Load the pixel label images using a pixelLabelDatastore to define the mapping between label IDs 
%and categorical names. In the dataset used here, the labels are 'Background','RNP'. The label IDs 
%for these classes are 0 and 1, respectively.
classNames = ["Background" "RNP"];
pixelLabelID = [0 1];
pxds = pixelLabelDatastore(pxDir1,classNames,pixelLabelID,'ReadFcn',@(x)imresize((imread(x)/255)>=0.5,[640 448]));

%FOR DEBUGGING ONLY:
%Read and display the mic and segmented mic number indx:
% idx = 20;
% I = readimage(imds,idx);
% figure,
% imagesc(I)
% C = readimage(pxds,idx);
% B = labeloverlay(I,C);
% figure, imagesc(B)

%% Define and Train the network
%https://es.mathworks.com/help/vision/ref/unetlayers.html
%Class weightening: Much more pixels labelled as 'Background' than 'RNP'
%so we have to compensate this weighting the classes
%https://es.mathworks.com/help/vision/ug/semantic-segmentation-using-deep-learning.html 
tbl = countEachLabel(pxds)
frequency = tbl.PixelCount/sum(tbl.PixelCount);
classWeights = 1./ frequency
classWeights = [1 2]
imageSize = [640 448];
numClasses = 2;

%If we have already trained the network we can perform a transfer learning:
%load results_training.mat;
%load('net_dice.mat');
%lgraph = net.layerGraph;

%If we have not pretrained the network, we must train from the begining:
lgraph = unetLayers(imageSize, numClasses,'FilterSize',7,'EncoderDepth',3)

% We do some changes to the network. We change the loss to a dice loss
% which is more robust to unbalanced classes.Another option is using The 
%"typical classification layer but weighting the different classes.

% Case typical classification layer but weighting the different classes:
layer_1 = pixelClassificationLayer('Name','labels','Classes',tbl.Name,'ClassWeights',classWeights);
%lgraph = replaceLayer(lgraph,"DiceLoss",layer_1);
lgraph = replaceLayer(lgraph,'Segmentation-Layer',layer_1);

% Case Dice loss:
%layer_1 = dicePixelClassificationLayer('Name','DiceLoss');
%lgraph = replaceLayer(lgraph,'Segmentation-Layer',layer_1);

plot(lgraph)

%We divide the dataset into Training and Validation
[imdsTrain, imdsVal, pxdsTrain, pxdsVal] = partitionCamVidData(imds,pxds)

%Create a datastore for training the network.
dsTrain = combine(imdsTrain,pxdsTrain);

%We include data augmentation to improve the training:
xTrans = [-10 10];
yTrans = [-10 10];

dsTrain = transform(dsTrain, @(data)augmentImageAndLabel(data,xTrans,yTrans));

%Create a datastore for training the network.
dsVal = combine(imdsVal,pxdsVal);

numGPUs = gpuDeviceCount("available")
miniBatchSize = 30;

options = trainingOptions('adam', ...
    'ExecutionEnvironment',"multi-gpu", ... % Turn on automatic multi-gpu support.
    'InitialLearnRate',2e-5, ...
    'MaxEpochs',50, ...
    'MiniBatchSize',miniBatchSize, ...
    'Shuffle','every-epoch', ...
    'LearnRateSchedule',"piecewise", ...
    'LearnRateDropFactor',0.65, ...
    'LearnRateDropPeriod',1, ...
    'VerboseFrequency',10, ...
    'ValidationData',dsVal, ....
    'ValidationFrequency',50, ...
    'Verbose',true, ...
    'Plots','training-progress');
    
[net info] = trainNetwork(dsTrain,lgraph,options)
save('results_training.mat')
