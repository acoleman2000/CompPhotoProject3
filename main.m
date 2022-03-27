
% Load in images
imname1 = "C:\Users\alexc\Downloads\poster1.jpg"
imname2 = "C:\Users\alexc\Downloads\poster2.jpg"

im1 = im2double(imread(imname1));
%im1 = imrotate(im1,270);
im2 = im2double(imread(imname2));
%im2 = imrotate(im2,270);


% Read points (can save points so no need to click everytime).
% points_1 = readPoints(im1,4)
%Couch:
%points_1 = [1.689500000000000e+03,1.661500000000000e+03;1.647500000000000e+03,6.955000000000000e+02;2.937500000000000e+03,6.295000000000000e+02;2.955500000000000e+03,1.643500000000000e+03];
%Poster:
points_1 = [6.079999999999999e+02,1.497000000000000e+03;5.929999999999999e+02,276;1.430000000000000e+03,243;1.406000000000000e+03,1.530000000000000e+03]

%points_2 = readPoints(im2,4)
%Couch: 
%points_1 = [8.674999999999999e+02,1.793500000000000e+03;8.195000000000001e+02,8.155000000000000e+02;2.097500000000000e+03,8.275000000000000e+02;2.109500000000000e+03,1.817500000000000e+03];
%Poster: 
points_2 = [2.029999999999999e+02,1.554000000000000e+03;1.249999999999999e+02,282;9.619999999999999e+02,291;9.889999999999997e+02,1.503000000000000e+03]

% Use SSD to 'fix' points
% For point in nearby 10x10 grid
    % Take SSD
    % if min, ajust point
% Take min point 
for p = 1:size(points_1,1)
   lowest_displacement=1000;
   lowest_x = points_1(p,1);
    lowest_y = points_1(p,2);
    % shift image 2 so points_1(p) and points_2(p_ line up 
    x_shift = round(points_1(p,2) - points_2(p,2));
    y_shift = round(points_1(p,1) - points_2(p,1));
    fullim1 = circshift(im1, [x_shift, y_shift]);
    fullim1 =fullim1(max(abs(x_shift),1):(size(fullim1,1) - abs(x_shift)), max(abs(y_shift),1):(size(fullim1,2) - abs(y_shift)));
    fullim2 =im2(max(abs(x_shift),1):(size(im2,1)- abs(x_shift)), max(abs(y_shift),1):(size(im2,2) - abs(y_shift)));
    for i=-5:5
       for j=-5:5
           fullim1=circshift(fullim1, [i, j]);
           temp_image1 =fullim1(max(abs(i),1):(size(fullim1,1) - abs(i)), max(abs(j),1):(size(fullim1,2) - abs(j)));
           temp_image2=fullim2(max(abs(i),1):(size(fullim2,1)- abs(i)), max(abs(j),1):(size(fullim2,2) - abs(j)));
           displacement = mean2( (temp_image1-temp_image2).^2 );
           if i == points_1(p,1) && j == points_1(p,2)
               lowest_displacement = displacement;
           end 
            if displacement<lowest_displacement
               lowest_x=j;
               lowest_y=i;
               lowest_displacement=displacement;
           end
        end
    end 
    lowest_x;
    lowest_y;
    points_1(p, 1) = lowest_x + points_1(p,1);
    points_1(p, 2) = lowest_y + points_1(p,2);
end

% Compute homography
H = computeH(points_1, points_2);
% Tranform image
im1 = imtransform(im1, H, "XYScale", 1);

% Get leftmost point
min_point = points_1(1,1);
min_index = 1;
for x = 2:size(points_1)
    if(points_1(x, 1) < min_point)
        min_point = points_1(x,1);
        min_index = x;
    end 
end 

% imshowpair(im1, im2, "montage");
% axis on
% hold on 
% points_new = tformfwd(H, points_1);
% for point= 1:size(points_1)
%     plot(points_new(point,1) , points_new(point,2), 'bo', 'MarkerSize', 30, 'LineWidth', 2);
% end
% 
% for point= 1:size(points_1)
%     plot(points_2(point,1) + size(im1, 2), points_2(point,2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
% end
im1 = circshift(im1, [-80, 0]);
% Pad images to be the same size
if size(im1, 1) < size(im2, 1)
   pad = zeros(size(im2, 1), size(im1,2));
   pad(1:size(im1,1), 1: size(im1,2), 1:3) = im1;
   im1 = pad;
end

if size(im1, 1) > size(im2, 1)
   pad = zeros(size(im1, 1), size(im2,2));
   pad(1:size(im2,1), 1: size(im2,2), 1:3) = im2;
   im2 = pad;    
end

if size(im1, 2) < size(im2, 2)
   pad = zeros(size(im1, 1), size(im2,2));
   pad(1:size(im1,1), 1: size(im1,2), 1:3) = im1;
   im1 = pad;
end

if size(im1, 2) > size(im2, 2)
   pad = zeros(size(im2, 1), size(im1,2));
   pad(1:size(im2,1), 1: size(im2,2), 1:3) = im2;
   im2 = pad;    
end

% Get dimensions for new image
x_dim = min_point + size(im2,2)
y_dim = size(im2, 1)
new_im = zeros(y_dim, x_dim, 3);

% Set 0 - min_point to be from image 1, and min_point - size to be from
% image 2. Pick arbitrary overlap

% TODO - replace with blurring
overlap = 300;
min_point = min_point + overlap;
new_im(:, 1 : min_point, :) = im1(:, 1 : min_point, :);
new_im(:, min_point + 1: x_dim, :) = im2(:, overlap + 1 : size(im2,2), :);

%Show image
imshow(new_im)
%Show homography - imshowpair(im1,im2,"montage");