% [ ] do all sessions
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/delta/unwrap';
doSetup = false;
doSave = true;
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
useSessions = [12:24];
% dataLabel = 'onlyR0142';

if doSetup
    dataArr = [];
    timeArr = [];
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
            for iTrial = 1:size(W,3)
                trialCount(iEvent) = trialCount(iEvent) + 1;
                if iEvent == 1
                    timeArr(trialCount(iEvent)) = allTimes(iTrial);
                end
                data = unwrap(angle(squeeze(W(iEvent,:,iTrial))));
                dataArr(iEvent,trialCount(iEvent),:) = (diff(data)); % removed abs
            end
        end
    end
end
% debug
if doDebug
    h = ff(400,800);
    subplot(311);
    plot(angle(squeeze(W(iEvent,:,iTrial))));
    xlim([1 numel(data)]);
    title('delta phase, single trial');

    subplot(312);
    plot(unwrap(angle(squeeze(W(iEvent,:,iTrial)))));
    xlim([1 numel(data)]);
    title('delta phase unwrapped');

    subplot(313);
    plot((diff(data.^2)));
    title('diff(unwrapped phase)');
    xlim([1 numel(data)]);
end

% save('20190410_unwrapDelta','dataArr','timeArr','dataLabel');
% save('20190410_unwrapDelta_notR0142','dataArr','timeArr','dataLabel');
% save('20190410_unwrapDelta_onlyR0142','dataArr','timeArr','dataLabel');

% close all
h = ff(1400,300);
rows = 1;
cols = 8;
t = linspace(-tWindow,tWindow,size(all_data,2)-1);
nTimes = 5;
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
        subplot(rows,cols,iEvent);
        medn = median(squeeze(dataArr(iEvent,useTrials,:))) - mean(median(squeeze(dataArr(8,useTrials,:))));
        lns(iTime) = plot(t,smooth(medn,nSmooth),'-','linewidth',2,'color',colors(iTime,:));
        hold on;
        ylim([-.0005 .0005]);
        yticks(sort([ylim,0]));
        xticks(sort([xlim,0]));
        title(eventFieldnames_wFake{iEvent});
        plot([0 0],ylim,'k:');
        grid on;
        if iEvent == 1
            ylabel('abs(diff(phase))');
        end
    end
end
legend(lns,timeLabels);

addNote(h,{'all sessions (2.5 Hz)','1. unwrap phase','2. Take diff(phase)','3. Plot median for all trials',...
    '.. normalized to mean(inter-trial)','','sorted by RT'});
set(gcf,'color','w');
if doSave
    saveas(h,fullfile(savePath,[dataLabel,'_deltaPhaseUnwrapped_n',num2str(nTimes),'.png']));
    close(h);
end