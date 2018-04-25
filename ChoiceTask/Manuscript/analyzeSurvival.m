% function analyzeSurvival(waveforms,sameWire,wireLabels,channel,unit,spiketimes,wmean,survival)

savePath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Resubmission/UnitSurvival';
unitCount = 0;
for iDay = 1:numel(survival)
    [td_units,tm_units] = find(survival{iDay} == 1);
    for iUnit = 1:numel(td_units)
        unitCount = unitCount + 1;
        
%         td_wmean = wmean{iDay}{td_units(iUnit)};
%         tm_wmean = wmean{iDay+1}{tm_units(iUnit)};
%         td_spiketimes = spiketimes{iDay}{td_units(iUnit)};
%         tm_spiketimes = spiketimes{iDay+1}{tm_units(iUnit)};
%         
%         figuree(800,300);
%         subplot(121);
%         plot(td_wmean,'lineWidth',2);
%         hold on;
%         plot(tm_wmean,'lineWidth',2);
%         xlabel('sample');
%         xlimVals = size(tm_wmean);
%         xlim(xlimVals);
%         xticks(xlimVals);
%         ylabel('uV');
%         ylimVals = ylim;
%         yticks(sort([0 ylimVals]));
%         title(['Session ',num2str(iDay)]);
%         legend('Today','Tomorrow');
%         
%         subplot(122);
%         binEdges = [0:.001:.04];
%         td_counts = histcounts(diff(td_spiketimes),binEdges);
%         tm_counts = histcounts(diff(tm_spiketimes),binEdges);
%         plot(td_counts,'lineWidth',2);
%         hold on;
%         plot(tm_counts,'lineWidth',2);
%         set(gca,'xscale','log')
%         xlabel('ISI (ms)');
%         xlim(size(td_counts));
%         xticks(size(td_counts));
%         xticklabels([binEdges(1) binEdges(end)*1000]);
%         ylabel('count');
%         ylimVals = ylim;
%         yticks(ylimVals);
%         legend('Today','Tomorrow');
    end
end