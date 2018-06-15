% compiled_eventsArr(iNeuron).
% eventsArr
% eventsArr_meta
% eventRTcorr
% eventMTcorr

useEventFeature = 'number'; % 'number' or 'timing'

useEventArr = 'Tone';
if strcmp(useEventArr,'Tone')
    compiled_eventsArr = compiled_eventsArr_Tone;
else
    compiled_eventsArr = compiled_eventsArr_NoseOut;
end

% % savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/transientTiming/MT';
freqList = logFreqList([3.5 100],30);
binEdges = [-1:.05:1];

for iRTMT  = 1%:2 
    if iRTMT == 1
        timingField = 'RT';
    else
        timingField = 'MT';
    end
    
    allPs = [];
    allRs = [];
    for iFreq = 1:size(eventsArr,1)
        freqWindowPs = [];
        freqWindowRs = [];
        for iWindow = 1:numel(binEdges)-1
            windowTransientFeature = [];
            windowRTs = [];
            for iNeuron = 1:numel(compiled_eventsArr)
                eventsArr = compiled_eventsArr(iNeuron).eventsArr;
                eventsArr_meta = compiled_eventsArr(iNeuron).eventsArr_meta;
                eventRTcorr = compiled_eventsArr(iNeuron).eventRTcorr;
                eventMTcorr = compiled_eventsArr(iNeuron).eventMTcorr;
                if strcmp(timingField,'RT')
                    useEventCorr = eventRTcorr;
                else
                    useEventCorr = eventMTcorr;
                end
                for iTrial = 1:numel(useEventCorr)
                    RT = useEventCorr(iTrial);
                    if isnan(RT)
                        continue;
                    end
                    transientTiming = eventsArr_meta{iFreq,iTrial}(1,:);
                    windowIdx = find(transientTiming > binEdges(iWindow) & transientTiming <= binEdges(iWindow + 1));
                    if strcmp(useEventFeature,'number')
                        windowTransientFeature = [windowTransientFeature numel(windowIdx)];
                        windowRTs = [windowRTs RT];
                    else
                        windowTransientFeature = [windowTransientFeature transientTiming(windowIdx)];
                        windowRTs = [windowRTs repmat(RT,[1,numel(windowIdx)])];
                    end
                end
            end
            [R,P] = corr(windowRTs',windowTransientFeature');
            freqWindowPs(iWindow) = P;
            freqWindowRs(iWindow) = R;
        end
        allPs(iFreq,:) = freqWindowPs;
        allRs(iFreq,:) = freqWindowRs;
    end
end

h1 = figuree(1200,900);
set(h1,'defaultAxesColorOrder',[[0 0 0]; [1 0 0]]);
rows = 5;
cols = 6;
t = linspace(-1,1,size(allPs,2));
for iFreq = 1:size(allPs,1)
    subplot(rows,cols,iFreq);
    yyaxis right;
    plot(t,allPs(iFreq,:),'-','linewidth',0.5,'color',[1 0 0 0.2]);
    ylim([0 1]);
    ylabel('p-value');
    
    yyaxis left;
    plot(t,allRs(iFreq,:),'k-','linewidth',2);
    ylim([-0.5 0.5]);
    yticks(sort([ylim 0]));
    ylabel('R');
    
    xlim([min(t) max(t)]);
    xticks(sort([xlim 0]));
    xlabel('time (s)');
    title({[num2str(freqList(iFreq),'%2.1f'),' Hz, ',timingField,' at ',useEventArr],['corr. event ',useEventFeature]});
    grid on;
end