%Advanced Image Processing course, Image Segmentation lab
%by Daria Kruzhinskaia

% Lab 2. Exercise 1. Properties of microcalcifications

%% reading
I = imread('bencalc1.tif');
BC =  I;

%% Method #3 ? prefered. Adapted threshold + watershed

%  Thresholding & segmentation
thresh = adaptthresh (I, 0.15);
BW2 = imbinarize (I, thresh);
SE = strel ('disk', 2);
BW2 = imclose(BW2, SE);
D = -bwdist(~BW2);
mask = imextendedmin(D,2);
D2 = imimposemin(D,mask);
D2(~BW2) = -Inf;
%Apply watershed
L = watershed(D2);
BW2(L==0) = 0;
BW2 = imopen(BW2, SE);

imshowpair(I, BW2 , 'montage'); 

% Determine the number of microcalcifications in the image, as well as their average size

[Label, Num] = bwlabel(BW2);
disp(['Number of microcalcifications: ', string(Num)]); 

Stats = regionprops (Label, 'Area', 'Centroid', 'Perimeter');
size = cat(1, Stats.Area);
disp(['Average size: ', string(mean(size)), ' pixels']);

%Localize and show the biggest calcification

maxMC = max(size); 
radius = sqrt(maxMC/3.14);
centrs = cat(1, Stats.Centroid);

[row, col]= find((size == maxMC)==1);

% figure; imshow (BW2); hold on;
% viscircles([centrs(row,1), centrs(row,2)],radius,'Color', 'b'); %draw circles

%% Method #1. Using imbinarize with Otsu method 

BC_level=graythresh(BC);
BC_gray=imbinarize(BC,'adaptive','ForegroundPolarity','bright','Sensitivity',BC_level);
REs_BW=bwareaopen(BC_gray,50,4);

STATS= regionprops(REs_BW,'centroid', 'Area','MajorAxisLength','MinorAxisLength', 'Perimeter');
Area=[STATS.Area];
Per=[STATS.Perimeter];
Centroids=[STATS.Centroid];
maxArea=max(Area);
meansize=mean(Area);
Radio=max(Per)/(2*pi);
posicion=find(Area==max(Area)); 
center=STATS(posicion).Centroid;
%figure, imshowpair(BC, REs_BW, 'montage');

% figure, imshow(REs_BW)
% hold on
% viscircles(center,Radio, Color', 'b');
% hold off

%% Method #2, using top-hat 

se = strel('disk',12);
tophatFiltered = imtophat(BC,se); %homogenize the illumination
contrastAdjusted = imadjust(tophatFiltered);
BC_level=graythresh(contrastAdjusted);

% figure, subplot(2,2,1); imshow(BC), title ('original')
% subplot(2,2,2); imshow(tophatFiltered), title('top-hat filter image') 
% subplot(2,2,3); imshow(contrastAdjusted), title('contrast adjusted image')
% subplot(2,2,4); imshow(imbinarize(contrastAdjusted,BC_level)), title(' BW image')

%figure; imshowpair(contrastAdjusted,imbinarize(contrastAdjusted,BC_level),'montage');
BW_th = imbinarize(contrastAdjusted,BC_level);

%% show results 
figure;
subplot (2,2, 1);imshow(I); title ('Original');
subplot (2,2, 2);imshow(REs_BW); hold on;  viscircles(center,Radio, 'Color', 'b');hold off; title ('Method #1');
subplot (2,2, 3);imshow(BW_th); title ('Method #2');
subplot (2,2, 4);imshow (BW2); hold on; viscircles([centrs(row,1), centrs(row,2)],radius,'Color', 'b');hold off; title('Method #3');