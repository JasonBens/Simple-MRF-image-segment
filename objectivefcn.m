function E = objectivefcn(label, image, pd, iter)

  [row, col, numFeat] = size(image);  
  
  % From Equation 11 (Page 2327)
  c1 = 80;
  c2 = 1 / numFeat;
  alpha = c1*0.9^iter + c2;
  
  % Calculate Region and Feature energy
  Er = regionEnergy(label, row, col);
  Ef = featureEnergy(label, image, pd);
  
  % Total energy
  E = Er + alpha * Ef;
  
end


function Er = regionEnergy(label, row, col)
  
  % From paper (Page 2327)
  beta = 1;

  % Get 8-neighbourhood of element.
  [element, neighbour] = getneighbors(label, row, col);
  
  % Get region energy for each class
  Er = 0;
  for m = 1:numel(unique(label))
    index = (element == m);
    
    % Equation 4 (Page 2325)
    Er = Er + beta * cliquePotential(element(index), neighbour(index));
  end
  
end


function potential = cliquePotential(x, y)
  
  % Pairwise MLL potential energy (Equation 4, Page 2325)
  potential = sum(x ~= y) - sum(x == y);
  
end


function [element, neighbour] = getneighbors(A, row, col)

  paddedA = nan(row + 2, col + 2);
  paddedA(2:row + 1, 2:col + 1) = reshape(A, row, col);
  
  index = repmat(find(~isnan(paddedA))', 8, 1);
  element = paddedA(index(:));
    
  neighbourIndex = [(-1:1) - row - 2, -1, 1, (-1:1) + row+2]';
  index = index + repmat(neighbourIndex, 1, numel(A));
  neighbour = paddedA(index(:));
  
  isValid = ~isnan(neighbour);
  element = element(isValid);
  neighbour = neighbour(isValid);
  
end

function Ef = featureEnergy(label, image, pd)

  % Iterate over all labels
  % Todo: Iterate over all features, too (k superscript in paper)
  Ef = 0;
  for m = 1:numel(pd);
    Ef = Ef + featPotential(image(label == m), pd{m}.mu, pd{m}.sigma);
  end
    
end


function potential = featPotential(image, mu, sigma)

  % Equation 7 (Page 2326) (Second term computed in second step)
  potential = sum((image - mu).^2 / (2 * sigma ^ 2));
  potential = potential + numel(image) * log(sqrt(2 * pi) * sigma);
end