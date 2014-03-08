function newLabel = annealingfcn(optimValues, problem, numLabel)
  
  % Annealing scheme is similar to annealingfast, where the number of
  % updated labels is proportional to the current temperature.
  
  newLabel = optimValues.x;
  
  initPercent = 1;
  numUpdate = max(1, ...
    round(problem.nvar / (initPercent * (optimValues.iteration + 1))));

  %numUpdate = 1;
  
  update = randi(problem.nvar, numUpdate, 1);
  offset = randi(numLabel - 1, numUpdate, 1) - 1;
  newLabel(update) = 1 + mod(newLabel(update) + offset, numLabel);
    
end
