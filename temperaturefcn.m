function temperature = temperaturefcn(optimValues, ~)

  % From Equation 10 (Page 2326)
  C = 2; % As per Section 4.1, Page 2327
  temperature = C / log(optimValues.iteration + 1);

end
