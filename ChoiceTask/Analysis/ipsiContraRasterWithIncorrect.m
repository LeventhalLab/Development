saveDir = 'C:\Users\Administrator\Documents\Data\ChoiceTask\ipsiContraWithIncorrectRaster';
saveExt = '.png';
doLegend = false;
doSave = true;
useEvents = [1:7];
% units: 113, 188, 201
for iNeuron =  1:numel(analysisConf.neurons) % 188
    note_dirSel = '-';
    note_dirSelNO = '-';
    note_dirSelSO = '-';
    if dirSelNeurons(iNeuron)
        note_dirSel = 'YES';
        if dirSelNeuronsNO(iNeuron)
            if dirSelNeuronsNO_contra(iNeuron)
                note_dirSelNO = 'contra';
            else
                note_dirSelNO = 'ipsi';
            end
        else
            if dirSelNeuronsSO_contra(iNeuron)
                note_dirSelSO = 'contra';
            else
                note_dirSelSO = 'ipsi';
            end
        end
    else
% %         disp(['Skipping neuron ',num2str(iNeuron)]);
% %         continue;
    end
    
    neuronName = analysisConf.neurons{iNeuron};
    curTrials = all_trials{iNeuron};
    trialIdInfo = organizeTrialsById(curTrials);

    trialIds_conds = {trialIdInfo.correctContra trialIdInfo.correctIpsi trialIdInfo.incorrectContra trialIdInfo.incorrectIpsi};
    
    % skip if any rasters are empty, generates error below
    if any(cellfun(@isempty,trialIds_conds))
        disp(['Contra/ipsi trials missing: ',num2str(iNeuron)]);
        continue;
    end
    
    trialIds = [];
    for iCond = 1:numel(trialIds_conds)
        trialIds_cond = trialIds_conds{iCond};
        t = [];
        for iTrial = 1:numel(trialIds_cond)
            if ismember(iCond,[1,2])
                t(iTrial) = curTrials(trialIds_cond(iTrial)).timing.MT;
            else
                t(iTrial) = curTrials(trialIds_cond(iTrial)).timing.movementTime;
            end
        end
        [v,k] = sort(t);
        trialIds = [trialIds trialIds_cond(k)];
    end
% %     trialIds = [trialIdInfo.correctContra trialIdInfo.correctIpsi trialIdInfo.incorrectContra trialIdInfo.incorrectIpsi];
    
    tsPeths = eventsPeth(curTrials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames);
% %     h = figuree(150*numel(useEvents)+300,200);
    h = figuree(1200,250);
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
        plot([-tWindow tWindow],[n_incorrectContra n_incorrectContra],'k-','lineWidth',1.5);
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
% %         if iEvent == 6 && iNeuron == 188 % !!! special case
% %             cur_xlim = xlim;
% %             for iTrial = 1:numel(trialIds)
% %                 sideOutDir = R0142_1209_sideOutDir(trialIds(iTrial));
% %                 marker = '>';
% %                 if sideOutDir == 2
% %                     marker = '<';
% %                 end
% %                 plot(cur_xlim(sideOutDir),iTrial,marker,'MarkerFaceColor',colors(sideOutDir,:),'MarkerEdgeColor','none','markerSize',5);
% %             end
% %             contraTrials = [trialIdInfo.correctContra trialIdInfo.incorrectContra];
% %             contraSideOuts = R0142_1209_sideOutDir(contraTrials);
% %             ipsiTrials = [trialIdInfo.correctIpsi trialIdInfo.incorrectIpsi];
% %             ipsiSideOuts = R0142_1209_sideOutDir(ipsiTrials);
% %             disp([num2str(100*sum(contraSideOuts == 1)/numel(contraSideOuts),'%2.2f'),'% contra Nose Out/Side Out agreement']);
% %             disp([num2str(100*sum(ipsiSideOuts == 2)/numel(ipsiSideOuts),'%2.2f'),'% ipsi Nose Out/Side Out agreement']);
% %         end
        
        plot([0 0],ylim,'k--'); % zero line
        title(eventFieldlabels{iEvent});
        set(gca,'fontSize',16);
        box off;
    end
    set(gcf,'color','w');

    noteText = {['Unit: ',num2str(iNeuron)],['dirSel? ',note_dirSel],['at NO? ',note_dirSelNO],['at SO? ',note_dirSelSO]};
    addNote(h,noteText);
    
% %     tightfig;
    
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
        saveas(h,fullfile(saveDir,['ipsiContraRaster_u',num2str(iNeuron,'%03d'),'_NO-',note_dirSelNO,'_SO-',note_dirSelSO,saveExt]));
        close(h);
    end
end