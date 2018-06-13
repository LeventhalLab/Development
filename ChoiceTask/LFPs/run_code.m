for iNeuron = 1:numel(compiled_eventsArr)
    if isempty(compiled_eventsArr(iNeuron).eventsArr)
        continue;
    end
    for iFreq = 1:size(eventsArr,1)
        for iTrial = 1:numel(eventRTcorr)
            transientTiming = t_compiled_eventsArr(iNeuron).eventsArr_meta{iFreq,iTrial};
            if ~isempty(transientTiming)
                transientTiming(1,:) = (transientTiming(1,:).*4)-1;
                compiled_eventsArr(iNeuron).eventsArr_meta{iFreq,iTrial} = transientTiming;
            end
        end
    end
end