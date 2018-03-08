if true
% --- START INIT
useSubject = 1;
subject__names = {'R0088','R0117','R0142','R0154','R0182'};
switch subject__names{useSubject}
    case 'R0088'
        lfpChannel = 42;
    case 'R0117'
        lfpChannel = 42;
    case 'R0142'
        lfpChannel = 42;
    case 'R0154'
        lfpChannel = 42;
    case 'R0182'
        lfpChannel = 42;
end

doSetup = true;
if doSetup
    nasPath = '/Users/mattgaidica/Documents/Data/ChoiceTask';
    analysisConf = exportAnalysisConfv3(subject__names{useSubject},nasPath);
end
iNeuron = 1;
lfpChannel = 42;
fpass = [1 80];
nFreqs = 30;
freqList = logFreqList(fpass,nFreqs);
decimateFactor = 10;
timingField = 'RT';
tWindow = 3;
eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
% --- END INIT


% --- START LOAD SESSION
neuronName = analysisConf.neurons{iNeuron};
[electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
if ~exist('sessionConf','var') || ~strcmp(sessionConf.sessions__name,analysisConf.sessionConfs{iNeuron})
    sessionConf = analysisConf.sessionConfs{iNeuron};
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
trials = createTrialsStruct_simpleChoice(logData,nexStruct);
[trialIds,allTimes] = sortTrialsBy(trials,timingField); % forces to be 'correct'
% trialIds = sort(trialIds);
% trialIds = find([trials.falseStart] == 1);

% this is really not perfect yet, needs LFP channel in DB I think
% % rows = sessionConf.session_electrodes.channel == electrodeChannels;
% % channels = sessionConf.session_electrodes.channel(any(rows')');
% % lfpChannel = channels(1);
if ~exist('sevFile','var') || ~strcmp(sevFile,sessionConf.sevFiles{lfpChannel})
    sevFile = sessionConf.sevFiles{lfpChannel};
    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
    Fs = header.Fs / decimateFactor;
    simpleFFT(sevFilt(1e6:end),Fs,true);
end
% --- END LOAD SESSION
allW = eventsLFP(trials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
end

tWindow_vis = 1;
t = linspace(-tWindow,tWindow,size(allW,2));

% build data arrays
scaloData = [];
phaseData = [];
for iFreq = 1:nFreqs
    for iEvent = 1:numel(eventFieldnames)
        freqData = squeeze(allW(iEvent,:,:,iFreq))';
        scaloData(iEvent,iFreq,:) = mean(abs(freqData));
%         scaloData(iEvent,iFreq,:) = (scaloData(iEvent,iFreq,:) - mean(squeeze(scaloData(1,iFreq,:)))') ./ std(squeeze(scaloData(1,iFreq,:))');
        phaseData(iEvent,iFreq,:) = deg2rad(meanangle(rad2deg(angle(freqData))));
    end
end

% plot data arrays
figuree(1200,500);
rows = 2;
iSubplot = 1;
for iEvent = 1:numel(eventFieldnames)
    ax = subplot(rows,numel(useEvents),iSubplot);
    imagesc(t,1:nFreqs,squeeze(scaloData(iEvent,:,:)));
    xlim([-tWindow_vis tWindow_vis]);
    xticks([-tWindow_vis 0 tWindow_vis]);
    yticks(1:nFreqs);
    yticklabels(freqList);
    set(ax,'YDir','normal');
    colormap(jet);
    grid on;

    if iEvent == 1
        ylabel('trials');
        caxisVals = getLimits(squeeze(scaloData(iEvent,:,:)),0.1,.99);
    end
    caxis(caxisVals);
    title(eventFieldnames{iEvent});
    iSubplot = iSubplot + 1;
end

for iEvent = 1:numel(eventFieldnames)
    ax = subplot(rows,numel(useEvents),iSubplot);
    imagesc(t,1:nFreqs,squeeze(phaseData(iEvent,:,:)));
    xlim([-tWindow_vis tWindow_vis]);
    xticks([-tWindow_vis 0 tWindow_vis]);
    yticks(1:nFreqs);
    yticklabels(freqList);
    set(ax,'YDir','normal');
    cmocean('phase');
    grid on;

    iSubplot = iSubplot + 1;
end
colorbar;