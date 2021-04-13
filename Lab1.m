%Advanced Image Processing course, Image Segmentation lab
%by Daria Kruzhinskaia

% Lab 1. Thresholding

%% read the images

im1 = imread ('BB.TIF');
im4 = imread ('CHROMOSO.BMP');
im2 = imread ('CIRCUIT.BMP');
im3 = imread ('TOOLS.BMP');

%% image 1

%get binary image using Otsu
BW1= imbinarize (im1,graythresh(im1));
%fill in the holes
BW1 = imfill(BW1, 'holes');

%Method 1. Morphological
se_m =  strel('disk', 10);
BW1_m = imerode(BW1, se_m);
se_m =  strel('disk', 5);
BW1_m = imdilate(BW1_m, se_m);

%Method 2. Watershed
%calculation of distance transform
D = -bwdist(~BW1);
mask = imextendedmin(D,2);
D2 = imimposemin(D,mask);
D2(~BW1) = -Inf;
%Apply watershed
L = watershed(D2);
BW1(L==0) = 0; 

se = strel('disk', 8);
BW1 = imopen(BW1, se); %delete small pieces of  circles in the frame

%show results
figure;
subplot(1,3, 1); imshow(im1); title('Original');
subplot(1,3,2); imshow(BW1_m); title('Morphological approach');
subplot(1,3,3); imshow(BW1); title('Watershed approach');

% figure; 
% subplot(1,3, 1); imshow(D,[]); title('Distance transform');
% subplot(1,3,2); imshow(L,[]); title('Watershed transform');
% subplot(1,3,3); imshow(BW1); title('Watershed result');

%% image 2

threshold2 = graythresh(im2) - 0.09; %custom value of threshold
BW2_temp = imbinarize (im2, threshold2);
se2 = strel('line', 6 , 90);
BW2 = imerode (BW2_temp, se2); %delete horizontal elements
se2 = strel('square', 3); 
BW2 = imopen (BW2, se2);

BW2 = bwareaopen(BW2, 10); % delete small elements

%show result
figure;
subplot(1,3,1); imshow(im2); title('Original');
subplot(1,3,2); imshow(BW2_temp); title('After thresholding');
subplot(1,3,3); imshow(BW2); title('Final result');

%% image 3

BW3_adapt = imbinarize(im3, adaptthresh(im3));
se3 = strel('disk',20);
temp3 = imtophat (im3, se3); %homogenize the illumination
temp3= im3.*0.1 + temp3.*0.9;
BW3 = imbinarize (temp3, graythresh(temp3));

%show results
figure;
subplot(1,4,1); imshow(im3); title('Original (a)');
subplot(1,4,2); imshow(BW3_adapt); title('After adaptive threshold (b)');
subplot(1,4,3); imshow(temp3); title('After tophat (c)');
subplot(1,4,4); imshow(BW3); title('Final result (d)');

%% image 4

im4filt = medfilt2(im4);

BWedges =  edge(im4filt,'Canny');
threshold4 = graythresh(im4filt) - 0.06;
BW4 = imbinarize (im4filt, threshold4);
se4 = strel('disk', 3);
BW4 = imdilate (BW4, se4);
BW4inv = imcomplement (BW4);
D = -bwdist(~BW4inv );
%Apply watershed
L = watershed(D);
BW4inv(L==0) = 0;

%show results
subplot (2, 2, 1); imshow ( im4filt);
subplot (2, 2, 2); imshow ( BW4);
subplot (2, 2, 3); imshow (BW4inv );
subplot (2, 2, 4); imshow ( BWedges);
