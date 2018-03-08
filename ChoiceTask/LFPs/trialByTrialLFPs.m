% --- START INIT
doSetup = false;
if doSetup
    nasPath = '/Users/mattgaidica/Documents/Data/ChoiceTask';
    analysisConf = exportAnalysisConfv3({'R0117'},nasPath);
end

iNeuron = 1;
useEvents = 1:7;
% % lfpChannel = 93;
fpass = [10 40];
nTicks = 1;
nFreqs = 50;
freqList = logFreqList(fpass,nFreqs);
decimateFactor = 10;%round(header.Fs / (fpass(2) * 10)); % 10x max filter freq
timingField = 'RT';
tWindow = 1;
t = linspace(-tWindow,tWindow,nFreqs);
eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
fontSize = 6;
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
end
% --- END LOAD SESSION

% caxisVals = [3.2129    7.1162];
caxisVals = [4 6];
if true
    [eventScalograms,allLfpData] = eventsScalo(trials(trialIds),sevFilt,tWindow,Fs,freqList,{eventFieldnames{useEvents}});
    rows = 1;
    cols = size(eventScalograms,1);
    figuree(120*cols,200);
    iSubplot = 1;
    for iEvent = 1:size(eventScalograms,1)
        ax = subplot(rows,cols,iSubplot);
        scaloData = log(squeeze(eventScalograms(iEvent,:,:)));
        imagesc(t,freqList,scaloData);
        title(eventFieldnames{iEvent});

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
        xlim([-tWindow tWindow]);
        xticks([-tWindow 0 tWindow]);

        set(ax,'TickDir','out');
        set(ax,'FontSize',fontSize);
        colormap(jet);
%         caxis(caxisVals);

        iSubplot = iSubplot + 1;
    end
end

cols = numel(useEvents);
rows = 50;%numel(allTimes);
h = figuree(120*cols,700);
caxisVals = [4 7];
iSubplot = 1;
noseOutVals = [];

for iTrial = 1:numel(trialIds)
    curTrialId = trialIds(iTrial);
    curTrial = trials(curTrialId);
    [eventScalograms,allLfpData] = eventsScalo(curTrial,sevFilt,tWindow,Fs,freqList,{eventFieldnames{useEvents}});
    
    if mod(iTrial,rows) == 0
        h = figuree(120*cols,700);
        iSubplot = 1;
    end

    for iEvent = 1:numel(useEvents)
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
        xlim([-tWindow tWindow]);
        xticks([-tWindow 0 tWindow]);

        set(ax,'TickDir','out');
        set(ax,'FontSize',fontSize);
        colormap(jet);
        caxis(caxisVals);

        iSubplot = iSubplot + 1;
    end
end
% tightfig;

if false
    figuree(800,300);
    for iEvent = 1:numel(eventFieldnames)
        subplot(1,7,iEvent);
        plot(allTimes,noseOutVals(iEvent,:),'k.','markerSize',20);
        [rho,pval] = corr(allTimes',noseOutVals(iEvent,:)');
        title({['rho: ',num2str(rho,3)],['pval: ',num2str(pval)]});
    end
end