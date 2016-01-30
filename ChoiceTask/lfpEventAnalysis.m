function [lfpEventData,t,freqList,eventFieldnames] = lfpEventAnalysis(analysisConf)

decimateFactor = 10;
scalogramWindow = 2; % seconds
plotEventIdx = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
fpass = [1 100];
lfpEventData = {};
            
for iNeuron=1:size(analysisConf.neurons,1)
    disp(['Working on ',analysisConf.neurons{iNeuron}]);
    
    [tetrodeName,tetrodeId] = getTetrodeInfo(analysisConf.neurons{iNeuron});
    % save time if the sessionConf is already for the correct session
    if ~exist('sessionConf','var') || ~strcmp(sessionConf.sessionName,analysisConf.sessionNames{iNeuron})
        sessionConf = exportSessionConf(analysisConf.sessionNames{iNeuron},'nasPath',analysisConf.nasPath);
        leventhalPaths = buildLeventhalPaths(sessionConf);
        fullSevFiles = getChFileMap(leventhalPaths.channels);
    end
    nexMatFile = [sessionConf.nexPath,'.mat'];
    if exist(nexMatFile)
        load(nexMatFile);
    else
        error('No NEX .mat file');
    end

    logFile = getLogPath(leventhalPaths.rawdata);
    logData = readLogData(logFile);
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    correctTrials = find([trials.correct]==1);
    
    disp(['Reading from ',tetrodeName]);
    
    lfpChannel = sessionConf.lfpChannels(tetrodeId);
    [sev,header] = read_tdt_sev(fullSevFiles{sessionConf.chMap(5,lfpChannel+1)});
    sev = decimate(double(sev),decimateFactor);
    Fs = header.Fs/decimateFactor;
    scalogramWindowSamples = round(scalogramWindow * Fs);
    allScalograms = [];
    for iField=plotEventIdx
        for iTrial=correctTrials
            eventFieldnames = fieldnames(trials(iTrial).timestamps);
            eventTs = getfield(trials(iTrial).timestamps, eventFieldnames{iField});
            eventSample = round(eventTs * Fs);
            data(:,iTrial) = sev((eventSample - scalogramWindowSamples):(eventSample + scalogramWindowSamples - 1));
        end
        [W, freqList] = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'fpass',fpass);
        allScalograms(iField,:,:) = squeeze(mean(abs(W).^2, 2))';
    end
    t = [0:size(W,1)-1]./Fs;
    
    lfpEventData{iNeuron} = allScalograms;
    
%     for iField=plotEventIdx
%         figure;
%         imagesc(t,freqList,log(squeeze(allScalograms(iField,:,:))))
%         ylabel('Frequency (Hz)')
%         xlabel('Time (s)');
%         set(gca, 'YDir', 'normal')
%         colormap(jet);
%         title([eventFieldnames{iField}]);
%     end
        
end