function plotLfpTrials(allLfp,t,vis_tWindow,n)

t1Idx = closest(t,-vis_tWindow);
t2Idx = closest(t,vis_tWindow);
t_vis = linspace(-vis_tWindow,vis_tWindow,numel(t1Idx:t2Idx));
ylimVals = [-500 500];

useTrials = unique(round(linspace(1,size(allLfp,3),n)));
rows = numel(useTrials);

figuree(1200,80*rows);
for iTrial = useTrials
    for iEvent = 1:7
        curLfp = squeeze(squeeze(allLfp(iEvent,t1Idx:t2Idx,iTrial)));
        plot(t_vis,curLfp);
    end
end