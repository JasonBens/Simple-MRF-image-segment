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

diary('output.txt');

% Definitions
% TODO: Put this in a function definition
numIter = 150;
numLabel = 3;

% Load image
% TODO:
%  - If greyscale, create 1-column feature vector.  If RGB, convert to HSV
%    and create 3-column feature matrix
image = imread('test1.png');
[row, col, feat] = size(image);
%if size(image, 3) == 3
%  image = rgb2gray(image);
%end
image = double(image);

% Bin mean standard deviation of each feature to initialize class labels
[~, ix] = sort(mean(zscore(reshape(image, [], feat), 0, 1), 2));
bin = round(linspace(1, numel(ix), numLabel + 1));

label = zeros(size(ix));
for i = 1:numLabel
  %index = bin(i) <= ix & ix <= bin(i+1);
  label(ix(bin(i):bin(i+1))) = i;
end


% Configure simulated annealing options
saopt = saoptimset('TemperatureFcn', @temperaturefcn, ...
                   'AnnealingFcn', @(o, p) annealingfcn(o, p, numLabel), ...
                   'ReannealInterval', 2000, ...
                   'StallIterLimit', 1000, ...
                   'Display', 'iter', ...
                   'OutputFcns', @(o, p, f) outputfcn(o, p, f, row, col) ...
                   );

convergenceTest = zeros(1, numIter);
for iter = 1:numIter
  
  % E-STEP
  % TODO:
  %  - Vectorize this
  %  - Handle all features.
  for m = numLabel:-1:1
    pd{m} = fitdist(image(label == m), 'Normal');
  end
    
  % M-STEP
  
  % This is an ugly workaround to clear the peristent variables in
  % objectivefcn, which shouldn't be hanging around between iterations.
  objectivefcn();
  
  % Update objective function with new alpha every iteration.
  objectiveE = @(x) objectivefcn(x, image, pd, iter);
  
  [label, E] = simulannealbnd(objectiveE, label, [], [], ...
                              saopt);
  imwrite(uint8(reshape(label, row, col) * 255 / max(label)), ...
          sprintf('iter%d.png', iter));

  convergenceTest(iter) = E(1);
  if iter >= 3 && std(convergenceTest(iter-2:iter)) / convergenceTest(iter)<0.0001
      fprintf('Labels have convergerged: %d\n', iter);
      %break;
  end
  
end

diary off
