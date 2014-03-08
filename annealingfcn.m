function annealedLabel = annealingfcn(optimValues, problem, numLabel)
  
  % Annealing scheme is similar to annealingfast, where the number of
  % updated labels is proportional to the current temperature.
  
  initPercent = 1;
  numUpdate = max(1, ...
    round(problem.nvar / (initPercent * (optimValues.iteration + 1))));
  
  %numUpdate = 1;
  
  % TODO:  This can generate the same label, meaning no update.  Set of
  % valid labels should be XOR of current label and all labels.
  updateVect = randi(problem.nvar, numUpdate, 1);
  annealedLabel = optimValues.x;
  annealedLabel(updateVect) = randi(numLabel, numUpdate, 1);
  
end
