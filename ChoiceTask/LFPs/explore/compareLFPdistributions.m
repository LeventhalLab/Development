rows = 6;
cols = 5;

iEvent = 4;
refEvent = 8;
iTime = 200;
binEdges = linspace(-3,5,30);
% close all
if false
    h = ff(1200,800);
    for iFreq = 1:30
        subplot(rows,cols,iFreq);
        theseZs = all_Wz_power(:,iEvent,iTime,iFreq);
        theseRefZs = all_Wz_power(:,refEvent,iTime,iFreq);
        histogram(theseRefZs,binEdges);
        hold on;
        histogram(theseZs,binEdges);
        ylim([0 800]);
        title(sprintf('%1.2f Hz',freqList(iFreq)));
        legend('ev1','ev4');
    end
end
if true
    h = ff(1200,800);
    iEvent = 4;
    iFreq = 17;
    useTimes = round(linspace(1,size(all_Wz_power,3),rows*cols));
    timeInSec = linspace(-1,1,rows*cols);
    for iTime = 1:numel(useTimes)
        subplot(rows,cols,iTime);
        theseZs = all_Wz_power(:,iEvent,useTimes(iTime),iFreq);
        theseRefZs = all_Wz_power(:,8,useTimes(iTime),iFreq);
        histogram(theseRefZs,binEdges);
        hold on;
        histogram(theseZs,binEdges);
        ylim([0 800]);
        title(sprintf('%1.2fs %1.2fHz ev%i',timeInSec(iTime),freqList(iFreq),iEvent));
        legend('ev8','ev4');
    end
end