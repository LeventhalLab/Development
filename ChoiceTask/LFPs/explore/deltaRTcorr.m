doSetup = true;
doPlot1 = false;
doPlot2 = true;
doSave = false;
doDebug = false;

doTiming = 'RT';

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikePhaseDeltaRT';

tWindow = 1;
% freqList = {[1 4]}; % hilbert method
freqList = [1.8];
if strcmp(doTiming,'RT')
    plot1Event = 3;
    caxisVals = [0.1 0.3];
else
    plot1Event = 5;
    caxisVals = [0.2 0.4];
end

if doSetup
    n_timePoints = 1001;
    all_Times = [];
    phaseCorrs_delta = {};
    iSession = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(num2str(iSession));
        sevFile = LFPfiles_local{iNeuron};
        [~,name,~] = fileparts(sevFile);
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        curTrials = all_trials{iNeuron};

        [trialIds,allTimes] = sortTrialsBy(curTrials,doTiming);
        W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        
        if doDebug
            figure;
            imagesc(angle(squeeze(W(3,:,:)))');
            phaseMap = cmocean('phase');
            colormap(gca,phaseMap);
        end
        
        tIdxs = floor(linspace(1,size(W,2),n_timePoints));
        for iEvent = 1:7
            if iNeuron == 1
                phaseCorrs_delta{iEvent} = [];
            end
            phaseCorrs_delta{iEvent} = [phaseCorrs_delta{iEvent};squeeze(angle(W(iEvent,tIdxs,:)))'];
        end
        all_Times = [all_Times;allTimes'];
    end
end

cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
cmap = mycmap(cmapPath,n_timePoints);
nBins = 24;

binEdges = linspace(-pi,pi,nBins+1);
binCenters = linspace(-pi,pi,nBins);

timeCenters = linspace(-tWindow,tWindow,n_timePoints);
iSubplot = 1;

if doPlot1
    h = figuree(900,800);
    timeLabels = {};
    plot1Range = floor(linspace(450,550,36));
    all_pvals = [];
    all_rhos = [];
    rows = ceil(sqrt(numel(plot1Range)));
    cols = rows;
end

all_meanTimes = {};
for iEvent = 1:7
    event_meanTimes = [];
    for ii = 1:n_timePoints
        phaseCorr = phaseCorrs_delta{iEvent}(:,ii);
        meanTimes = [];
        stdTimes = [];
        for iBin = 1:nBins
            theseTimes = all_Times(phaseCorr >= binEdges(iBin) & phaseCorr < binEdges(iBin+1));
            meanTimes(iBin) = mean(theseTimes);
            stdTimes(iBin) = std(theseTimes);
        end
        [rho,pval] = circ_corrcl(phaseCorr,all_Times);
        event_meanTimes(ii,:) = meanTimes;
        
        all_pvals(iEvent,ii) = pval;
        all_rhos(iEvent,ii) = rho;
        if iEvent == plot1Event && doPlot1 && ismember(ii,plot1Range)
            subplot(rows,cols,iSubplot);
            % STD
            for iBin = 1:nBins
                plot([meanTimes(iBin)-stdTimes(iBin) meanTimes(iBin)+stdTimes(iBin)],[binCenters(iBin) binCenters(iBin)],'-','color',repmat(0.8,[1,3]));
                hold on;
            end
            plot(meanTimes,binCenters,'k-','lineWidth',2);
            hold on;
            plot(meanTimes,binCenters,'ko');
            xticks([0.1:0.1:0.4]);
            xlabel([doTiming,' (s)']);
            yticks(binCenters);
            yticklabels(num2str(binCenters(:),'%1.2f'));
            ylabel('delta phase');
            timeLabels{iSubplot} = num2str(timeCenters(ii),'%1.2f');
            title({['t = ',timeLabels{iSubplot}],['p = ',num2str(pval),', rho = ',num2str(rho,2)]});
            iSubplot = iSubplot + 1;
        end
    end
    all_meanTimes{iEvent} = event_meanTimes;
end

if doPlot1 % companion
    ff(600,300);
    subplot(121);
    plot(timeCenters,all_pvals(plot1Event,:));
    ylim([0 0.05]);
    xlabel('time (s)');
    title('pval');
    subplot(122);
    plot(timeCenters,all_rhos(plot1Event,:));
    ylim([0 0.5]);
    xlabel('time (s)');
    title('rho');
end

if doPlot2
    h = figuree(1400,200);
    for iEvent = 1:7
        subplot(1,7,iEvent);
        imagesc(all_meanTimes{iEvent}');
        colormap(gca,cmap);
        xticks([1 round(n_timePoints/2) n_timePoints]);
        xticklabels({'-1','0','1'});
        xlabel('Time (s)');
        yticks([1 ceil(nBins/2) nBins]);
        yticklabels({'\pi','0','-\pi'});
        title({eventFieldnames{iEvent},'\delta phase'});
        caxis(caxisVals);
        if iEvent == 7
            cbAside(gca,['mean ',doTiming],'k');
        end
        grid on;

        [maxTime,maxIndex] = max(all_meanTimes{iEvent}(:));
        [row_maxTime,col_maxTime] = ind2sub(size(all_meanTimes{iEvent}),maxIndex);
        [minTime,minIndex] = min(all_meanTimes{iEvent}(:));
        [row_minTime,col_minTime] = ind2sub(size(all_meanTimes{iEvent}),minIndex);

        if false
            hold on;
            plot(row_minTime,col_minTime,'wo','markerSize',10);
            text(row_minTime,col_minTime,['  min',doTiming],'color','w');
            plot(row_maxTime,col_maxTime,'wo','markerSize',10);
            text(row_maxTime,col_maxTime,['  max',doTiming],'color','w');
        end
    end
    set(gcf,'color','w');
    if doSave
        saveFile = ['delta',doTiming,'corrMatrix_allEvents_HILBERT.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end