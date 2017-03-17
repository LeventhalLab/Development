% % nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
% % analysisConf = exportAnalysisConfv2('R0088',nasPath);

% compiles all waveforms by averaging all waveforms
% compileOFSWaveforms(waveformDir);
% compares some of the unit properties in a scatter plot
% compareOFSWaveforms(csvWaveformFiles);
tWindow = 2; % for scalograms, xlim is set to -1/+1 in formatting
plotEventIds = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
sevFile = '';
longRasters = {};
longRasterTimes = [];
shortRasters = {};
shortRasterTimes = [];

all_zMean = [];
all_zStd = [];
for iNeuron=1:size(analysisConf.neurons,1)
    fpass = [10 100];
    freqList = logFreqList(fpass,30);
    
    neuronName = analysisConf.neurons{iNeuron};
    disp(['Working on ',neuronName]);
% %     [electrodeName,electrodeSite,electrodeChannels] =
% getElectrodeInfo(neuronName) !!! fix function for 50um filenames
    
    % only load different sessions
    if ~exist('sessionConf','var') || ~strcmp(sessionConf.sessions__name,analysisConf.sessionConfs{iNeuron})
        sessionConf = analysisConf.sessionConfs{iNeuron};
        isNewSession = true;
        % load nexStruct.. I don't love using 'load'
        nexMatFile = [sessionConf.leventhalPaths.nex,'.mat'];
        if exist(nexMatFile,'file')
            disp(['Loading ',nexMatFile]);
            load(nexMatFile);
        else
            error('No NEX .mat file');
        end
    else
        isNewSession = false;
    end
    
    logFile = getLogPath(sessionConf.leventhalPaths.rawdata);
    logData = readLogData(logFile);
    trials = createTrialsStruct_simpleChoice(logData,nexStruct);
    timingField = 'RT';
    [trialIds,allTimes] = sortTrialsBy(trials,timingField); % forces to be 'correct'
    
    % load timestamps for neuron
    for iNexNeurons=1:length(nexStruct.neurons)
        if strcmp(nexStruct.neurons{iNexNeurons}.name,analysisConf.neurons{iNeuron})
            disp(['Using timestamps from ',nexStruct.neurons{iNexNeurons}.name]);
            ts = nexStruct.neurons{iNexNeurons}.timestamps;
            [tsISI,tsLTS,tsPoisson] = tsBurstFilters(ts);
            Lia = ismember(ts,tsISI);
            tsISIInv = ts(~Lia);
        end
    end

    % load SEV file and filter it for LFP analyses
    needsLfp = false;
    if needsLfp
        % !!! needs fix to handle 50um and tetrodes
        [a,b] = regexp(neuronName,'_ch[0-9]+');
        electrodeSite = str2num(neuronName(a+3:b));
        rows = sessionConf.session_electrodes.site == electrodeSite;
        channels = sessionConf.session_electrodes.channel(rows);
        lfpChannel = channels(1);

        if ~exist('sevFile','var') || ~strcmp(sevFile,sessionConf.sevFiles{lfpChannel})
            sevFile = sessionConf.sevFiles{lfpChannel};
            [sev,header] = read_tdt_sev(sevFile);
            decimateFactor = 1;%round(header.Fs / (fpass(2) * 10)); % 10x max filter freq
% %             sevFilt = decimate(double(sev),decimateFactor);
            sevFilt = double(sev);
% %             Fs = header.Fs / decimateFactor;
            Fs = header.Fs;
        end
    end
    
    % ----- ANALYSIS START -----
    
    % produces waveform and ISI xcorr analyses
    if isNewSession
% %         makeUnitSummaries();
    end
    
    % timing raster investigation
    tsPeths = eventsPeth(trials(trialIds),ts,tWindow);
% %     tsISIInvPeths = eventsPeth(trials(trialIds),tsISIInv,tWindow);
% %     tsISIPeths = eventsPeth(trials(trialIds),tsISI,tWindow);
% %     tsLTSPeths = eventsPeth(trials(trialIds),tsLTS,tWindow);
% %     tsPoissonPeths = eventsPeth(trials(trialIds),tsPoisson,tWindow);
    
    iEvent = 3; % centerOut
    rasterData = tsPeths(:,iEvent);
    [zMean,zStd] = meanPETZ(rasterData,tWindow);
    all_zMean(iNeuron,:) = zMean;
    all_zStd(iNeuron,:) = zStd;

% %     longRasterData = rasterData(allTimes > .4);
% %     if ~isempty(longRasterData)
% %         longRasters = [longRasters;longRasterData];
% %         longRasterTimes = [longRasterTimes;allTimes(allTimes > .4)'];
% %     end
% %     shortRasterData = rasterData(allTimes < .2);
% %     if ~isempty(shortRasterData)
% %         shortRasters = [shortRasters;shortRasterData];
% %         shortRasterTimes = [shortRasterTimes;allTimes(allTimes < .2)'];
% %     end
    
    % event-centered analysis
% %     tsPeths = eventsPeth(trials(trialIds),ts,tWindow);
% %     tsISIInvPeths = eventsPeth(trials(trialIds),tsISIInv,tWindow);
% %     tsISIPeths = eventsPeth(trials(trialIds),tsISI,tWindow);
% %     tsLTSPeths = eventsPeth(trials(trialIds),tsLTS,tWindow);
% %     tsPoissonPeths = eventsPeth(trials(trialIds),tsPoisson,tWindow);
% %     [eventScalograms,eventFieldnames,allLfpData] = eventsScalo(trials(trialIds),sevFilt,tWindow,Fs,freqList);
% %     t = linspace(-tWindow,tWindow,size(eventScalograms,3));
% %     eventAnalysis(); % format
    
    % scalograms based on different ts bursts separated by low-med-high
    % spike density
% %     tsScalograms = tsScalogram(ts,sevFilt,tWindow,Fs,freqList);
% %     t = linspace(-tWindow,tWindow,size(tsScalograms,3)); % set one for all
% %     tsISIScalograms = tsScalogram(tsISI,sevFilt,tWindow,Fs,freqList);
% %     tsLTSScalograms = tsScalogram(tsLTS,sevFilt,tWindow,Fs,freqList);
% %     tsPoissonScalograms = tsScalogram(tsPoisson,sevFilt,tWindow,Fs,freqList);
% %     allTsScalograms = {tsScalograms,tsISIScalograms,tsLTSScalograms,tsPoissonScalograms};
% %     allScalogramTitles = {'ts','tsISI','tsLTS','tsPoisson'};
% %     tsPrctlScalos(); % format
    
% %     % high beta power centered analysis using ts raster
% %     fpass = [13 30];
% %     tWindow = 1; % [] need to standardize time windows somehow
% %     fieldname = 'centerOut';
% %     [rasterTs,rasterEvents,allTs,allEvents] = lfpRaster(trials,trialIds,fieldname,ts,sev,header.Fs,fpass,tWindow);
% %     lfpRasters(); % format

% % run_RTraster()
end

addUnitHeader(analysisConf,{'eventAnalysis'});