rows = 3;
cols = numel(eventFieldnames);

tWindow = 1;
curRow = 1;
eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    disp(['Working on ',neuronName]);
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    if ~exist('sessionConf','var') || ~strcmp(sessionConf.sessions__name,analysisConf.sessionConfs{iNeuron})
        sessionConf = analysisConf.sessionConfs{iNeuron};
        % load nexStruct.. I don't love using 'load'
        nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
        if exist(nexMatFile,'file')
            disp(['Loading ',nexMatFile]);
            load(nexMatFile);
        else
            error('No NEX .mat file');
        end
    end
        
    logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
    logData = readLogData(logFile);
    if strcmp(neuronName(1:5),'R0154')
        nexStruct = fixMissingEvents(logData,nexStruct);
    end
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    timingField = 'pretone';
    [trialIds,allTimes] = sortTrialsBy(trials,timingField); % forces to be 'correct'
    
    % load timestamps for neuron
    for iNexNeurons = 1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron})
            disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
            ts = nexStruct.neurons{iNexNeurons}.timestamps;
% %             [tsISI,tsLTS,tsPoisson] = tsBurstFilters(ts);
% %             Lia = ismember(ts,tsISI);
% %             tsISIInv = ts(~Lia);
        end
    end
    
    tsPeths = eventsPeth(trials(trialIds),ts,tWindow,eventFieldnames);
    
    if iNeuron == 1
        h1 = figure('position',[0 0 1200 800]);
        iSubplot = 1;
    end
    for iEvent = 1:numel(eventFieldnames)
        ax = subplot(rows,cols,iSubplot);
        rasterData = tsPeths(:,iEvent);
        rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
        rasterData = makeRasterReadable(rasterData,75); % limit to 100 data points
        plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
        if iEvent == 1
            ylabel({'tsAll','Trials'});
        else
            set(ax,'yTickLabel',[]);
        end
        xlim([-1 1]);
        set(ax,'FontSize',fontSize);
        hold on;
        plot([0 0],[0 size(rasterData,1)],':','color','red'); % center line
        if iEvent == 1
            title({neuronName,eventFieldnames{iEvent}},'HorizontalAlignment','left','interpreter','none');
        else
             title({'',eventFieldnames{iEvent}},'HorizontalAlignment','center','interpreter','none');
        end
    %     set(ax,'XTickLabel',[]);
        iSubplot = iSubplot + 1;
    end
    
    % print, reset figure
    if curRow == rows || iNeuron == size(analysisConf.neurons,1)
        curRow = 1;
        iSubplot = 1;
        % print
        set(h1,'PaperPositionMode','auto'); 
        set(h1,'PaperOrientation','landscape');
        print('-bestfit','-r150')
        
        close(h1);
        h1 = figure('position',[0 0 1200 800]);
    else
        curRow = curRow + 1;
    end
end