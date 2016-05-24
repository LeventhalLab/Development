% % iNeuron = 1;
decimateFactor = 20;
fpass = [10 200];
scalogramWindow = 0.5; % seconds
allPhaseLog = {};

% tsRand = (min(eventData.tsPoisson) + max(eventData.tsPoisson)-min(eventData.tsPoisson))*rand(length(eventData.tsPoisson),1);

for iNeuron=1:size(analysisConf.neurons,1)
    disp(['Working on ',analysisConf.neurons{iNeuron}]);
    eventData = burstEventData{iNeuron};

    [tetrodeName,tetrodeId] = getTetrodeInfo(analysisConf.neurons{iNeuron});
    % save time if the sessionConf is already for the correct session
    if ~exist('sessionConf','var') || ~strcmp(sessionConf.sessionName,analysisConf.sessionNames{iNeuron})
        sessionConf = exportSessionConf(analysisConf.sessionNames{iNeuron},'nasPath',analysisConf.nasPath);
        leventhalPaths = buildLeventhalPaths(sessionConf);
        fullSevFiles = getChFileMap(leventhalPaths.channels);
    end

    lfpChannel = sessionConf.lfpChannels(tetrodeId);
    sevFile = fullSevFiles{sessionConf.chMap(tetrodeId,lfpChannel+1)};

    disp(['Reading LFP (SEV file) for ',tetrodeName]);
    disp(sevFile);
    [sev,header] = read_tdt_sev(sevFile);
    sev = decimate(double(sev),decimateFactor);
    Fs = header.Fs/decimateFactor;

    scalogramWindowSamples = round(scalogramWindow * Fs);
    phaseLog = [];
    data = [];
    jj = 1;
    for ii=1:length(eventData.tsPoisson)
        eventSample = round((eventData.ts(ii) * header.Fs) / decimateFactor);
        if eventSample - scalogramWindowSamples <= 0 || eventSample + scalogramWindowSamples - 1 > length(sev)
            continue;
        else
            data(:,1) = sev((eventSample - scalogramWindowSamples):(eventSample + scalogramWindowSamples - 1));
            [W, freqList] = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'fpass',fpass);
            phaseLog(jj,:) = angle(squeeze(W(scalogramWindowSamples,:)));
            jj = jj + 1;
        end
    end
    allPhaseLog{iNeuron} = phaseLog;
end

% % [a,b] = sort(allPhaseLogPoisson{1}(:,40));
% % imagesc(allPhaseLogPoisson{1}(b,:)');
% % plot(mean(phaseLog));


figure;
for ii=1:length(allPhaseLog)
    hold on;
    plot(freqList,mean(allPhaseLog{ii}));
end