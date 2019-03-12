% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
% load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
% load('RTMT_rawData.mat')

baseName = '201903_RTMTcorr_R0182_nSessions';

if ismac
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/RTMTCorr';
else
    savePath = 'C:\Users\dleventh\Documents\MATLAB\Development\ChoiceTask\LFPs';
end

doSetup = true;
doWrite = false;

timingFields = {'pretone','MT'};
tWindow = 1;
freqList = logFreqList([1 200],30);
Wlength = 200;
zThresh = 5;
% useSessions = 1:4; % R0088
% useSessions = 5:11; % R0117
% useSessions = 12:24; % R0142
useSessions = 25:29; % R0154
% useSessions = 30; % R0182
useFreqs = 1:numel(freqList);
useTiming = 1%:2;

% % % % nRT = 5;
% % % % rtBrackets = floor(linspace(1,numel(all_rt),nRT+1));
% % % % all_rt_sorted = sort(all_rt);
% % % % rtThreshs = all_rt_sorted(rtBrackets);
% % % % rtThreshs(end) = 1; % max out RT

% % % % for useSessions = 1:30 % to save individual sessions
if doSetup
% % % % all_RT_powerCorrs = {};
% % % % all_RT_powerPvals = {};
% % % % all_RT_phaseCorrs = {};
% % % % all_RT_phasePvals = {};
% % % % for iRT = 1:nRT
    all_powerCorrs = [];
    all_powerPvals = [];
    all_phaseCorrs = [];
    all_phasePvals = [];
    for iFreq = useFreqs
        iSession = 0;
        xTimes = [];
        yPower = [];
        yPhase = [];
        startIdx = ones(2,1);
        for iNeuron = selectedLFPFiles(useSessions)'
            iSession = iSession + 1;
% % % %             fprintf('iRT: %02d, iFreq: %02d, iNeuron: %03d\n',iRT,iFreq,iNeuron);
            fprintf('iFreq: %02d, iNeuron: %03d\n',iFreq,iNeuron);
            sevFile = LFPfiles_local{iNeuron};
            [~,name,~] = fileparts(sevFile);

            [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
            curTrials = all_trials{iNeuron};

            for iTiming = useTiming
                [trialIds,allTimes] = sortTrialsBy(curTrials,timingFields{iTiming});
                [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow*2,Fs,freqList(iFreq),eventFieldnames);

                keepTrials = threshTrialData(all_data,zThresh);
                W = W(:,:,keepTrials,:);
                [Wz,Wz_angle] = zScoreW(W,Wlength); % power Z-score
                allTimes = allTimes(keepTrials);
                
                % threshRT
% % % %                 keepRTs = find(allTimes >= rtThreshs(iRT) & allTimes < rtThreshs(iRT+1));
% % % %                 allTimes = allTimes(keepRTs);
% % % %                 Wz = Wz(:,:,keepRTs);
% % % %                 Wz_angle = Wz_angle(:,:,keepRTs);
                
                xTimes(iTiming,startIdx(iTiming):startIdx(iTiming) + numel(allTimes) - 1) = allTimes;
% %                 xTimes(iTiming,startIdx(iTiming):startIdx(iTiming) + numel(allTimes) - 1) = (allTimes - mean(allTimes)) ./ std(allTimes);
                for iTime = 1:size(Wz,2)
                    for iEvent = 1:7
                        yPower(iTiming,iTime,iEvent,startIdx(iTiming):startIdx(iTiming) + numel(allTimes) - 1) = squeeze(squeeze(Wz(iEvent,iTime,:)));
                        yPhase(iTiming,iTime,iEvent,startIdx(iTiming):startIdx(iTiming) + numel(allTimes) - 1) = squeeze(squeeze(Wz_angle(iEvent,iTime,:)));
                    end
                end

                startIdx(iTiming) = startIdx(iTiming) + numel(allTimes);
            end
        end
        
        powerCorrs = [];
        powerPvals = [];
        phaseCorrs = [];
        phasePvals = [];
        for iTiming = useTiming
            theseTimes = xTimes(iTiming,:);
            for iEvent = 1:7
                for iTime = 1:size(yPower,2)
                    thisPower = squeeze(yPower(iTiming,iTime,iEvent,:));
                    [rho,pval] = corr(theseTimes',thisPower,'Type','Spearman');
                    powerCorrs(iTiming,iEvent,iTime) = rho;
                    powerPvals(iTiming,iEvent,iTime) = pval;

                    thisPhase = squeeze(yPhase(iTiming,iTime,iEvent,:));
                    [rho,pval] = circ_corrcl(theseTimes',thisPhase); % (alpha,x)
                    phaseCorrs(iTiming,iEvent,iTime) = rho;
                    phasePvals(iTiming,iEvent,iTime) = pval;
                end
            end
        end
        all_powerCorrs(:,:,:,iFreq) = powerCorrs;
        all_powerPvals(:,:,:,iFreq) = powerPvals;
        all_phaseCorrs(:,:,:,iFreq) = phaseCorrs;
        all_phasePvals(:,:,:,iFreq) = phasePvals;
    end
% % % % all_RT_powerCorrs{iRT} = all_powerCorrs;
% % % % all_RT_powerPvals{iRT} = all_powerPvals;
% % % % all_RT_phaseCorrs{iRT} = all_phaseCorrs;
% % % % all_RT_phasePvals{iRT} = all_phasePvals;
% % % % end
end

% % save(fullfile(savePath,['201903_RTMTcorr_iSession',num2str(useSessions,'%02d'),'_nSessions',num2str(numel(useSessions),'%02d')]),...
% %     'all_powerCorrs','all_powerPvals','all_phaseCorrs','all_phasePvals');
if doWrite
    save(fullfile(savePath,[baseName,num2str(numel(useSessions),'%02d')]),...
        'all_powerCorrs','all_powerPvals','all_phaseCorrs','all_phasePvals');
end
% % % % end