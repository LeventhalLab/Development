% compiled_eventsArr(iNeuron).
% eventsArr
% eventsArr_meta
% eventRTcorr
% eventMTcorr

useEventArr = 'Tone';
condLabels = {'before','after','before+after'};

if strcmp(useEventArr,'Tone')
    compiled_eventsArr = compiled_eventsArr_Tone;
else
    compiled_eventsArr = compiled_eventsArr_NoseOut;
end

% % savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/transientTiming/MT';
freqList = logFreqList([3.5 100],30);
lineLabels = {};
loopCount = 0;
minTransientEvents = 2;
for iTiming = 1:2 
    if iTiming == 1
        timingField = 'RT';
    else
        timingField = 'MT';
    end
    freqCV2 = {};
    freqFano = {};
    for iFirstLast = 1:2
        for iCond = 1:2
            freqRs = {};
            freqPs = {};
            for iNeuron = 1:numel(compiled_eventsArr)
                if isempty(compiled_eventsArr(iNeuron).eventsArr)
                    continue;
                end

                eventsArr = compiled_eventsArr(iNeuron).eventsArr;
                eventsArr_meta = compiled_eventsArr(iNeuron).eventsArr_meta;
                eventRTcorr = compiled_eventsArr(iNeuron).eventRTcorr;
                eventMTcorr = compiled_eventsArr(iNeuron).eventMTcorr;
                if strcmp(timingField,'RT')
                    useEventCorr = eventRTcorr;
                else
                    useEventCorr = eventMTcorr;
                end
                
                for iFreq = 1:size(eventsArr,1)
                    RTs = [];
                    numberOfEvents = [];
                    timeToEvent = [];
                    IEIlog = [];
                    trialCount = 0;
                    for iTrial = 1:numel(useEventCorr)
                        transientTiming = eventsArr_meta{iFreq,iTrial};
                        if isempty(transientTiming) || isnan(useEventCorr(iTrial))
                            continue;
                        end
                        if iCond == 1
                            if sum(transientTiming(1,:) <= 0) < minTransientEvents
                                continue;
                            end
                            idx = transientTiming(1,:) <= 0;
                        else
                            if sum(transientTiming(1,:) > 0) < minTransientEvents
                                continue;
                            end
                            idx = transientTiming(1,:) > 0;
                        end
                        trialCount = trialCount + 1;
                        RTs(trialCount) = useEventCorr(iTrial);
                        numberOfEvents(trialCount) = eventsArr(iFreq,iTrial,iCond);
                        IEIlog = [IEIlog diff(transientTiming(1,idx))];
                        if iFirstLast == 1
                            timeToEvent(trialCount) = min(transientTiming(1,idx));
                        else
                            timeToEvent(trialCount) = max(transientTiming(1,idx));
                        end
                    end
                    
                    if isempty(RTs)
                        R = 0;
                        P = 1;
                        Pqual = 1;
                    else
                        [R,P] = corr(RTs',timeToEvent');
                        [Rqual,Pqual] = corr(RTs',numberOfEvents');
                    end
                        
                    if Pqual >= 0.05
                        R = NaN;
                        P = NaN;
                    end
                    
                    if numel(freqRs) < iFreq
                        freqRs{iFreq} = [];
                        freqPs{iFreq} = [];
                        freqCV2{iFreq,iCond} = [];
                        freqFano{iFreq,iCond} = [];
                    end
%                     CV2 = var(IEIlog) / mean(IEIlog)^2;
%                     FanoFactor = var(numberOfEvents) / mean(numberOfEvents);
                    freqRs{iFreq} = [freqRs{iFreq} R];
                    freqPs{iFreq} = [freqPs{iFreq} P];
                    
                    freqCV2{iFreq,iCond} = [freqCV2{iFreq,iCond} IEIlog];
                    freqFano{iFreq,iCond} = [freqFano{iFreq,iCond} numberOfEvents];
                end
            end
            allCondPs{iFirstLast,iCond} = freqPs;
        end
        
    end
    % plot here for iTiming (RT,MT)
    h1 = figuree(1200,900);
    rows = 6;
    cols = 5;
    for iFreq = 1:size(eventsArr,1)
        x = [];
        for iFirstLast = 1:2
            for iCond = 1:2
                x = [x;allCondPs{iFirstLast,iCond}{iFreq}];
            end
        end
        subplot(rows,cols,iFreq);
        boxplot(x','PlotStyle','compact','ColorGroup',[1 0 0;1 0 0;0 0 1;0 0 1]);
        ylim([0 1]);
        yticks(ylim);
        ylabel('p-value');
        grid on;
        title({[num2str(freqList(iFreq),'%2.1f'),' Hz, ',timingField,'p < 0.05 by #'],['<--before | ',useEventArr,' | after-->']});
        set(gca,'XTickLabel',{' '});
        xticks(1:4);
        xticklabels({'First','Last','First','Last'});
        set(gca,'FontSize',8);
    end
    set(gcf,'color','w');
    
    h2 = figuree(1200,900); 
    rows = 6;
    cols = 5;
    colors = [1 0 0;0 0 1];
    for iFreq = 1:size(eventsArr,1)
        n_CV2 = [];
        n_Fano = [];
        subplot(rows,cols,iFreq);
        for iCond = 1:2
            CV2_vals = freqCV2{iFreq,iCond};
            n_CV2(iCond) = numel(CV2_vals);
            CV2 = var(CV2_vals) / mean(CV2_vals)^2;
            FF_vals = freqFano{iFreq,iCond};
            n_Fano(iCond) = numel(FF_vals);
            FF = var(FF_vals) / mean(FF_vals);
            plot(FF,CV2,'.','color',colors(iCond,:),'MarkerSize',30);
            hold on;
        end
        xlim([0 2]);
        xticks([0:0.5:2]);
        xlabel({'Fano Factor',['b:',num2str(n_Fano(1)),', a:',num2str(n_Fano(2)),]});
        ylim(xlim);
        yticks(xticks);
        ylabel({'CV^2',['b:',num2str(n_CV2(1)),', a:',num2str(n_CV2(2))]});
        grid on;
        title({[num2str(freqList(iFreq),'%2.1f'),' Hz, ',timingField]});
        legend({'before','after'});
        set(gca,'FontSize',8);
        grid on;
    end
    set(gcf,'color','w');
end