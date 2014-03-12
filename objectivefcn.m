function E = objectivefcn(label, image, pd, iter)

  % This is a nasty workaround, since simulannealbnd wasn't intended to
  % iteratively calculate objective functions, and MATLAB still doesn't
  % implement pointers (It's only been thirty years, guys)
  persistent state 
    
  % Reinitialize if no arguments in
  if nargin == 0
    state = struct('lastE', [], ...
                   'lastAcceptedE', [], ... 
                   'lastLabel', [], ...
                   'lastAcceptedLabel', [], ...
                   'lastMod', [], ...
                   'firstRun', []);
    
    regionEnergy();
    return;
  end
  
  % If first run, calculate energy of all pixels.  Else, only calculate
  % energy delta of updated pixels.
  if isempty(state.firstRun)

    % Initialize the things that need initializing.
    state.lastAcceptedE = 0;
    state.lastAcceptedLabel = zeros(size(label));
  else
    
    % Check if last change was accepted.  If accepted, update lastAccepted
    % with lastE (Energy after last change).  Else, keep lastAccepted.
    if all(label(state.lastMod) == state.lastLabel(state.lastMod))
      state.lastAcceptedE = state.lastE;
      state.lastAcceptedLabel = state.lastLabel;
    end
  end
  
  % Scan for new modified labels and preserve
  modIndex = find(label ~= state.lastAcceptedLabel);
  % END 1337HAX0RZ
  
  [row, col, numFeat] = size(image);  
  
  % From Equation 11 (Page 2327)
  c1 = 80;
  c2 = 1 / numFeat;
  alpha = c1*0.9^iter + c2;
  
  % Calculate Region and Feature energy
  if isempty(state.firstRun)
    delEr = regionEnergy(label, modIndex, row, col);
    delEf = featureEnergy(image(modIndex), label(modIndex), pd);
  else
    oldEr = regionEnergy(state.lastAcceptedLabel, modIndex, row, col);
    newEr = regionEnergy(label, modIndex, row, col);
    delEr = newEr - oldEr;
    
    oldEf = featureEnergy(image(modIndex), ...
                          state.lastAcceptedLabel(modIndex), pd);
    newEf = featureEnergy(image(modIndex), label(modIndex), pd);
    delEf = newEf - oldEf;
  end
  
  % Total energy
  delE = delEr + alpha * delEf;
  
  % Apply delta.  If first run, take delta as baseline
  if isempty(state.firstRun)
    E = delE;
    state.lastAcceptedE = E;
    state.lastAcceptedLabel = label;
  else
    E = state.lastAcceptedE + delE;
  end
  
  % Store persistent variables
  state.lastE = E;
  state.lastMod = modIndex;
  state.lastLabel = label;
  state.firstRun = false;
  
end


function delEr = regionEnergy(label, index, row, col)
  
  persistent nhood
  
  % Reinitialize if no arguments in
  if nargin == 0
    nhood = [];
    return;
  end
  
  % Cache neighbourhood, since it doesn't change.
  if isempty(nhood)
    nhood = getneighbourhood(row, col);
  end
  
  % From paper (Page 2327)
  beta = 1;

  % Get region energy for each class
  delEr = 0;
  for m = 1:numel(index)
    
    % Remove duplicate pairs
    clique = label(nhood{index(m)});
    clique = clique(~isnan(clique));
    
    potential = cliquePotential(label(index(m)), clique);
    
    % Equation 4 (Page 2325)
    delEr = delEr + beta * potential;
    
    % Mark current label as NaN to avoid using in neighbouring clique
    % potential calculations.
    label(index(m)) = NaN;
  end
  
end


function potential = cliquePotential(x, y)
  
  % Pairwise MLL potential energy (Equation 4, Page 2325
  % Multiply by two to account for bidirectional pairs.
  potential = sum(x ~= y) - sum(x == y);
  
end


function nhood = getneighbourhood(row, col)

  % Zero-pad an index matrix to handle edge conditions.
  paddedA = zeros(row + 2, col + 2);
  paddedA(2:row + 1, 2:col + 1) = reshape(1:row*col, row, col);
  
  % Create matrix of indices containing neighbourhood.
  index = repmat(find(paddedA ~= 0)', 8, 1);
  nhoodOffset = [(-1:1) - row - 2, -1, 1, (-1:1) + row+2]';
  index = index + repmat(nhoodOffset, 1, row * col);
  
  % Convert neighbourhood to cell and remove all padded zeros.
  nhood = num2cell(index', 2);
  nhood = cellfun(@(x) paddedA(x(paddedA(x) ~= 0)), nhood, ...
                  'UniformOutput', false);
                
end


function Ef = featureEnergy(image, label, pd)

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