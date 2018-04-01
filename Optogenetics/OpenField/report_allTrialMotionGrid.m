function report_allTrialMotionGrid(trialActograms,stimIDs,powerList,px2mm,freqLabel)
cmapIM = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/Optogenetics/OpenField/helpers/stoplight.jpg';

if numel(stimIDs) == 25
    rows = 5;
    cols = 5;
else
    rows = 1;
    cols = numel(stimIDs);
end

fillIdxs = ones(cols,1);
figuree(cols*160,rows*160);
for iTrial = 1:size(trialActograms,1)
    allCenters = filter_allCenters(trialActograms{iTrial,3});
    z = smoothn({allCenters(:,1),allCenters(:,2)},'robust');
    
    if any(diff(stimIDs))
        stimID = stimIDs(trialActograms{iTrial,2});
    else
        stimID = 1;
    end
    
    subplot(rows,cols,prc(cols,[stimID,fillIdxs(stimID)]));
    traceColors = mycmap(cmapIM,size(allCenters,1));
    scatter(allCenters(:,1)*px2mm,allCenters(:,2)*px2mm,10,traceColors(1:size(allCenters,1),:),'filled');
    hold on;
    plot(z{1}*px2mm,z{2}*px2mm,'r');
    limVals = [0 500];
    xlim(limVals);
    ylim(limVals);
    xticks([]);
    yticks([]);
    titleStr = [num2str(powerList(stimID),'%1.2f'),' mW (trial ',num2str(iTrial),')'];
    title(titleStr);
    if stimID == max(stimIDs)
        xlabel('mm');
    end
    if fillIdxs(stimID) == 1
        ylabel('mm');
        if stimID == 1
            title({[num2str(freqLabel),' Hz'],titleStr});
        else
            title({'',titleStr});
        end
    end
    set(gca,'ydir','reverse'); % centroid = y-flipped
    box on;
    set(gcf,'color','w');
    
    fillIdxs(stimID) = fillIdxs(stimID) + 1;
end