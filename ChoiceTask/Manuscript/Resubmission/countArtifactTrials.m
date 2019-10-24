load('session_20180919_NakamuraMRL.mat', 'all_trials');
load('LFPfiles_local_matt');
eventFieldlabels = {'Cue','Nose In','Tone','Nose Out','Side In','Side Out','Reward'};

iSession = 0;
tWindow = 1;
freqList = logFreqList([1 200],30);
correctTrialCount = 0;
keepTrialCount = 0;
zThresh = 5;

for iNeuron = selectedLFPFiles(2)'
    iSession = iSession + 1;
    disp(['Session #',num2str(iSession)]);

    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    curTrials = all_trials{iNeuron};
    [trialIds,allTimes] = sortTrialsBy(curTrials,'RT'); % returns correct only

    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
%     sevFilt = artifactThresh(sevFilt,[1],2000);
    sevFilt = sevFilt - mean(sevFilt);
    [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    [keepTrials,data,zmean,zstd,ztrials] = threshTrialData(all_data,zThresh);
    
    correctTrialCount = correctTrialCount + numel(allTimes);
    keepTrialCount = keepTrialCount + numel(keepTrials);
    
    if numel(allTimes) ~= numel(keepTrials)
        disp(['unmatched! iNeuron:',num2str(iNeuron),', iSession:',num2str(iSession)]);
    end
end
disp(['correct trials: ',num2str(correctTrialCount)]);
disp(['keep trials: ',num2str(keepTrialCount)]);

% playground
% reject trial 14 of session 2

zLabels = {'Rejected Trial','Good Trial'};
useTrials = [14,15];
close all;
ff(1200,600);
rows = 2;
cols = 7;
t = linspace(-tWindow,tWindow,size(rdata,2));
for iRow = 1:2
    for iCol = 1:7
        subplot(rows,cols,prc(cols,[iRow,iCol]));
        rdata = all_data(:,:,useTrials(iRow));
        event_data = rdata(iCol,:);
        zdata = (event_data - zmean) ./ zstd;
        exceedsAt = abs(zdata) > zThresh;
        plot(t,zdata);
        hold on;
        plot(t(exceedsAt),zdata(exceedsAt),'rx');
        ylim([-6 6]);
        title(eventFieldlabels{iCol});
        set(gca,'fontsize',16);
        ffp();
        yticks(sort([ylim,-5,5]));
        xlabel('Time (s)');
        ylabel({zLabels{iRow},'Z'});
    end
end
% saveas rejectedTrialExample.png