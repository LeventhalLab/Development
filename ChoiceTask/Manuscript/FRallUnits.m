eventFieldlabelsNR = {eventFieldlabels{:} 'NR'};
fontSize = 12;

FRs = [];
FRs_classes = cell(8,1);
FRs_dirSel = cell(2,1);
for iNeuron = 1:numel(all_ts)
    curTs = all_ts{iNeuron};
    curFR = numel(curTs) / curTs(end);
    FRs = [FRs curFR];
    curClass = primSec(iNeuron,1);
    if ~isnan(curClass)
        FRs_classes{curClass} = [FRs_classes{curClass} curFR];
    else
        FRs_classes{8} = [FRs_classes{8} curFR];
    end
    if ismember(primSec(iNeuron,1),[3,4])
        if dirSelNeuronsNO(iNeuron)
            FRs_dirSel{1} = [FRs_dirSel{1} curFR];
        else
            FRs_dirSel{2} = [FRs_dirSel{2} curFR];
        end
    end
end

h = figuree(1300,200);
for iEvent = 1:8
    subplot(1,8,iEvent);
    curFRs = FRs_classes{iEvent};
    plotSpread(curFRs','showMM',5);
    meanFR = mean(curFRs);
    stdFR = std(curFRs);
    title({[eventFieldlabelsNR{iEvent},' (',num2str(numel(curFRs)),' units)'],['mean: ',num2str(meanFR)],['std: ',num2str(stdFR)]});
    ylim([0 100]);
    ylabel('FR (spikes/sec)');
    set(gca,'fontSize',fontSize);
end
addNote(h,{'FR for units of primary class','mean +/- standard deviation'});
set(gcf,'color','w');

dirSelLabels = {'dirSel','~dirSel'};
h = figuree(800,200);
for iEvent = 1:2
    subplot(1,2,iEvent);
    curFRs = FRs_dirSel{iEvent};
    plotSpread(curFRs','showMM',5);
    meanFR = mean(curFRs);
    stdFR = std(curFRs);
    title({[dirSelLabels{iEvent},' (',num2str(numel(curFRs)),' units)'],['mean: ',num2str(meanFR)],['std: ',num2str(stdFR)]});
    ylim([0 100]);
    ylabel('FR (spikes/sec)');
    set(gca,'fontSize',fontSize);
end
addNote(h,{'dir. selectivity Tone & NO units','mean +/- standard deviation'});
set(gcf,'color','w');

figure;
subplot(121);
histogram(FRs,linspace(0,100,20),'FaceColor','k','EdgeColor','k','FaceAlpha',1);
xlim([0 100]);
xlabel('Firing Rate (spikes/sec)');
ylabel('Units');
meanFR = mean(FRs);
stdFR = std(FRs);
title({['All Units FR distribution (',num2str(numel(all_ts)),' units)'],['mean: ',num2str(meanFR)],['std: ',num2str(stdFR)]});
set(gca,'fontSize',fontSize);

subplot(122);
plotSpread(FRs','showMM',5);
ylabel('FR (spikes/sec)');
ylim([0 100]);
set(gca,'fontSize',fontSize);

set(gcf,'color','w');