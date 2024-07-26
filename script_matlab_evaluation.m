%load net;
load('results_training.mat');
rng(0);

%% Evaluation of the network
%https://es.mathworks.com/help/vision/ug/semantic-segmentation-using-deep-learning.html

%% Calculated over all images:
pxdsResults = semanticseg(imds,net, ...
    'MiniBatchSize',20, ...
    'WriteLocation',tempdir, ...
    'Verbose',false);

metrics = evaluateSemanticSegmentation(pxdsResults,pxds,'Verbose',true);

%% Calculated over Training set images:
pxdsResults = semanticseg(imdsTrain,net, ...
    'MiniBatchSize',20, ...
    'WriteLocation',tempdir, ...
    'Verbose',false);

metrics = evaluateSemanticSegmentation(pxdsResults,pxdsTrain,'Verbose',true);

%% Calculated over Validation set images:
pxdsResults = semanticseg(imdsVal,net, ...
    'MiniBatchSize',20, ...
    'WriteLocation',tempdir, ...
    'Verbose',false);

metrics = evaluateSemanticSegmentation(pxdsResults,pxdsVal,'Verbose',true);

%% Test case2 Visualization example:
%----------------------------------------
idx = 28 %32
testImage = readimage(imdsVal,idx);

%Contrast inversion:
temp = max(testImage(:))-testImage;
figure, imagesc(temp); colormap gray
axis off

%Read the manually labelled image and showed over the mic
C = readimage(pxdsVal,idx);
C = double(C);
C = (C > 1.5)*2;
B = labeloverlay(temp,C, 'Colormap','hot','Transparency',0.45);
figure, imagesc(B); colormap gray
axis off

%Apply semantic segmentation:
C = semanticseg(testImage,net);
C = double(C);
se = strel('disk',8);
out = imopen(C>1.5,se)*2;
B = labeloverlay(temp,out, 'Colormap','hot','Transparency',0.45);
figure, imagesc(B), colormap gray
axis off

%% Test Case2: Visualization example:
idx = 32
testImage = readimage(imdsVal,idx);
%Contrat inversion
temp = max(testImage(:))-testImage+;
figure, imagesc(temp), colormap gray, axis off;

C = semanticseg(testImage,net);
C = double(C);
se = strel('disk',8);
out = imopen(C>1.5,se)*2;
figure, imagesc(out), colormap gray
axis off

%Now we extract the centroids of the labelled regions;
L = bwlabel(out,8);
stats = regionprops(L,'centroid','Area');
centroids = cat(1,stats.Centroid);
area = cat(1,stats.Area);
centroids = centroids((area>1) & (area < 700),:);

%We plot the centroids:
figure, imagesc(L), colormap jet, colorbar
hold on
plot(centroids(:,1),centroids(:,2),'k.')
axis off

%We plot rectangles showing particles:
figure, imagesc(temp); colormap gray
hold on
wx = 30;
wy = 30*(640/448);
for i=1:length(centroids)
    rectangle('Position',[centroids(i,1)-wx/2,centroids(i,2)-wy/2,wx,wy],'LineWidth',1.5,'EdgeColor','r')
end
hold off
axis off

