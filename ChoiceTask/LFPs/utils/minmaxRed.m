function minmaxVals = minmaxRed(data)
% min and max by reducing data dimensions
% can be used to set caxis
minRed = min(data);
maxRed = max(data);
while max(size(minRed)) > 1
    minRed = min(minRed);
    maxRed = max(maxRed);
end
minmaxVals = [minRed maxRed];