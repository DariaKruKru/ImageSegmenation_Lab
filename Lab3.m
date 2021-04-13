%Advanced Image Processing course, Image Segmentation lab
%by Daria Kruzhinskaia

% Lab 3. 

clear all

%% Exercise 1. Obtaining horizontal text lines

% read the image
im = imread ('inclined_paragraph.tif');

% extra. Digits from fotocopy
im2 = imread('inclined_paragraph_fotocop.tif');
im2 = medfilt2(im2);

% Thresholding & segmentation
tresh = graythresh(imcomplement(im)) - 0.07; 
BW = imbinarize (imcomplement(im), tresh);
SE1 = strel('disk', 1);
%figure; imshowpair(BW, im, 'montage');

% merge all digits
SE = strel('diamond', 10);
BW_merge = imdilate(BW, SE);
BW_merge = imfill(BW_merge, 'holes');
%BW_merge = bwareaopen(BW_merge, 200); % uncomment for noisy image
%imshow(BW_merge); hold on;

% find an orientation and rotate lines
RP = regionprops(BW_merge, 'Orientation');
% rotate
Im_correct = imrotate(im, -1  * RP.Orientation); %initial image
BW_correct = imrotate(BW, -1  * RP.Orientation); %binarized image
BW_correct = imopen (BW_correct, SE1);
figure; imshowpair(BW_correct, Im_correct, 'montage');

%save result
imwrite(BW_correct, 'digits.png');
save('digits.mat','BW_correct');

%% Exercise 2. Digits classification

% load the result
digits = imread ('digits.png');

% load('digits.mat');
% digits = BW_correct;

%find digits area
stats = regionprops(digits, 'BoundingBox');
bb = cat(1, stats.BoundingBox);

%extract the features
for i=1:size(bb, 1)
    %get one digit alone and its size
    digit = imcrop(digits,stats(i).BoundingBox);
    [height, width] = size(digit); 
    num =1; %reset number of cell
    
    cell_heigh= floor(height/3);
    cell_wigth=floor(width/3);
    
    %count amount of white pixels in each cell of the grid 3x3
    for m =1:cell_heigh:3*cell_heigh
       for n =1:cell_wigth:3*cell_wigth
            total_white = size(find(digit(m:m+cell_heigh-1, n:n+cell_wigth-1)),1);
            features(i,num) =  total_white; %save white amount in feature vector
            num = num +1; %increment 
       end
    end
end

digit_number = 1; %index of digit type

%create prototypes matrix and test set
for i=1:4:size(features,1)
    digit_features = features(i:i+2,:); %obtain features from digits of the same type from 3 lines
    prototypes(digit_number, :) = mean (digit_features ); %get average values for each digit type
    
    test_features(digit_number, :) =  features(i+3, :);
    
     digit_number = digit_number+1; %increment 
end;

% Classification - function in the end of the script
% row index equal to value of the digit
class = myClassify (test_features(3, :), prototypes);
if  class == 10
    class = 0;
end
class

%% Exercise 3. Speed limit signs

% read the image
limit_im = imread ('veloc2_d.jpg');
%find red color areas
limit_im_seg = limit_im(:,:,1)- max(limit_im(:,:,3), limit_im(:,:,2));
imshow(limit_im_seg);

%segmentation
limit_mask = imbinarize(limit_im_seg, graythresh(limit_im_seg));
[sign_center, radii] = imfindcircles (limit_mask, [20 40]);
%hightlith sign area
imshow (limit_im); hold on;
viscircles(sign_center, radii,'EdgeColor','r'); 

%segment the number in the speed sign
sign = limit_im (sign_center(2)-radii/1.7:sign_center(2)+radii/1.7,    sign_center(1)-radii/1.7:sign_center(1)+radii/1.7,:);
figure, imshow(sign);
%segment the digits in the number
sign = rgb2gray(sign);
sign_BW = imcomplement(imbinarize(sign));
%find digits area
stats_sign = regionprops(sign_BW, 'BoundingBox');
bb_sign = cat(1, stats_sign.BoundingBox);
%because in the corners parts of the circle are located ? we need to delete them
bb_sign = bb_sign(3:4, :);

%drow bounding boxes for each digit
figure; imshow(sign_BW); hold on;
for i=1:size(bb_sign, 1)
    rectangle('Position', bb_sign(i,:), 'EdgeColor', 'red'); 
end;

%extract digits features
for i=1:size(bb_sign, 1)
    %get one digit alone and its size
    digit_sign = imcrop(sign_BW, bb_sign(i,:));
    [height, width] = size(digit_sign); 
    num =1; %reset number of cell
    
    cell_heigh= floor(height/3);
    cell_wigth=floor(width/3);
    
    %count amount of white pixels in each cell of the grid 3x3
    for m =1:cell_heigh:3*cell_heigh
       for n =1:cell_wigth:3*cell_wigth
            total_white = size(find(digit_sign(m:m+cell_heigh-1, n:n+cell_wigth-1)),1);
            features_sign(i,num) =  total_white; %save white amount in feature vector
            num = num +1; %increment 
       end
    end
end

%get speed limit
speed_limit(1) = myClassify (features_sign (1,:), prototypes); % first digit in the sign
speed_limit(2) = myClassify (features_sign (2,:), prototypes); % second digit in the sign
if  speed_limit(2) ==10
    speed_limit(2) = 0;
end
total_speed_limit = 10*speed_limit(1)  + speed_limit(2)

%% external functions

function class = myClassify (character, prototypes)

    %calculate euclidian dist between character and feature vectors from
    %prototype matrix
    Dist = zeros (10, 1);
    Dist = dist (prototypes, character');
    
    %find closes feature vector by minimum distance
    minDist = min (Dist);
    [row col] = find (Dist == minDist);
    class =  row;
    
end
