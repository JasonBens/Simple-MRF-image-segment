function [stop, options, optchanged] = outputfcn(options, optimvalues, ~, row, col)
  imshow(uint8(reshape(optimvalues.x, row, col) * 255/max(optimvalues.x)))
  drawnow;
  
  stop = false;
  optchanged = false;
  
end