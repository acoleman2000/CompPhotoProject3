
% Load In Images
imname1 = "C:\Users\kylev\Desktop\topmid.jpg"
imname2 = "C:\Users\kylev\Desktop\bottom.png"

im1 = im2double(imread(imname1));
im2 = im2double(imread(imname2));


% Rotate Images - (for certain image)
%im1 = imrotate(im1,270);
%im2 = imrotate(im2,270);


% Read in Points 
% Can save points so no need to click everytime.

% Points_1

%Read in points:
%points_1 = readPoints(im1,4);
%Couch:
%points_1 = [1.689500000000000e+03,1.661500000000000e+03;1.647500000000000e+03,6.955000000000000e+02;2.937500000000000e+03,6.295000000000000e+02;2.955500000000000e+03,1.643500000000000e+03];
%Poster:
%points_1 =[6.079999999999999e+02,1.497000000000000e+03;5.929999999999999e+02,276;1.430000000000000e+03,243;1.406000000000000e+03,1.530000000000000e+03];
%Elevator
%points_1 =[7.929999999999997e+02,1.607000000000000e+03;8.009999999999998e+02,426;1.383000000000000e+03,375;1.345000000000000e+03,1.677000000000000e+03];
%slip and fall
%points_1 = [330,1524;329,1638;714,1555;709,1459]
%slip and fall topmid and bot
points_1=[471,1.277000000000000e+03;469,1.376000000000000e+03;8.259999999999999e+02,1.299000000000000e+03;828,1.219000000000000e+03]
% Points_2

%Read in points:
%points_2 = readPoints(im2,4);
%Couch: 
%points_2 = [8.674999999999999e+02,1.793500000000000e+03;8.195000000000001e+02,8.155000000000000e+02;2.097500000000000e+03,8.275000000000000e+02;2.109500000000000e+03,1.817500000000000e+03];
%Poster: 
%points_2 =[2.029999999999999e+02,1.554000000000000e+03;1.249999999999999e+02,282;9.619999999999999e+02,291;9.889999999999997e+02,1.503000000000000e+03];
%Elevator
%points_2=[1.249999999999999e+02,1.635000000000000e+03;1.189999999999999e+02,354;7.039999999999999e+02,393;6.829999999999999e+02,1.599000000000000e+03];
%slip and fall
%points_2 = [167,1276;166,1375;520,1299;521,1219]
%slip and fall topmid and bot
points_2=[56.000000000000010,1242;53,1337;416,1256;417,1176]

% Use SSD to 'fix' points
% For point in nearby 10x10 grid
    % Take SSD
    % if min, adjust point
% Take min point 

% for p = 1:size(points_1,1)
%     lowest_displacement=1000;
%     lowest_x = points_1(p,1);
%     lowest_y = points_1(p,2);
%     % shift image 2 so points_1(p) and points_2(p_ line up 
%     for i=-15:15
%        for j=-15:15
%            fullim1=circshift(fullim1, [i, j]);
%            temp_image1 =fullim1(max(abs(i),1):(size(fullim1,1) - abs(i)), max(abs(j),1):(size(fullim1,2) - abs(j)));
%            temp_image2=fullim2(max(abs(i),1):(size(fullim2,1)- abs(i)), max(abs(j),1):(size(fullim2,2) - abs(j)));
%   
% 
%            displacement = mean2( (temp_image1-temp_image2).^2 );
%            if i == points_1(p,1) && j == points_1(p,2)
%                lowest_displacement = displacement;
%            end 
%             if displacement<lowest_displacement
%                lowest_x=j;
%                lowest_y=i;
%                lowest_displacement=displacement;
%            end
%         end
%     end 
%     lowest_x;
%     lowest_y;
%     points_1(p, 1) = lowest_x + points_1(p,1);
%     points_1(p, 2) = lowest_y + points_1(p,2);
% end

% Compute homography matrix
H = computeH(points_1, points_2);

% Tranform Image
% Save shift
% circshift[newim1, xdata(1), ydata(1)] returns coordinates to default
% position
[newim1, xdata, ydata]= imtransform(im1, H);

% Plot points on shifted image to verify transformation
% imshowpair(circshift(newim1, [round(ydata(1)), round(xdata(1))]), im2, "montage");
% axis on
% hold on 
% points_new = tformfwd(H, points_1);
% for point= 1:size(points_2)
%     plot(points_new(point,1) , points_new(point,2), 'bo', 'MarkerSize', 30, 'LineWidth', 2);
% end
% 
% for point= 1:size(points_1)
%    plot(points_2(point,1) + size(tempim1, 2), points_2(point,2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
% end
%axis off
%hold off
% Shift newim1 by the approriate y amount
newim1 = circshift(newim1, [round(ydata(1)), 0]);
if(ydata(1) > 0)
    newim1 = newim1(abs(round(ydata(1))):(size(newim1,1)), :, :);
else
    newim1 = newim1(1:(size(newim1,1)-abs(round(ydata(1)))), :, :);
end 


% Pad images to be the same size
if size(newim1, 1) < size(im2, 1)
   pad = zeros(size(im2, 1), size(newim1,2));
   pad(1:size(newim1,1), 1: size(newim1,2), 1:3) = newim1;
   newim1 = pad;
end

if size(newim1, 1) > size(im2, 1)
   pad = zeros(size(newim1, 1), size(im2,2));
   pad(1:size(im2,1), 1: size(im2,2), 1:3) = im2;
   im2 = pad;    
end

if size(newim1, 2) < size(im2, 2)
   pad = zeros(size(newim1, 1), size(im2,2));
   pad(1:size(newim1,1), 1: size(newim1,2), 1:3) = newim1;
   newim1 = pad;
end

if size(newim1, 2) > size(im2, 2)
   pad = zeros(size(im2, 1), size(newim1,2));
   pad(1:size(im2,1), 1: size(im2,2), 1:3) = im2;
   im2 = pad;    
end


% Get leftmost point



% Get dimensions for new image
x_dim = abs(round(xdata(1))) + size(im2,2)
y_dim = size(im2, 1)
output_im = zeros(y_dim, x_dim, 3);

%min_point is the leftmost point
min_point = abs(round(xdata(1)));


% Overlap - no blur
% overlap = 200;
% output_im(:, 1 : min_point + overlap, :) = newim1(:, 1 : min_point + overlap, :);
% output_im(:, min_point + overlap + 1: x_dim, :) = im2(:, overlap + 1: size(im2,2), :);


% 50% blur
output_im(:, 1 : min_point, :) = newim1(:, 1 : min_point, :);
output_im(:, min_point + 1: size(newim1, 2), :) = 0.5 * newim1(:, min_point + 1: size(newim1, 2), :) + 0.5 * im2(:,1 : (size(newim1, 2)  - min_point), :);
output_im(:, size(newim1, 2) + 1: x_dim, :) = im2(:, (size(newim1, 2)  - min_point + 1): size(im2,2), :);

% Gradient blur
% Create gradiant
%grad = 1
% grad = linspace(1, 0, size(newim1, 2) -  min_point);
% output_im(:, 1 : min_point, :) = newim1(:, 1 : min_point, :);
% output_im(:, min_point + 1: size(newim1, 2), :) = grad .* newim1(:, min_point + 1: size(newim1, 2), :) + flip(grad) .* im2(:,1 : (size(newim1, 2)  - min_point), :);
% output_im(:, size(newim1, 2) + 1: x_dim, :) = im2(:, (size(newim1, 2)  - min_point + 1): size(im2,2), :);


%Show image
imshow(output_im)
imwrite(output_im,'topmidbot.jpg')
%Show homography - imshowpair(im1,im2,"montage");