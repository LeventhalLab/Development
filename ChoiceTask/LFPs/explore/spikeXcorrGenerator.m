% load('session_20181218_highresEntrainment.mat', 'LFPfiles_local')
% load('session_20181218_highresEntrainment.mat','dirSelUnitIds','ndirSelUnitIds','primSec')
% load('session_20181218_highresEntrainment.mat', 'eventFieldnames')
% load('session_20181218_highresEntrainment.mat', 'LFPfiles_local_altLookup')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'all_ts')

doSetup = true;
doAlt = true;
doWrite = true;

freqList = logFreqList([1 200],30);
loadedFile = [];
minFR = 5;
maxTrialTime = 20; % seconds

if doSetup
    xcorrUnits = [];
    for iNeuron = 1:numel(all_ts)
        sevFile = LFPfiles_local{iNeuron};
        disp(['--> iNeuron ',num2str(iNeuron)]);
        ts = all_ts{iNeuron};
        FR = numel(ts) / max(ts);
        if FR < minFR
            disp(['skipping at ',num2str(FR,2),' Hz']);
            continue;
        end
        xcorrUnits = [xcorrUnits iNeuron];
        % replace with alternative for LFP
        if doAlt
            sevFile = LFPfiles_local_altLookup{strcmp(sevFile,{LFPfiles_local_altLookup{:,1}}),2};
        end
        % only load unique sessions
        if isempty(loadedFile) || ~strcmp(loadedFile,sevFile)
            [sevFilt,Fs,decimateFactor,loadedFile] = loadCompressedSEV(sevFile,[]);
            trials = all_trials{iNeuron};
            [trialIds,allTimes] = sortTrialsBy(trials,'RT');
            [intrialTimeRanges,intertrialTimeRanges] = compileTrialTimeRanges(trials,maxTrialTime);
            intrialTimeRanges = intrialTimeRanges(trialIds,:);
            intrialTimeRanges(isnan(sum(intrialTimeRanges,2)),:) = []; % clear NaNs
            intertrialTimeRanges(isnan(sum(intertrialTimeRanges,2)),:) = []; % clear NaNs
            
            W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList); % size: 5568092, 1, 3
            W = squeeze(W);
        end
        % build or load SDE here
        
        [~,k] = sort(diff(intrialTimeRanges,1,2));
        intrialTimeRanges = intrialTimeRanges(k,:);
        [~,k] = sort(diff(intertrialTimeRanges,1,2));
        intertrialTimeRanges = intertrialTimeRanges(k,:);
        
        % sort time ranges (in and inter)
        % convert trial time to samples
        % there should be more inter-ids because of incorrect trials
        % pluck out intrial lengths from *middle* of intertrial segment
        
        % !! Wpower has to be z-scored if it's chopped up
        % extract Z-power and SDE segments
    end
end