% function tsScaloXcorr(ts,sevFile)
% 
% [sev,header]=read_tdt_sev(sevFile);

upperPrctile = 75;
lowerPrctile = 25;
upperThresh = prctile(s,upperPrctile);
lowerThresh = prctile(s,lowerPrctile);

upperIdx = s > upperThresh;