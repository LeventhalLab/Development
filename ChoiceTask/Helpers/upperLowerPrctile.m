function upperLower = upperLowerPrctile(data,p)
[N,edges] = histcounts(data,100);
prctileThresh = prctile(N,p);
lowerIdx = find(N > prctileThresh,1,'first');
upperIdx = find(N > prctileThresh,1,'last');
upperLower = [edges(lowerIdx) edges(upperIdx)];