function eegTraces(spikeTs,spikeTslabels,rawLFP,scaloLFP,tWindow,freqA,freqAlabels,freqP,freqPlabels,eventTs,centerEvent,eventLabels)
% [ ] show SDE?
% close all

scaler = 0.4;
t = linspace(-tWindow,tWindow,numel(rawLFP));
t_hist = linspace(-tWindow,tWindow,numel(rawLFP)+1);
nRows = numel(spikeTs) + 1 + numel(freqA) + numel(freqP);

h = ff(1400,800);
try
    yticklabelVals = {};
    curRow = nRows;
    for iSpike = 1:numel(spikeTs)
        ts = spikeTs{iSpike};
        spikeLocs = find(histcounts(ts,t_hist));
        x = [spikeLocs;spikeLocs];
        y = repmat([-1;1]*scaler,[1 numel(spikeLocs)]);
        plot(t(x),y+curRow,'k-');
        hold on;
        plot([-tWindow,tWindow],[curRow curRow],'k-');
        yticklabelVals{curRow} = ['Unit ',spikeTslabels{iSpike}];
        curRow = curRow - 1;
    end

    plot(t,(normalize(rawLFP)*2-1)*scaler+curRow,'k-');
    yticklabelVals{curRow} = 'Raw LFP';
    curRow = curRow - 1;

    lineWidth = 2;
    for iScalo = 1:numel(freqA)
        scaloData = abs(scaloLFP(:,freqA(iScalo)).^2);
        plot(t,(normalize(scaloData)*2-1)*scaler+curRow,'b-','lineWidth',lineWidth);
        yticklabelVals{curRow} = [freqAlabels{iScalo},'-power'];
        curRow = curRow - 1;
    end

    for iScalo = 1:numel(freqP)
        scaloData = angle(scaloLFP(:,freqP(iScalo)));
        plot(t,(normalize(scaloData)*2-1)*scaler+curRow,'r-','lineWidth',lineWidth);
        yticklabelVals{curRow} = [freqPlabels{iScalo},'-phase'];
        curRow = curRow - 1;
    end

    xticklabelVals = {num2str(-tWindow)};
    xtickVals = [-tWindow];
    for iEvent = 1:numel(eventTs)
        if iEvent == centerEvent
    % %         xticklabelVals{iEvent + 1} = '0';
    % %         xtickVals = [xtickVals 0];
            title(eventLabels{iEvent});
        else
            xticklabelVals = {xticklabelVals{:} eventLabels{iEvent}};
            xtickVals = [xtickVals eventTs(iEvent)];
        end
    end
    xticklabelVals = {xticklabelVals{:} num2str(tWindow)};
    xtickVals = [xtickVals tWindow];

    % labels
    xticks(xtickVals);
    xticklabels(xticklabelVals);
    xtickangle(30);
    yticks(1:nRows);
    yticklabels(yticklabelVals);
    ylim([0 nRows+1]);
    set(gcf,'color','w');
    set(gca,'fontSize',16);
    xlabel('Time (s)');
    plot([0 0],ylim,'k:');
catch
    close(h);
end

% % function makeSDE(ts)
% % 
% % % %         SDE = [];
% % % %         for iTrial = 1:size(tsPeths,1)
% % % %             for iEvent = 1:size(tsPeths,2)
% % % %                 ts = tsPeths{iTrial,iEvent};
% % % %                 SDE(iTrial,iEvent,:) = spikeDensityEstimate_periEvent(ts,tWindow);
% % % %             end
% % % %         end
% % % %         zMean = mean(mean(SDE(:,1,:)));
% % % %         zStd = mean(std(SDE(:,1,:),[],3));
% % % %         zSDE = (SDE - zMean) ./ zStd;
% % end