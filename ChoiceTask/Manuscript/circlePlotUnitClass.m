% trialTypes = {'correctContra','correctIpsi'};
% binMs = 50;
% tWindow = 0.25;
% useEvents = 1:7;
% [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents);
% tWindow = 1;

compiledEvents = zeros(numel(eventFieldnames),1);
dirSelByEvent = zeros(numel(eventFieldnames),1);
for iNeuron = 1:numel(unitEvents)
    if isempty(unitEvents{iNeuron}.class)% && unitEvents{iNeuron}.maxz(unitEvents{iNeuron}.class(1)) > 1.96
        continue;
    end
    compiledEvents(unitEvents{iNeuron}.class(1),1) = compiledEvents(unitEvents{iNeuron}.class(1)) + 1;
    if dirSelNeuronsNO(iNeuron)
        dirSelByEvent(unitEvents{iNeuron}.class(1),1) = dirSelByEvent(unitEvents{iNeuron}.class(1),1) + 1;
    end
end

h = figuree(1200,300);
rows = 1;
xmm = zeros(numel(eventFieldnames));

for iEvent = 1:numel(eventFieldnames)
    xm = zeros(numel(eventFieldnames));
    classCount = 0;
    for iNeuron = 1:numel(analysisConf.neurons)
        if isempty(unitEvents{iNeuron}.class)
            continue;
        end
        if unitEvents{iNeuron}.class(1) == iEvent % && numel(unitEvents{iNeuron}.class) > 0.5 && unitEvents{iNeuron}.maxz(unitEvents{iNeuron}.class(2)) > 0.5
            xm(iEvent,unitEvents{iNeuron}.class(2)) = xm(iEvent,unitEvents{iNeuron}.class(2)) + 1; % increment
            xmm(iEvent,unitEvents{iNeuron}.class(2)) = xm(iEvent,unitEvents{iNeuron}.class(2)) + 1; % increment
            classCount = classCount + 1;
        end
    end
    subplot(rows,numel(eventFieldnames),iEvent);
    myColorMap = lines(numel(eventFieldnames));
%     CG = circularGraph(xm,'Colormap',myColorMap,'Label',eventFieldnames);
    
    subplot(rows,numel(eventFieldnames),iEvent);
    bar(1:numel(eventFieldnames),compiledEvents,'FaceColor',[.75 .75 .75],'EdgeColor','w'); hold on; % gray event class, same for all 
    bar(iEvent,compiledEvents(iEvent),'FaceColor',myColorMap(iEvent,:),'EdgeColor','none'); % colored event bar
    bar(iEvent,dirSelByEvent(iEvent),'FaceColor','k','EdgeColor','none'); % black dirSel overlay on colored event bar
    bar(1:numel(eventFieldnames),xm(iEvent,:),'FaceColor',myColorMap(iEvent,:),'EdgeColor','w','FaceAlpha',.3); % light colored secondary event class
    bar(1:numel(eventFieldnames),compiledEvents,'FaceColor','none','EdgeColor','w'); % white outline
    xticklabels(eventFieldnames);
    xtickangle(90);
    ylim([0 120]);
    xlim([0 8]);
    title([eventFieldnames{iEvent},' (n=',num2str(classCount),')']);
    if iEvent == 1
        ylabel('units');
    end
end
set(gcf,'color','w');
addNote(h,{'Solid (& light gray) = event class 1','Transparent = event class 2'...
    'Black = dirSel units'});
% figuree(800,800);
% CG = circularGraph(xmm,'Colormap',myColorMap,'Label',eventFieldnames);