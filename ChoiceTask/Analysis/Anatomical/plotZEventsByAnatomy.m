trialTypes = {'correctContra','correctIpsi'};
[unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,nBins_tWindow,trialTypes);

% shapes: vm, va, vl, ret
shapesLabels = {'vm','va','vl','ret'};
useEvents = [1:7];
colors = lines(5);
lgdMarkers = [];
figuree(1300,400);
lns = [];
lnsi = 1;
all_shapeIds = [];
useSubjects = [142];
for iShape = 0:4
    shape_zscores = [];
    iZs = 1;
    for iNeuron = 1:size(analysisConf.neurons,1)
        neuronName = analysisConf.neurons{iNeuron};
        subjects__name = neuronName(1:5);
        sessionConf = analysisConf.sessionConfs{iNeuron};
        if ~ismember(sessionConf.subjects__id,useSubjects)
            continue;
        end
        [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
        rows = sessionConf.session_electrodes.channel == electrodeChannels;
        channelData = sessionConf.session_electrodes(any(sum(rows,2)),:);

        if isempty(channelData)
            continue;
        end
        AP = channelData{1,'ap'};
        ML = channelData{1,'ml'};
        DV = channelData{1,'dv'} * -1;
        
% %         plot3(AP,ML,DV,'.','MarkerSize',30,'color',colors(iShape,:));
% %         hold on;

        shapeId = testAnatomyShapes(shapes,ML,AP,DV);
        all_shapeIds = [all_shapeIds shapeId];
        if shapeId == iShape
            shape_zscores(iZs,:,:) = all_zscores(iNeuron,:,:);
            iZs = iZs + 1;
        end
    end
    if isempty(shape_zscores)
        continue;
    end
    for iEvent = 1:7
        subplot(1,7,iEvent);
        lns(lnsi) = plot(smooth(squeeze(mean(shape_zscores(:,iEvent,:))),3),'color',colors(iShape+1,:),'LineWidth',2);
        hold on;
        title(eventFieldnames{iEvent});
        ylim([-1 3]);
        grid on;
    end
    lnsi = lnsi + 1;
end
legend(lns,{'N/A','BG','CB'});