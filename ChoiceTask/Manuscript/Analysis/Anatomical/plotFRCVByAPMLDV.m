figure('position',[0 0 800 800]);
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channelData = sessionConf.session_electrodes(any(rows)',:);
    if isempty(channelData)
        continue;
    end
    
    ts = all_ts{iNeuron};
    sessionFR = 1 / mean(diff(ts));
    sessionCV = std(diff(ts)) / mean(diff(ts));
    AP = channelData{1,'ap'};
    ML = channelData{1,'ml'};
    DV = channelData{1,'dv'};
    
    if channelData{1,'region_id'} == 37
        dotColor = 'green';
    else
        dotColor = 'red';
    end
    
    subplot(2,3,1);
    hold on; grid on;
    plot(AP,sessionFR,'*','color',dotColor);
    title('AP');
    ylabel('FR');xlabel('mm');
    subplot(2,3,4);
    hold on; grid on;
    plot(AP,sessionCV,'*','color',dotColor);
    ylabel('CV');xlabel('mm');
    
    subplot(2,3,2);
    hold on; grid on;
    plot(ML,sessionFR,'*','color',dotColor);
    title('ML');
    ylabel('FR');xlabel('mm');
    subplot(2,3,5);
    hold on; grid on;
    plot(ML,sessionCV,'*','color',dotColor);
    ylabel('CV');xlabel('mm');
    
    subplot(2,3,3);
    hold on; grid on;
    plot(DV,sessionFR,'*','color',dotColor);
    title('DV');
    ylabel('FR');xlabel('mm');
    subplot(2,3,6);
    hold on; grid on;
    plot(DV,sessionCV,'*','color',dotColor);
    ylabel('CV');xlabel('mm');
end