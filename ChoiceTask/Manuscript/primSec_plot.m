close all

doSetup = false;
if doSetup
    tWindow = 1;
    binMs = 50;
    trialTypes = {'correct'};
    useEvents = 1:7;
    useTiming = {};

    [unitEvents,all_zscores,unitClass] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);
    
    minZ = 0.5;
    [primSec,fractions] = primSecClass(unitEvents,minZ);
end

primSec_wNC = primSec;
primSec_wNC(isnan(primSec_wNC)) = 8;

figuree(1400,400);
rlimVals = [0 80];
cols = 7;
colors = parula(14);
colors = colors(3:3+7,:);
colors(8,:) = [.7 .7 .7];
% fate of primary units
for iEvent = 1:cols
    subplot(1,cols,iEvent);
    secUnits = primSec_wNC(primSec_wNC(:,1) == iEvent,2);
    primCount = sum(primSec_wNC(:,1) == iEvent);
    add_const = 15 + (primCount / 5);
    counts = (histcounts(secUnits,0.5:8.5)) + add_const;
    edges = linspace(0,2*pi,9);
    for iCounts = 1:numel(counts)
        polarhistogram('BinEdges',edges(iCounts:iCounts+1),'BinCounts',counts(iCounts),'EdgeColor','w','FaceColor',colors(iCounts,:),'FaceAlpha',1);
        hold on;
    end
    rlim(rlimVals);
    thetaticks('');
    rticks(0);
    rticklabels(num2str(primCount));
    set(gca,'fontSize',16);
    
    
    counts = linspace(0,2*pi,add_const);
    h2 = polarhistogram(counts,1,'FaceColor','w','FaceAlpha',1,'EdgeColor','none','FaceColor',colors(iEvent,:));
    thetaticks('');
end

set(gcf,'color','w');

% % figure;
% % histogram(secUnits,0.5:8.5);