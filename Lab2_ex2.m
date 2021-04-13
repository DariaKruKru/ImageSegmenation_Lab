%Advanced Image Processing course, Image Segmentation lab
%by Daria Kruzhinskaia

% Lab 2. Exercise 2. Size of the myocyte

%% reading image
M = imread('myocyte.tif');

%% Method #1

%binarizing the image using graytresh 
G=graythresh(M);
BW=imbinarize(M, G);
BW=imfill(BW, 'holes');
BW=bwareaopen(BW,10000,4); % function to eleiminate nos requieresd conected components 
se = strel('line',10, 30);
BW=imopen(BW, se);%opening function 

% getting object properties using regionprops function 
STATS=regionprops(BW, 'MajorAxisLength','MinorAxisLength'); 
height=STATS.MajorAxisLength
width=STATS.MinorAxisLength
figure, imshow(BW); title ('Method #1');

%% Method 2

%  Thresholding & segmentation
 tr = graythresh (M) - 0.0075;
 BW = imbinarize (M, tr);
 BW = imfill(BW, 'holes');
 SE = strel ('diamond', 9);
 BW = imopen (BW, SE);
 SE = strel ('diamond', 4);
 BW = imerode (BW, SE);
 
figure; imshowpair(M, BW , 'montage'); title ('Method #2'); 

% Estimate the size of the myocyte: height and width
STATS = regionprops (BW, 'Area','MajorAxisLength','MinorAxisLength');
area = cat(1, STATS.Area);
height = cat(1, STATS.MajorAxisLength);
width = cat(1, STATS.MinorAxisLength);
maxMC = max(area); %find the biggest element
[row, col]= find((area == maxMC)==1);

MCheight = height(row)
MCwidth = width(row)
