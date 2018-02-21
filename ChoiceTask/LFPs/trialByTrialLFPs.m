% --- START INIT
doSetup = false;
if doSetup
    nasPath = '/Users/mattgaidica/Documents/Data/ChoiceTask';
    analysisConf = exportAnalysisConfv3({'R0117'},nasPath);
end

iNeuron = 1;
% % lfpChannel = 93;
fpass = [13 30];
nTicks = 1;
nFreqs = 30;
freqList = logFreqList(fpass,nFreqs);
decimateFactor = 10;%round(header.Fs / (fpass(2) * 10)); % 10x max filter freq
timingField = 'RT';
tWindow = 1;
t = linspace(-tWindow,tWindow,nFreqs);
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

% this is really not perfect yet, needs LFP channel in DB I think
rows = sessionConf.session_electrodes.channel == electrodeChannels;
channels = sessionConf.session_electrodes.channel(any(rows')');
lfpChannel = channels(1);
if ~exist('sevFile','var') || ~strcmp(sevFile,sessionConf.sevFiles{lfpChannel})
    sevFile = sessionConf.sevFiles{lfpChannel};
    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
    Fs = header.Fs / decimateFactor;
end
% --- END LOAD SESSION


if true
    [eventScalograms,allLfpData] = eventsScalo(trials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    rows = 1;
    cols = numel(eventFieldnames);
    figuree(800,200);
    iSubplot = 1;
    for iEvent = 1:numel(eventFieldnames)
        ax = subplot(rows,cols,iSubplot);
        scaloData = log(squeeze(eventScalograms(iEvent,:,:)));
        imagesc(t,freqList,scaloData);
        if iTrial == 1
            title(eventFieldnames{iEvent});
        end

        if iEvent == 1
            ylabel('Freq (Hz)');
            nTicks = 5;
            ytickVals = round(linspace(freqList(1),freqList(end),nTicks));
            ytickLabelVals = round(logFreqList(fpass,nTicks));
            yticks(ytickVals);
            yticklabels(ytickLabelVals);
        else
            set(ax,'yTickLabel',[]);
        end

        set(ax,'YDir','normal');
        xlim([-1 1]);
        xticks([]);

        set(ax,'TickDir','out');
        set(ax,'FontSize',fontSize);
        colormap(jet);
    % %     caxis(caxisVals);

        iSubplot = iSubplot + 1;
    end
end

h = figuree(900,700);
rows = numel(allTimes);
cols = numel(eventFieldnames);
caxisVals = [-5 8];
fontSize = 6;
iSubplot = 1;
noseOutVals = [];

for iTrial = 1:numel(trialIds)
    curTrialId = trialIds(iTrial);
    curTrial = trials(curTrialId);
    [eventScalograms,allLfpData] = eventsScalo(curTrial,sevFilt,tWindow,Fs,freqList,eventFieldnames);
    
    for iEvent = 1:numel(eventFieldnames)
        ax = subplot(rows,cols,iSubplot);
        scaloData = log(squeeze(eventScalograms(iEvent,:,:)));
        imagesc(t,freqList,scaloData);
        if iTrial == 1
            title(eventFieldnames{iEvent});
        end
            
        if iEvent == 1
            ylabel({'Freq (Hz)',num2str(allTimes(iTrial),3)});
            ytickVals = round(linspace(freqList(1),freqList(end),nTicks));
            ytickLabelVals = round(logFreqList(fpass,nTicks));
            yticks(ytickVals);
            yticklabels(ytickLabelVals);
        else
            set(ax,'yTickLabel',[]);
        end
        
        qtrSec = round((size(scaloData,2) / 2) / 4);
        noseOutVals(iEvent,iTrial) = mean(mean(scaloData(:,(size(scaloData,2)/2)-qtrSec:(size(scaloData,2)/2)+qtrSec)));
        
        set(ax,'YDir','normal');
        xlim([-1 1]);
        xticks([]);

        set(ax,'TickDir','out');
        set(ax,'FontSize',fontSize);
        colormap(jet);
        caxis(caxisVals);

        iSubplot = iSubplot + 1;
    end
end

figuree(800,300);
for iEvent = 1:numel(eventFieldnames)
    subplot(1,7,iEvent);
    plot(allTimes,noseOutVals(iEvent,:),'k.','markerSize',20);
    [rho,pval] = corr(allTimes',noseOutVals(iEvent,:)');
    title({['rho: ',num2str(rho,3)],['pval: ',num2str(pval)]});
end
    