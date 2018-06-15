% % load('session_20180516_FinishedResubmission.mat', 'primSec');
% % load('session_20180516_FinishedResubmission.mat', 'analysisConf');
% % load('session_20180516_FinishedResubmission.mat', 'dirSelUnitIds');
% % load('session_20180516_FinishedResubmission.mat', 'all_coords'); % ML, AP, DV
% pSC from: doesTransientTimingMatter.m
[uniqueLFPfiles,ic,ia] = unique(LFPfiles_local);

sigBar = [];
nsigBar = [];
xspace = 0.25;
xPos = [];
colorgroup = [];
for iFreq = 1:size(pSC,1)
    sigDVs = NaN(1,366);
    nsigDVs = NaN(1,366);
    for iSession = 1:size(pSC,2)
        neuronIds = find(strcmp(uniqueLFPfiles{iSession},LFPfiles_local) == 1);
        theseCoords = abs(all_coords(neuronIds,3))*-1;
        if pSC(iFreq,iSession) < 0.05
            sigDVs(neuronIds) = theseCoords;
        else
            nsigDVs(neuronIds) = theseCoords;
        end
    end
    sigBar(iFreq*2-1,:) = sigDVs;
    sigBar(iFreq*2,:) = nsigDVs;
    colorgroup = [colorgroup;1 0 0;repmat(0.5,[1,3])];
    xPos = [xPos (iFreq*3-1)-xspace (iFreq*3-1)+xspace];
end

figuree(1200,400);
boxplot(sigBar','position',xPos,'PlotStyle','compact','ColorGroup',colorgroup);
set(gca,'XTickLabel',{' '});
xticks([2:3:90]);
xticklabels({num2str(freqList(:),'%2.1f')});
xtickangle(90);
ylim([-9 -5]);
yticks(-9:.5:-5);
box_vars = findall(gca,'Tag','Box');
hLegend = legend(box_vars([1,2]), {'Non-significant','Significant'});

title(['Unit Class p < 0.05 - Timing Corr x ',timingField,' ',condLabels{iCond},' ',useEventArr]);
set(gcf,'color','w');