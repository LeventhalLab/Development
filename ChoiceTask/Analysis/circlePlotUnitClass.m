trialTypes = {'correctContra','correctIpsi'};
[unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,nBins_tWindow,trialTypes);

figuree(1200,500);
rows = 2;
xmm = zeros(numel(eventFieldnames));
for iEvent = 1:numel(eventFieldnames)
    xm = zeros(numel(eventFieldnames));
    classCount = 0;
    for iNeuron = 1:numel(analysisConf.neurons)
        if isempty(unitEvents{iNeuron}.class)
            continue;
        end
        if unitEvents{iNeuron}.class(1) == iEvent
            xm(iEvent,unitEvents{iNeuron}.class(2)) = xm(iEvent,unitEvents{iNeuron}.class(2)) + 1; % increment
            xmm(iEvent,unitEvents{iNeuron}.class(2)) = xm(iEvent,unitEvents{iNeuron}.class(2)) + 1; % increment
            classCount = classCount + 1;
        end
    end
    subplot(rows,numel(eventFieldnames),iEvent);
    myColorMap = lines(numel(eventFieldnames));
    CG = circularGraph(xm,'Colormap',myColorMap,'Label',eventFieldnames);
    
    subplot(rows,numel(eventFieldnames),iEvent+numel(eventFieldnames));
    bar(1:numel(eventFieldnames),xm(iEvent,:),'FaceColor',myColorMap(iEvent,:),'EdgeColor','none');
    xticklabels(eventFieldnames);
    xtickangle(90);
    ylim([0 45]);
    xlim([0 8]);
    title([eventFieldnames{iEvent},' (',num2str(classCount),')']);
end

% figuree(800,800);
% CG = circularGraph(xmm,'Colormap',myColorMap,'Label',eventFieldnames);