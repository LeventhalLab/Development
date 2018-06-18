% beta, gamma X tone, nose out X RT, MT X medcutoffs
% compare medcutoff to mean power at 10x intervals
% W_power(iFreq,iEvent,trialCount,:)
% W_phase(iFreq,iEvent,trialCount,:)
% W_timing{loopCount} = [allTimes;allTrialIds];
% W_median(loopCount,iFreq)
% W_key(trialCount(iFreq,iEvent),:) = [iNeuron,loopCount];
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/transientTiming/DecileTransientsRTMT';
freqList = [3.5,8,12,20,50,80,100];
RTMTlabels = {'RT','MT'};
testMedians = [6,10];
useEvents = [3,4];
rows = numel(testMedians) + 1;
cols = 4;
t = linspace(-1,1,size(W_power,4));

W_timing_flat = [W_timing{:}];
[RT_sorted,RT_key] = sort(W_timing_flat(1,:));

MT_flat = [];
for iTiming = 1:numel(W_timing)
    curTiming = W_timing{iTiming};
    for iTrial = 1:size(curTiming,2)
        MT_flat = [MT_flat curTiming(2,(ismember(curTiming(4,:),curTiming(3,iTrial)) == 1))];
    end
end
[MT_sorted,MT_key] = sort(MT_flat(RT_key));
sortKeys = [RT_key;MT_key];
sortTimes = [RT_sorted;MT_sorted];

nBins = 10;
binIdxs = floor(linspace(1,size(W_power,3),nBins+1));
sortByColors = cool(nBins);
lineWidth = 2;
phaseColors = cmocean('phase',361);

for iFreq = 1:numel(freqList)
    for iSortby = 1:2
        if iSortby == 1
            sortByColors = cool(nBins);
        else
            sortByColors = summer(nBins);
        end
        h = figuree(1200,900);
        for iEvent = 1:2
            subplot(rows,cols,prc(cols,[1,(iEvent*2)-1]));
            curPower = squeeze(squeeze(W_power(iFreq,iEvent,sortKeys(iSortby,:),:)));
            curPhase = squeeze(squeeze(W_phase(iFreq,iEvent,sortKeys(iSortby,:),:)));
            imagesc(t,1:size(curPower,1),curPower);
            xlim([-1 1]);
            xticks(sort([xlim 0]));
            xlabel('time (s)');
            ylim([1 size(curPower,1)]);
            yticks(ylim);
            ylabel('wire-trials');
            colormap(jet);
            caxis([0 1000]); % !! UPDATE
            title([num2str(freqList(iFreq)),'Hz at ',eventFieldnames{useEvents(iEvent)},' by ',RTMTlabels{iSortby}]);
            grid on;

            subplot(rows,cols,prc(cols,[1,(iEvent*2)]));
            for iBin = 1:nBins
                plot(t,median(curPower(binIdxs(iBin):binIdxs(iBin+1),:)),'-','color',sortByColors(iBin,:),'LineWidth',lineWidth);
                hold on;
            end
            xlim([-1 1]);
            xticks(sort([xlim 0]));
            xlabel('time (s)');
            yticks(ylim);
            ylabel('power');
            cb = colorbar;
            colormap(cb,sortByColors);
            caxis([round(min(sortTimes(iSortby,:)),2) round(max(sortTimes(iSortby,:)),2)]);
            set(cb,'YTick',caxis);
            ylabel(cb,RTMTlabels{iSortby});
            title('Median Power');
            grid on;

            for iMedian = 1:numel(testMedians)
                cutoffPower =  W_median(W_key(iTrial,2),iFreq) * testMedians(iMedian);
                x = [];
                y = [];
                C = [];
                for iTrial = 1:size(curPower,1)
                    [locs,pks] = peakseek(curPower(iTrial,:),round(size(curPower,2)/2/freqList(iFreq)),cutoffPower);
                    x = [x (locs/size(curPower,2)*2) - 1];
                    y = [y repmat(iTrial,[1 numel(locs)])];
                    C = [C;phaseColors(round(rad2deg(curPhase(iTrial,locs)+pi))+1,:)];
                end
                subplot(rows,cols,prc(cols,[1+iMedian,(iEvent*2)-1]));
                scatter(x,y,3,C,'filled');
                xlim([-1 1]);
                xticks(sort([xlim 0]));
                xlabel('time (s)');
                ylim([1 size(curPower,1)]);
                yticks(ylim);
                ylabel('wire-trials');
                cb = colorbar;
                colormap(cb,phaseColors);
                caxis([-pi pi]);
                set(cb,'YTick',[-pi 0 pi]);
                set(cb,'YTickLabel',{'-\pi','0','\pi'});
                ylabel(cb,'phase angle');
                set(gca,'YDir','reverse');
                title([num2str(testMedians(iMedian)),'x Median Transients']);

                nmedBins = 61;
                nSmooth = 3;
                subplot(rows,cols,prc(cols,[1+iMedian,(iEvent*2)]));
                for iBin = 1:nBins
                    binx = x(find(y >= binIdxs(iBin) & y < binIdxs(iBin+1)));
                    medCounts = histcounts(binx,linspace(-1,1,nmedBins));
                    plot(linspace(-1,1,nmedBins-1),smooth(medCounts,nSmooth),'-','color',sortByColors(iBin,:),'LineWidth',lineWidth);
                    hold on;
                end
                xlim([-1 1]);
                xticks(sort([xlim 0]));
                xlabel('time (s)');
                yticks(ylim);
                ylabel('count');
                title('Transient Event Histogram');
                cb = colorbar;
                colormap(cb,sortByColors);
                caxis([round(min(sortTimes(iSortby,:)),2) round(max(sortTimes(iSortby,:)),2)]);
                set(cb,'YTick',caxis);
                ylabel(cb,RTMTlabels{iSortby});
                grid on;
                box on;
            end
        end
        set(gcf,'color','w');
        saveFile = [num2str(freqList(iFreq)),'Hz_by',RTMTlabels{iSortby},'_transients.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end
