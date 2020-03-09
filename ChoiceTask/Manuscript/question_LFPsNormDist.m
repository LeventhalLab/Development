% load('session_20191124.mat'); % all_Wz_power: trials (2243), events (8), time (400), freq (30)

iEvent = 4;
iTime = 200;
freqList = logFreqList([1 200],30);
useFreqs = [6,14,16,19,23,25];

close all
h = ff(1200,600);
rows = 2;
cols = 6;
nFreq = 0;
for iFreq = useFreqs
    nFreq = nFreq + 1;
    
    subplot(rows,cols,prc(cols,[1,nFreq]));
    theseTrials = sort(squeeze(all_Wz_power(:,iEvent,iTime,iFreq)));
    useTrials = rmoutliers(theseTrials);
    histogram(normalize(useTrials),100,'FaceColor','k');
    xlabel('Z');
    ylabel('count');
    title(sprintf('f = %1.2fHz',freqList(iFreq)));
    
    subplot(rows,cols,prc(cols,[2,nFreq]));
    F = fitmethis(normalize(useTrials),'pdist',4);
    [h,p] = adtest(useTrials);
    title(sprintf('%1.0f %1.2f',h,p));
end