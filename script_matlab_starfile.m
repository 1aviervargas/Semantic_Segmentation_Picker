clear all;
close all;

%Load the network:
load('results_training.mat');

% Go to the project folder. Please, change this path to the place where
% the folder 'IMAGES_FILTERED' is located.
cd('/mnt/DATOS2/jvargas/ScipionUserData/projects/RNP_Vargas/Solo_Puntas')

imDir1 = '/mnt/DATOS2/jvargas/ScipionUserData/projects/RNP_Vargas/Solo_Puntas/IMAGES_FILTERED/';
imds = imageDatastore(imDir1,"FileExtensions",".png","ReadFcn",@(x)normy(x))
downsampling = 1;

%%
for idx = 1:length(imds.Files)

    I = readimage(imds,idx);

    %Evaluate the image with the net:
    C = double(semanticseg(I,net));

    %Original format:
    C = imresize(C,[454,639]);
    I = imresize(I,[454,639]);

    se = strel('disk',2);
    C = imclose(C<1.5,se);
    L = bwlabel(C,8);

    stats = regionprops(L,'centroid','Area');
    centroids = cat(1,stats.Centroid);
    area = cat(1,stats.Area);
    centroids = centroids((area>1) & (area < 1000),:);
   
    str = erase(cell2mat(imds.Files(idx)),append(cell2mat(imds.Folders(1)),'/') );
    str = split(str,'.');
    str = append('/mnt/DATOS2/jvargas/ScipionUserData/projects/RNP_Vargas/Solo_Puntas/POS_FILES_filtered/',str{1},'_borders.pos')

    s.cost = centroids(:,1)./centroids(:,1);
    s.enabled = centroids(:,1)./centroids(:,1);
    
    s.xcoor = centroids(:,1)*downsampling;
    s.ycoor = centroids(:,2)*downsampling;
    
    WriteStarFileStruct(s,'particles_auto',str)

    %figure(1), imagesc(I); colormap gray
    %hold on
    %plot(s.xcoor(:),s.ycoor(:),'or')
    %hold off
    %pause;
    
    clear s;
end
