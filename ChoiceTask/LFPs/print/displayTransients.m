savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/transientTiming/betaEventsAtTone';
iEvent = 3;
freqList = logFreqList([3.5 100],30);
sevFile = '';
colors = [jet(51);repmat([1 0 0],[50 1])];
timingField = 'RT';

useEventArr = 'Tone';
if strcmp(useEventArr,'Tone')
    compiled_eventsArr = compiled_eventsArr_Tone;
else
    compiled_eventsArr = compiled_eventsArr_NoseOut;
end

RTs = [];
curWs = [];
locss = {};
trialCount = 0;
iFreq = 16;
for iNeuron = 1:numel(LFPfiles_local)
    % only unique sev files
    if strcmp(sevFile,LFPfiles_local{iNeuron})
        continue;
    end
    disp(num2str(iNeuron));
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);
    curTrials = all_trials{iNeuron};
    [W,freqList,allTimes] = getW(sevFile,curTrials,eventFieldnames,freqList,timingField);

    h = figuree(1400,900);
    refW = squeeze(squeeze(W(1,1:round(size(W,2)/2),:,iFreq)));
    medPower = nanmedian(abs(refW(:)).^2);
    cutoffPower = medPower * 6;
    for iSubplot = 1:4
        maxWs = [];
        for iTrial = 1:size(W,3)
            eventArrCount = trialCount + iTrial;
            curW = decimate(abs(squeeze(squeeze(W(iEvent,:,iTrial,iFreq)))).^2,10);
            maxWs(iTrial) = max(curW);
            [locs,pks] = peakseek(curW,round(size(curW,1)/2/freqList(iFreq)),cutoffPower);
            RTcolor = colors(round(allTimes(iTrial)*100)+1,:);
            subplot(2,2,iSubplot);
            plot3(repmat(iTrial,size(curW)),1:numel(curW),curW,'-','lineWidth',1,'color',RTcolor);
            hold on;
            plot3(repmat(iTrial,size(locs)),locs,curW(locs),'o','MarkerFaceColor',RTcolor,'MarkerSize',7,'MarkerEdgeColor','k');
            if iSubplot == 1
                trialCount = trialCount + 1;
                RTs(trialCount) = allTimes(iTrial);
                curWs(trialCount,:) = curW;
                locss{trialCount} = locs;
            end
%             eventArr_meta{iFreq,eventArrCount} = [(locs/numel(curW)*2) - 1;pks/cutoffPower];
        end
% %         figure;waterfall(1:numel(curW),1:size(W,3),abs(squeeze(squeeze(W(iEvent,:,:,iFreq)))).^2');
        xlabel('trial');
        xlim([1 size(W,3)]);
        xticks(xlim);
        set(gca,'XDir','reverse');
        ylim(size(curW));
        yticks([1 round(numel(curW)/2) numel(curW)]);
        yticklabels({'-1','0','1'});
        ylabel('time (s)');
        sorted_maxWs = sort(maxWs);
        zlim([0 median(sorted_maxWs(end-5:end))+cutoffPower]);
        zticks(zlim);
        zlabel('power');
        grid on;
        cb = colorbar;
        colormap(jet);
        caxis([0 0.5]);
        set(cb,'YTick',caxis);
        ylabel(cb,timingField);
        view(views(iSubplot,:));
        if iSubplot == 1
            title({[num2str(iNeuron,'%03d'),': ',name],[num2str(freqList(iFreq),'%2.1f'),' Hz, ',timingField,' at ',useEventArr]},'interpreter','none');
        else
            title({'',[num2str(freqList(iFreq),'%2.1f'),' Hz, ',timingField,' at ',useEventArr]});
        end
        set(gcf,'color','w');
        box on;
    end
    saveas(h,fullfile(savePath,[num2str(iNeuron,'%03d'),'.png']));
    close(h);
end

% plots
views = [61,78;90 0;90 90;180 0];
figuree(400,900);
[sortedRTs,k] = sort(RTs);
sorted_curWs = curWs(k,:);
sorted_locss = locss(k);
imagesc(sorted_curWs);

iEvent = 3;
freqList = logFreqList([3.5 100],30);
sevFile = '';
colors = [jet(51);repmat([1 0 0],[50 1])];
timingField = 'RT';

useEventArr = 'Tone';

x = [];
y = [];
for iTrial = 1:numel(k)
    x = [x (sorted_locss{iTrial}/numel(curW)*2)-1];
    y = [y repmat(iTrial,[1,numel(sorted_locss{iTrial})])];
end
figuree(400,900);
subplot(211);
plot(x,y,'k.');
xlim([-1 1]);
xticks(sort([xlim 0]));
xlabel('time (s)');
ylim([1 numel(k)]);
yticks(ylim);
ylabel('wire-trials');
title([num2str(freqList(iFreq),'%2.1f'),' Hz, ',timingField,' at ',useEventArr]);
grid on;
set(gca,'YDir','reverse');

subplot(212);
nBins = 10;
nSmooth = 3;
colors = cool(nBins);
binIdxs = floor(linspace(1,numel(k),nBins+1));
binEdges = linspace(-1,1,61);
for iBin = 1:nBins
%     binLocs = ([sorted_locss{binIds(iBin):binIds(iBin+1)}] / numel(curW)*2) - 1;
    binLocs = x(find(y >= binIdxs(iBin) & y < binIdxs(iBin+1)));
    binCounts = smooth(histcounts(binLocs,binEdges),nSmooth);
    plot(linspace(-1,1,numel(binEdges)-1),binCounts,'-','linewidth',2,'color',colors(iBin,:));
    hold on;
end
xlim([-1 1]);
xticks(sort([xlim 0]));
xlabel('time (s)');
yticks(ylim);
ylabel('count');
grid on;