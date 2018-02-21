atlas_ims = [];
all_atlas_ims = {};
sessionCount = 1;
lastSession = [];
sessionNames = {};
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    if ~isempty(lastSession) && ~strcmp(lastSession,sessionConf.sessions__name)
        all_atlas_ims{sessionCount} = atlas_ims;
        sessionNames{sessionCount} = lastSession;
        atlas_ims = [];
        sessionCount = sessionCount + 1;
    end
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channelData = sessionConf.session_electrodes(any(rows')',:);
    if ~isempty(channelData)
        AP = channelData{1,'ap'};
        ML = channelData{1,'ml'};
        DV = channelData{1,'dv'};
        if channelData{1,'region_id'} == 37
            dotColor = 'green';
        else
            dotColor = 'red';
        end
        [atlas_ims,k] = plotMthalElectrode(atlas_ims,AP,ML,DV,nasPath,dotColor);
        lastSession = sessionConf.sessions__name;
    end
end
if ~isempty(lastSession) && ~strcmp(lastSession,sessionConf.sessions__name)
    all_atlas_ims{sessionCount} = atlas_ims;
end

rowsPerFig = 4;
iSubplot = 1;
for iSession = 1:numel(all_atlas_ims)
    if iSubplot == 1
        figure('position',[0 0 900 1200]);
    end
    
    for ii = 1:3
        subplot(rowsPerFig,3,iSubplot);
        session_ims = all_atlas_ims{iSession};
        imshow(session_ims{ii});
        title(sessionNames{iSession},'interpreter','none');
        iSubplot = iSubplot + 1;
    end
    
    if iSubplot > rowsPerFig * 3
        iSubplot = 1;
    end
end