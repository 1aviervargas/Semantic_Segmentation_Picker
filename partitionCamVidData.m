function [imdsTrain, imdsTest, pxdsTrain, pxdsTest] = partitionCamVidData(imds,pxds)
% Partition data by randomly selecting 80% of the data for training. The
% rest is used for testing.

% Set initial random state for example reproducibility.
rng(0);
numFiles = numel(imds.Files);
shuffledIndices = randperm(numFiles);

% Use 80% of the images for training.
numTrain = round(0.8 * numFiles);
trainingIdx = shuffledIndices(1:numTrain);

% Use 20% of the images for validation
%numVal = round(0.20 * numFiles);
%valIdx = shuffledIndices(numTrain+1:numTrain+numVal);

numTest = round(0.20 * numFiles);
% Use the rest for testing.
testIdx = shuffledIndices(numTrain+1:end);

% Create image datastores for training and test.
trainingImages = imds.Files(trainingIdx);
%valImages = imds.Files(valIdx);
testImages = imds.Files(testIdx);

imdsTrain = imageDatastore(trainingImages,"FileExtensions",".png","ReadFcn",@(x)normy(x));
%imdsVal = imageDatastore(valImages);
imdsTest = imageDatastore(testImages,"FileExtensions",".png","ReadFcn",@(x)normy(x));

% Extract class and label IDs info.
%classes = pxds.ClassNames;
%labelIDs = camvidPixelLabelIDs();

classNames = ["Background" "RNP"];
pixelLabelID = [0 1];

% Create pixel label datastores for training and test.
trainingLabels = pxds.Files(trainingIdx);
%valLabels = pxds.Files(valIdx);
testLabels = pxds.Files(testIdx);

pxdsTrain = pixelLabelDatastore(trainingLabels, classNames,pixelLabelID,'ReadFcn',@(x)imresize((imread(x)/255)>=0.5,[640 448]));
pxdsTest = pixelLabelDatastore(testLabels, classNames,pixelLabelID,'ReadFcn',@(x)imresize((imread(x)/255)>=0.5,[640 448]));

end
