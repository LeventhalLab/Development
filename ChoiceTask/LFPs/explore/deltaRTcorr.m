doSetup = true;
doTiming = 'RT';

tWindow = 1;
freqList = [1.8];
if strcmp(doTiming,'RT')
    iEvent = 3;
    caxisVals = [0.1 0.3];
else
    iEvent = 5;
    caxisVals = [0.2 0.4];
end
n_timePoints = 101;

if doSetup
    phaseCorr = [];
    phaseCorrs = [];
    all_Times = [];
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(num2str(iNeuron));
        sevFile = LFPfiles_local{iNeuron};
        [~,name,~] = fileparts(sevFile);
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
        curTrials = all_trials{iNeuron};

        [trialIds,allTimes] = sortTrialsBy(curTrials,doTiming);
        W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        
        tIdxs = floor(linspace(1,size(W,2),n_timePoints));
        phaseCorrs = [phaseCorrs;squeeze(angle(W(iEvent,tIdxs,:)))'];
        
        t0 = round(size(W,2)/2);
        phaseCorr = [phaseCorr;squeeze(angle(W(iEvent,t0,:)))];
        all_Times = [all_Times;allTimes'];
    end
end

doPlot1 = false;
doPlot2 = true;
doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikePhaseDeltaRT';
cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
cmap = mycmap(cmapPath,n_timePoints);
rows = ceil(sqrt(n_timePoints));
cols = rows;
nBins = 24;
binEdges = linspace(-pi,pi,nBins+1);
binCenters = linspace(-pi,pi,nBins);
timeCenters = linspace(-1,1,n_timePoints);
if doPlot1
    h = figuree(900,800);
end
all_meanTimes = [];
for ii = 1:n_timePoints
    phaseCorr = phaseCorrs(:,ii);
    meanTimes = [];
    stdTimes = [];
    for iBin = 1:nBins
        theseTimes = all_Times(phaseCorr >= binEdges(iBin) & phaseCorr < binEdges(iBin+1));
        meanTimes(iBin) = mean(theseTimes);
        stdTimes(iBin) = std(theseTimes);
    end
    all_meanTimes(ii,:) = meanTimes;
    if doPlot1
        subplot(rows,cols,ii);
        % STD
        for iBin = 1:nBins
            plot([meanTimes(iBin)-stdTimes(iBin) meanTimes(iBin)+stdTimes(iBin)],[binCenters(iBin) binCenters(iBin)],'-','color',repmat(0.8,[1,3]));
            hold on;
        end
        plot(meanTimes,binCenters,'-','lineWidth',2,'color',cmap(ii,:));
        hold on;
        plot(meanTimes,binCenters,'o','color',cmap(ii,:));
        xticks([0.1:0.1:0.4]);
        xlabel([doTiming,' (s)']);
        yticks(binCenters);
        yticklabels(num2str(binCenters(:),'%1.2f'));
        ylabel('delta phase');
        title(['t = ',num2str(timeCenters(ii),'%1.2f')]);
    end
end

if doPlot2
    h = figuree(400,150);
    imagesc(all_meanTimes');
    colormap(gca,cmap);
    xticks([1 round(n_timePoints/2) n_timePoints]);
    xticklabels({'-1','0','1'});
    xlabel('Time (s)');
    yticks([1 ceil(nBins/2) nBins]);
    yticklabels({'\pi','0','-\pi'});
    title(['Delta Phase at ',eventFieldnames{iEvent}]);
    caxis(caxisVals);
    cbAside(gca,['mean ',doTiming],'k');
    grid on;

    [maxTime,maxIndex] = max(all_meanTimes(:));
    [row_maxTime,col_maxTime] = ind2sub(size(all_meanTimes),maxIndex);
    [minTime,minIndex] = min(all_meanTimes(:));
    [row_minTime,col_minTime] = ind2sub(size(all_meanTimes),minIndex);

    hold on;
    plot(row_minTime,col_minTime,'wo','markerSize',10);
    text(row_minTime,col_minTime,['  min',doTiming],'color','w');
    plot(row_maxTime,col_maxTime,'wo','markerSize',10);
    text(row_maxTime,col_maxTime,['  max',doTiming],'color','w');
    set(gcf,'color','w');
    if doSave
        saveFile = ['delta',doTiming,'corrMatrix_',eventFieldnames{iEvent},'.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end