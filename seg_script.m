% Notes on the paper:
% m subscript denotes m-th class
%  - this must be specified
%
% k subscript denotes k-th feature component
%  - For greyscale, k = 1
%  - Other features: Gabor wavelets, HSV, texture
% 
% beta denotes an a priori value to determine the image region energy
%  - Set to one in the paper, as only the ratio of alpha to beta is
%    important
%
% alpha denotes an a priori value to determine the image feature energy
%  - empirically set as a(t) = c1*0.9^t + c(2)
%  - c1 empirically set as 80
%  - c2 empirically set as 1 / number of features
%
%

num_iterations = 150;
num_classes = 3;

% TODO:
%  - If greyscale, create 1-column feature vector.  If RGB, convert to HSV
%    and create 3-column feature matrix
image = imread('test1.png');
features = reshape(image, [], 1);
[num_pixels, num_features] = size(features);
label = randi(num_classes, num_pixels, 1);

% From paper (Page 2327)
beta = 1;

% From Equation 11 (Page 2327)
c1 = 80;
c2 = 1 / num_features;
alpha = @(t) c1*0.9^t + c2;

% From Equation 10 (Page 2326)
C = 2; % As per Section 4.1, Page 2327
temp = @(t) C / log(t + 1);

for i = 1:num_iterations
  
  % E-STEP
  % TODO:
  %  - Vectorize this
  for m = 1:num_classes
    class_index = (label == m);
    est_mean = mean(features(class_index, :), 1);
    est_std = std(features(class_index, :), 0, 1);
  end
    
  % M-STEP
  
end
  