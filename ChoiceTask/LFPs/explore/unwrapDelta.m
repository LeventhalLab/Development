% [ ] do all sessions
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/delta/unwrap';
doSetup = false;
doSave = false;
doDebug = false;

if ~exist('selectedLFPFiles')
    load('session_20181106_entrainmentData.mat', 'selectedLFPFiles');
    load('session_20181106_entrainmentData.mat', 'eventFieldnames');
    load('session_20181106_entrainmentData.mat', 'LFPfiles_local');
    load('session_20181106_entrainmentData.mat', 'all_trials');
end

eventFieldnames_wFake = {eventFieldnames{:} 'interTrial'};
tWindow = 1;
zThresh = 5;
xlimVals = [-1 1];
freqList = 2.5;
useSessions = [1:30];
dataLabel = 'allSessions';
minpeakdist = 200;
minpeakh = 1e-4;

if doSetup
    dataArr = [];
    timeArr = [];
    locsCell = {};
    trialCount = zeros(8,1);
    for iSession = useSessions
        iNeuron = selectedLFPFiles(iSession);
        disp(num2str(iSession));
        sevFile = LFPfiles_local{iNeuron};
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        trials = all_trials{iNeuron};
        trials = addEventToTrials(trials,'interTrial');
        
        [trialIds,allTimes] = sortTrialsBy(trials,'RT');
        [W,all_data] = eventsLFPv2(trials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames_wFake);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        all_data = all_data(:,:,keepTrials);
        allTimes = allTimes(keepTrials);
        
        for iEvent = 1:8
            if numel(locsCell) < iEvent
                locsCell{iEvent} = []; % init
            end
            for iTrial = 1:size(W,3)
                trialCount(iEvent) = trialCount(iEvent) + 1;
                if iEvent == 1
                    timeArr(trialCount(iEvent)) = allTimes(iTrial);
                end
                data = diff(unwrap(angle(squeeze(W(iEvent,:,iTrial)))),2);
                [locs,pks] = peakseek(data,minpeakdist,minpeakh);
                locsCell{iEvent} = [locsCell{iEvent} locs];
                dataArr(iEvent,trialCount(iEvent),:) = data;
            end
        end
    end
end
% debug
if doDebug
    a = angle(squeeze(W(iEvent,:,iTrial)));
    h = ff(400,800);
    subplot(311);
    plot(a);
    xlim([1 numel(data)]);
    title('delta phase, single trial');

    subplot(312);
    plot(unwrap(a));
    xlim([1 numel(data)]);
    title('delta phase unwrapped');

    subplot(313);
    plot((diff(unwrap(a),2)));
    title('diff(unwrapped phase,2)');
    xlim([1 numel(data)]);
end

% save('20190410_unwrapDelta','dataArr','timeArr','dataLabel');
% save('20190410_unwrapDelta_notR0142','dataArr','timeArr','dataLabel');
% save('20190410_unwrapDelta_onlyR0142','dataArr','timeArr','dataLabel');

% close all
h = ff(1400,600);
rows = 2;
cols = 8;
t = linspace(-tWindow,tWindow,size(dataArr,3));
nTimes = 1;
colors = copper(nTimes);
timeMarks = round(linspace(1,numel(timeArr),nTimes+1));
sorted_timeArr = sort(timeArr);
timeValues = sorted_timeArr(timeMarks);
nSmooth = 100;
timeLabels = {};
lns = [];
for iTime = 1:nTimes
    useTrials = timeArr > timeValues(iTime) & timeArr < timeValues(iTime+1);
    timeLabels{iTime} = sprintf('%1.3f - %1.3f s',timeValues(iTime),timeValues(iTime+1));
    for iEvent = 1:cols
        subplot(rows,cols,prc(cols,[1 iEvent]));
        medn = mean(squeeze(dataArr(iEvent,useTrials,:)));% - mean(median(squeeze(dataArr(8,useTrials,:))));
        lns(iTime) = plot(t,smooth(medn,nSmooth),'-','linewidth',2,'color',colors(iTime,:));
        hold on;
%         ylim([-6e-7 6e-7]);
        yticks(sort([ylim,0]));
        xticks(sort([xlim,0]));
        title(eventFieldnames_wFake{iEvent});
        plot([0 0],ylim,'k:');
        grid on;
        if iEvent == 1
            ylabel('median diff(phase,2)');
        end
        
        subplot(rows,cols,prc(cols,[2 iEvent]));
        nBins = 21;
        counts = histcounts(locsCell{iEvent},nBins);
        bar(linspace(-1,1,nBins),counts,'k');
        ylabel('# phase shifts');
        ylim([0 60]);
        grid on;
        hold on;
        yticks(ylim);
        plot([0 0],ylim,'k:');
    end
    
end
legend(lns,timeLabels);

addNote(h,{'all sessions (2.5 Hz)','1. unwrap phase','2. Take diff(phase,2)','3. Plot median for all trials',...
    '','sorted by RT'});
set(gcf,'color','w');
if doSave
    saveas(h,fullfile(savePath,[dataLabel,'_deltaPhaseUnwrapped_n',num2str(nTimes),'.png']));
    close(h);
end