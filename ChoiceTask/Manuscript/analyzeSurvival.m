% function analyzeSurvival(sessionNames,unitid,waveforms,sameWire,wireLabels,channel,unit,spiketimes,wmean,survival)
doSave = true;
doPlot = false;
savePath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Resubmission/UnitSurvival';
unitCount = 0;
removeUnits = [];
for iDay = 1:numel(survival)
    [td_units,tm_units] = find(survival{iDay} == 1);
    for iUnit = 1:numel(td_units)
        unitCount = unitCount + 1;
        cur_unitid = unitid{iDay}(iUnit);
        removeUnits(unitCount) = cur_unitid;
        
        td_wmean = wmean{iDay}{td_units(iUnit)};
        tm_wmean = wmean{iDay+1}{tm_units(iUnit)};
        td_spiketimes = spiketimes{iDay}{td_units(iUnit)};
        tm_spiketimes = spiketimes{iDay+1}{tm_units(iUnit)};
        
        if doPlot
            h = figuree(800,300);
            subplot(121);
            plot(td_wmean,'lineWidth',2);
            hold on;
            plot(tm_wmean,'lineWidth',2);
            xlabel('sample');
            xlimVals = size(tm_wmean);
            xlim(xlimVals);
            xticks(xlimVals);
            ylabel('uV');
            ylimVals = ylim;
            yticks(sort([0 ylimVals]));
            titleString = [sessions{iDay},'_cnt',num2str(unitCount,'%03i'),'_uid',num2str(removeUnits(unitCount),'%03i')];
            if isnan(primSec(cur_unitid,1))
                primClass = 'N/A';
            else
                primClass = eventFieldlabels{primSec(cur_unitid,1)};
            end
            if isnan(primSec(cur_unitid,2))
                secClass = 'N/A';
            else
                secClass = eventFieldlabels{primSec(cur_unitid,2)};
            end
            metaData = ['prim: ',primClass,', sec: ',secClass];
            title({titleString,metaData},'interpreter','none');
            legend('Today','Tomorrow');

            subplot(122);
            binEdges = [0:.001:.04];
            td_counts = histcounts(diff(td_spiketimes),binEdges);
            tm_counts = histcounts(diff(tm_spiketimes),binEdges);
            plot(td_counts,'lineWidth',2);
            hold on;
            plot(tm_counts,'lineWidth',2);
            set(gca,'xscale','log')
            xlabel('ISI (ms)');
            xlim(size(td_counts));
            xticks(size(td_counts));
            xticklabels([binEdges(1) binEdges(end)*1000]);
            ylabel('count');
            ylimVals = ylim;
            yticks(ylimVals);
            legend('Today','Tomorrow');

            if doSave
                saveas(h,fullfile(savePath,[titleString,'.png']));
                close(h);
            end
        end
    end
end
survivalUnitClasses = primSec(removeUnits,:);
dirUnits = dirSelNeuronsNO(removeUnits);
primaryTone = numel(find(survivalUnitClasses(:,1) == 3))
primaryNoseOut = numel(find(survivalUnitClasses(:,1) == 4))
% secondaryTone = numel(find(unitClasses(:,2) == 3))
% secondaryNoseOut = numel(find(unitClasses(:,2) == 4))
primaryToneEffect = sum(dirUnits(find(survivalUnitClasses(:,1) == 3)))
primaryNoseOutEffect = sum(dirUnits(find(survivalUnitClasses(:,1) == 4)))