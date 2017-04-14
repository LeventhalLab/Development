figure('position',[0 0 800 800]);
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    rows = sessionConf.session_electrodes.channel == electrodeChannels;
    channelData = sessionConf.session_electrodes(rows,:);
    if isempty(channelData)
        continue;
    end
    
    ts = all_ts{iNeuron};
    sessionFR = 1 / mean(diff(ts));
    sessionCV = std(diff(ts)) / mean(diff(ts));
    AP = channelData{1,'ap'};
    ML = channelData{1,'ml'};
    DV = channelData{1,'dv'};
    
    subplot(2,3,1);
    hold on; grid on;
    plot(AP,sessionFR,'r*');
    title('AP');
    subplot(2,3,4);
    hold on; grid on;
    plot(AP,sessionCV,'r*');
    
    subplot(2,3,2);
    hold on; grid on;
    plot(ML,sessionFR,'r*');
    title('ML');
    subplot(2,3,5);
    hold on; grid on;
    plot(ML,sessionCV,'r*');
    
    subplot(2,3,3);
    hold on; grid on;
    plot(DV,sessionFR,'r*');
    title('DV');
    subplot(2,3,6);
    hold on; grid on;
    plot(ML,sessionCV,'r*');
end