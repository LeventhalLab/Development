% % unitEvents = corr_unitEvents;
% % all_zscores = corr_all_zscores;
% trialTypes = {'correctContra','correctIpsi'};
% useEvents = 1:7;
% tWindow = 1;
% [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,ts_all,eventFieldnames,tWindow,binMs,trialTypes,useEvents);
imsc = [];
useSubjects = [88,117,142,154,182];
% useSubjects = [182];

% compile event classes
neuronClasses = {};
for iEvent = 1:numel(eventFieldnames)
    neuronClasses{iEvent} = [];
    for iNeuron = 1:numel(analysisConf.neurons)
        sessionConf = analysisConf.sessionConfs{iNeuron};
        if isempty(unitEvents{iNeuron}.class) || ~ismember(sessionConf.subjects__id,useSubjects)
            continue;
        end
        if unitEvents{iNeuron}.class(1) == iEvent
            neuronClasses{iEvent} = [neuronClasses{iEvent} iNeuron];
        end
    end
end

% sort those event classes
sorted_neuronClasses = {};
for iEvent = 1:numel(eventFieldnames)
    curEvent_maxbins = [];
    cur_neuronClasses = neuronClasses{iEvent};
    for iNeuron = 1:numel(cur_neuronClasses)
        neuronId = cur_neuronClasses(iNeuron);
        curEvent_maxbins(iNeuron) = unitEvents{neuronId}.maxbin(iEvent);
    end
    [v,k] = sort(curEvent_maxbins);
    sorted_neuronClasses{iEvent} = cur_neuronClasses(k);
end

% remap neuronIds
sorted_neuronIds = [];
markerLocs = [0];
for iEvent = 1:numel(eventFieldnames)
    sorted_neuronIds = [sorted_neuronIds sorted_neuronClasses{iEvent}];
    markerLocs = [markerLocs numel(sorted_neuronIds)];
end

figuree(1200,800);
for iEvent = 1:numel(eventFieldnames)
    subplot(1,numel(eventFieldnames),iEvent);
    imagesc(squeeze(all_zscores(sorted_neuronIds,iEvent,:)));
%     imagesc(squeeze(all_zscores(:,iEvent,:))); % in session order
    caxis([-1 3]);
    xlim([1 size(all_zscores,3)]);
    xticks([1 round(size(all_zscores,3)/2) size(all_zscores,3)]);
    xticklabels({'-1','0','1'});
    yticks([1 numel(analysisConf.neurons)]);
    colormap jet;
    title(['corr_',eventFieldnames{iEvent}],'interpreter','none');
    hold on;
    plot([round(size(all_zscores,3)/2) round(size(all_zscores,3)/2)],[1 numel(analysisConf.neurons)],'k--');
    markerRange = markerLocs(iEvent)+1:markerLocs(iEvent+1);
    plot(ones(numel(markerRange),1),markerRange,'k.','MarkerSize',20);
%     markerRange = markerLocs(iEvent)+1:markerLocs(iEvent+1);
%     plot(ones(numel(markerRange),1),markerRange,'r.','MarkerSize',10);
end

if false
    % incorrect 
    figuree(1200,800);
    for iEvent = 1:numel(eventFieldnames)
        subplot(1,numel(eventFieldnames),iEvent);
        imagesc(squeeze(incorr_all_zscores(sorted_neuronIds,iEvent,:)));
        caxis([-3 8]);
        xlim([1 40]);
        xticks([1 20 40]);
        xticklabels({'-1','0','1'});
        yticks([1 numel(analysisConf.neurons)]);
        colormap jet;
        title(['incorr_',eventFieldnames{iEvent}],'interpreter','none');
        hold on;
        plot([20 20],[1 numel(analysisConf.neurons)],'k--');
        markerRange = markerLocs(iEvent)+1:markerLocs(iEvent+1);
        plot(ones(numel(markerRange),1),markerRange,'k.','MarkerSize',20);
    %     markerRange = markerLocs(iEvent)+1:markerLocs(iEvent+1);
    %     plot(ones(numel(markerRange),1),markerRange,'r.','MarkerSize',10);
    end

    % correct - incorrect 
    figuree(1200,800);
    for iEvent = 1:numel(eventFieldnames)
        subplot(1,numel(eventFieldnames),iEvent);
        imagesc(squeeze(all_zscores(sorted_neuronIds,iEvent,:)) - squeeze(incorr_all_zscores(sorted_neuronIds,iEvent,:)));
        caxis([-3 8]);
        xlim([1 40]);
        xticks([1 20 40]);
        xticklabels({'-1','0','1'});
        yticks([1 numel(analysisConf.neurons)]);
        colormap jet;
        title(['diff_',eventFieldnames{iEvent}],'interpreter','none');
        hold on;
        plot([20 20],[1 numel(analysisConf.neurons)],'k--');
        markerRange = markerLocs(iEvent)+1:markerLocs(iEvent+1);
        plot(ones(numel(markerRange),1),markerRange,'k.','MarkerSize',20);
    %     markerRange = markerLocs(iEvent)+1:markerLocs(iEvent+1);
    %     plot(ones(numel(markerRange),1),markerRange,'r.','MarkerSize',10);
    end
end