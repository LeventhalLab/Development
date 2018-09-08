doSetup = true;
doTiming = 'RT';

doPlot1 = true;
doPlot2 = false;
doSave = false;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/wholeSession/spikePhaseDeltaRT';

tWindow = 1;
% % freqList = [1.8 20]; % wavelet method
freqList = {[1 3;13 30]}; % hilbert method
if strcmp(doTiming,'RT')
    iEvent = 3;
    caxisVals = [0.1 0.3];
else
    iEvent = 5;
    caxisVals = [0.2 0.4];
end

if doSetup
    n_timePoints = 101;
    phaseCorr = [];
    phaseCorrs_delta = [];
    phaseCorrs_beta = [];
    betaCorrs = [];
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
        phaseCorrs_delta = [phaseCorrs_delta;squeeze(angle(W(iEvent,tIdxs,:,1)))'];
        betaZ = (squeeze(abs(W(iEvent,tIdxs,:,2)).^2) - mean(mean(squeeze(abs(W(1,:,:,2)).^2)))) ./ mean(std(squeeze(abs(W(1,:,:,2)).^2)));
        phaseCorrs_beta = [phaseCorrs_beta;betaZ'];
% %         betaCorrs = [betaCorrs;squeeze(abs(W(4,tIdxs,:,2)).^2)'];      
% %         t0 = round(size(W,2)/2);
% %         phaseCorr = [phaseCorr;squeeze(angle(W(iEvent,t0,:)))];
        all_Times = [all_Times;allTimes'];
    end
end

if false
    figure;
    imagesc(angle(squeeze(W(3,:,:,1)))');
    colormap(cmap_phase);
end

cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
cmap = mycmap(cmapPath,n_timePoints);
rows = ceil(sqrt(n_timePoints));
rows = 5;
cols = rows;
nBins = 24;


binEdges = linspace(-pi,pi,nBins+1);
binCenters = linspace(-pi,pi,nBins);
binEdges = linspace(-1,5,nBins+1);
binCenters = linspace(-1,5,nBins);

timeCenters = linspace(-1,1,n_timePoints);
iSubplot = 1;
if doPlot1
    h = figuree(900,800);
end
all_meanTimes = [];
all_pvals = [];
all_rhos = [];

% useRange = 31:55;
useRange = round(linspace(30,90,25));

timeLabels = {};
for ii = useRange%n_timePoints % !! CHANGE BACK
    phaseCorr = phaseCorrs_beta(:,ii);
    meanTimes = [];
    stdTimes = [];
    
    for iBin = 1:nBins
        theseTimes = all_Times(phaseCorr >= binEdges(iBin) & phaseCorr < binEdges(iBin+1));
        meanTimes(iBin) = mean(theseTimes);
        stdTimes(iBin) = std(theseTimes);
    end
    [rho,pval] = circ_corrcl(phaseCorr,all_Times);
    all_pvals(iSubplot) = pval;
    all_rhos(iSubplot) = rho;
    
    all_meanTimes(ii,:) = meanTimes;
    if doPlot1
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
if doPlot1
    set(gcf,'color','w');
    
    figure;
    yyaxis left;
    plot(all_rhos);
    xticks(1:numel(all_rhos));
    xticklabels(timeLabels);
    xtickangle(45);
    ylim([0 0.5]);
    yticks(ylim);
    ylabel('rho');
    yyaxis right;
    plot(all_pvals);
    ylim([0 0.1]);
    yticks(ylim);
    ylabel('pval');
    
    if doSave
        saveFile = ['delta',doTiming,'corrSubplots_',eventFieldnames{iEvent},'.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
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