load('session_20180707_MachineLearning.mat', 'LFPfiles_local')
load('session_20180707_MachineLearning.mat', 'all_trials')
load('session_20180707_MachineLearning.mat', 'eventFieldnames')

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/MachineLearning/trainingData250msMT';
sevFile = '';
freqList = logFreqList([3.5 200],30);
timingField = 'MT';
decimateFactor = 10;
Wlength = 200;
cLims = [-10 10];
trialCount = 0;
idTimes = [];
for iNeuron = 1:numel(LFPfiles_local)
    % only unique sev files
    if strcmp(sevFile,LFPfiles_local{iNeuron})
        continue;
    end
    disp(num2str(iNeuron,'%03d'));
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    [sev,header] = read_tdt_sev(sevFile);
    sevDec = decimate(double(sev),decimateFactor);
    Fs = header.Fs / decimateFactor;
    curTrials = all_trials{iNeuron};
    [trialIds,allTimes] = sortTrialsBy(curTrials,timingField);
    W = eventsLFPv2(curTrials(trialIds),sevDec,[0.25,1],Fs,freqList,eventFieldnames);
    Wz = zScoreW(W,Wlength);
    
    for iTrial = 1:size(Wz,3)
        trialCount = trialCount + 1;
        for iEvent = 1:7
            idTimes(trialCount) = allTimes(iTrial);
            thisWz = squeeze(Wz(iEvent,:,iTrial,:));
            BW = normalize(fliplr(thisWz)');
            imwrite(BW,fullfile(savePath,['u',num2str(iNeuron,'%03d'),'_e',num2str(iEvent),'_t',num2str(iTrial,'%03d'),...
                '_',timingField,num2str(round(allTimes(iTrial)*1000),'%04d'),'_id',num2str(trialCount,'%05d'),'.jpg']));
        end
        disp(num2str(trialCount,'%05d'));
    end

% %             scaloData = W(iEvent,:,useTrials,:);
% %             scaloData = squeeze(scaloData);
% %             scaloData = circ_r(angle(scaloData),[],[],2);
% %             scaloData = mean(scaloData,2);
% %             scaloData = squeeze(scaloData);
end