% function tsFft(tsPeth)
% tsPeth = trials x events (cell)
% ... where {m,n} = ts for (trial,event)
% close all;
% eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};

nSmooth = 10;
% maxBurstISI = .2;
maxSpikes = 10000;
binInc = .0001;
stopTs = 0.025;
startTs = 0;
bins = startTs:binInc:stopTs;
tsPethISIs = {};
figure('position',[0 0 800 800]);
useEvents = 1:6;
for eventNumber = useEvents
    eventNeuronIds = find(eventIds_by_maxHistValues == eventNumber);
    for iEvent = useEvents
        allEventISIs = [];
        for iNeuron = 1:numel(eventNeuronIds) %size(all_tsPeths,2)
            cur_tsPeths = all_tsPeths{1,eventNeuronIds(iNeuron)};
            for iTrial = 1:size(cur_tsPeths,1)
                curPeth = cur_tsPeths{iTrial,iEvent};
                curPeth = curPeth(curPeth >= startTs & curPeth < stopTs);
                if numel(curPeth) > 2
                    if numel(curPeth) < maxSpikes
                        ISIs = (diff(curPeth));
%                         ISIs = pdist(curPeth');
    %                     ISIs = ISIs(ISIs > 0.2);
                        allEventISIs = [allEventISIs ISIs];
                    end

                end
            end
        end
        [counts,centers] = hist(allEventISIs,bins);
        linewidth = 0.5;
        if iEvent == eventNumber
            linewidth = 3;
        end
        subplot(2,3,eventNumber);
        hold on;
        plot(centers,(smooth(counts,nSmooth)),'linewidth',linewidth);
        xlim([0 stopTs-startTs]);
        set(gca,'yscale','log');
    end
    title([eventFieldnames{eventNumber},' - pdist']);
    legend(eventFieldnames{useEvents});
end
