saveDir = '/Users/mattgaidica/Documents/Data/ChoiceTask/spikeRasterWithIncorrect';
doLegend = true;
doSave = false;
useEvents = [1:7];
for iNeuron = 188%1:numel(analysisConf.neurons)
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
    trialIdInfo = organizeTrialsById(curTrials);
    trialIds = [trialIdInfo.correctContra trialIdInfo.correctIpsi trialIdInfo.incorrectContra trialIdInfo.incorrectIpsi];
    tsPeths = eventsPeth(curTrials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames);
% %     h = figuree(150*numel(useEvents)+300,200);
    h = figuree(1200,200);
    for iEvent = 1:numel(useEvents)
        ax = subplot(1,numel(useEvents),iEvent);
        rasterData = tsPeths(:,useEvents(iEvent));
%         rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
        for iTrial = 1:numel(rasterData)
            if isempty(rasterData{iTrial})
                rasterData{iTrial} = NaN;
            end
        end
        rasterData = makeRasterReadable(rasterData,50); % limit to 100 data points
        th = figure;
        [xPoints,yPoints] = plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
        close(th);
        figure(h);
        hold on;
        
        n_correctContra = 1;
        n_correctIpsi = n_correctContra + numel(trialIdInfo.correctContra);
        n_incorrectContra = n_correctIpsi + numel(trialIdInfo.correctIpsi);
        n_incorrectIpsi = n_incorrectContra + numel(trialIdInfo.incorrectContra);
        
        groups = ones(numel(trialIds),1) * 4;
        trialRange = 1:n_correctIpsi;
        groups(trialRange) = ones(numel(trialRange),1) * 1;
        trialRange = n_correctIpsi+1:n_incorrectContra;
        groups(trialRange) = ones(numel(trialRange),1) * 2;
        trialRange = n_incorrectContra+1:n_incorrectIpsi;
        groups(trialRange) = ones(numel(trialRange),1) * 3;
        
        figPos = [];
        markerSize = 4;
        colors = lines(2);
        colors(3,:) = colors(1,:) * .5;
        colors(4,:) = colors(2,:) * .5;
% %         colors = [];
% %         colors(1,:) = [1 0 0];
% %         colors(2,:) = [0 0 1];
% %         colors(3,:) = [.75 0 0];
% %         colors(4,:) = [0 0 .75];
        plotSpikeRaster_color(xPoints,yPoints,groups,colors,figPos,markerSize)
        
% %         plot([-tWindow tWindow],[n_correctContra n_correctContra],'r:');
% %         plot([-tWindow tWindow],[n_correctIpsi n_correctIpsi],'r:');
        plot([-tWindow tWindow],[n_incorrectContra n_incorrectContra],'k--','lineWidth',1.5);
% %         plot([-tWindow tWindow],[n_incorrectIpsi n_incorrectIpsi],'r:');
        ytickVals = [n_correctContra,n_correctIpsi,n_incorrectContra,n_incorrectIpsi];
        ytickReplaceIdx = find(diff(ytickVals) == 0);
        xlim([-1 1]);
        while ~isempty(ytickReplaceIdx)
            ytickVals(ytickReplaceIdx(end)+1) = ytickVals(ytickReplaceIdx(end)+1) + 1;
            ytickReplaceIdx = find(diff(ytickVals) == 0);
        end
        yticks(ytickVals);
% %         title(eventFieldnames{useEvents(iEvent)});
        if iEvent == 1
%             title(['unit',num2str(iNeuron),' - ',neuronName],'interpreter','none');
%             yticklabels({'Tone Contra, Move Contra','Tone Ipsi, Move Ipsi','Tone Ipsi, Move Contra','Tone Contra, Move Ipsi'});
            yticklabels({'1','','',num2str(numel(trialIds))});
            ytickangle(0);
            ylabel('Trials');
        else
            yticklabels({'','','',''});
        end
        if iEvent == 4
            xlabel('time (s)');
        end
        title(eventFieldlabels{iEvent});
        set(gca,'fontSize',16);
    end
    set(gcf,'color','w');
    tightfig;
    
    if doLegend
        th = figure;
        lns = [];
        for ii = 1:4
            lns(ii) = plot(1,1,'.','color',colors(ii,:),'markerSize',40);
            hold on;
        end
        legend(lns,{'Tone Contra, Move Contra','Tone Ipsi, Move Ipsi','Tone Ipsi, Move Contra','Tone Contra, Move Ipsi'});
        set(gca,'fontSize',16);
        set(gcf,'color','w');
    end
    if doSave
        saveas(h,fullfile(saveDir,['ipsiContraRaster_allEvents_',neuronName,'.fig']));
        close(h);
    end
end