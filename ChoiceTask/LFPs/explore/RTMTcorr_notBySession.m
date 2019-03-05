% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
% load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')

if ismac
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/RTMTCorr';
else
     savePath = 'C:\Users\dleventh\Documents\MATLAB\Development\ChoiceTask\LFPs';
end

doSetup = true;

timingFields = {'RT','MT'};
tWindow = 1;
freqList = logFreqList([1 200],30);
Wlength = 200;
zThresh = 5;
% % useSessions = 1;

for useSessions = 1:30
if doSetup
    all_powerCorrs = [];
    all_powerPvals = [];
    all_phaseCorrs = [];
    all_phasePvals = [];
    for iFreq = 1:numel(freqList)
        iSession = 0;
        xTimes = [];
        yPower = [];
        yPhase = [];
        startIdx = ones(2,1);
        for iNeuron = selectedLFPFiles(useSessions)'
            iSession = iSession + 1;
            fprintf('iFreq: %02d, iNeuron: %03d\n',iFreq,iNeuron);
            sevFile = LFPfiles_local{iNeuron};
            [~,name,~] = fileparts(sevFile);

            [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
            curTrials = all_trials{iNeuron};

            for iTiming = 1:2
                [trialIds,allTimes] = sortTrialsBy(curTrials,timingFields{iTiming});
                [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow*2,Fs,freqList(iFreq),eventFieldnames);

                keepTrials = threshTrialData(all_data,zThresh);
                W = W(:,:,keepTrials,:);
                [Wz,Wz_angle] = zScoreW(W,Wlength); % power Z-score
                allTimes = allTimes(keepTrials);
                xTimes(iTiming,startIdx(iTiming):startIdx(iTiming) + numel(allTimes) - 1) = allTimes;
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
        for iTiming = 1:2
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
end
save(fullfile(savePath,['201903_RTMTcorr_iSession',num2str(useSessions,'%02d'),'_nSessions',num2str(numel(useSessions),'%02d')]),...
    'all_powerCorrs','all_powerPvals','all_phaseCorrs','all_phasePvals');
end

% plot
% % h = ff(1400,800);
% % rows = 4;
% % cols = 7;
% % for iTiming = 1:2
% %     for iEvent = 1:7
% %         subplot(rows,cols,prc(cols,[iTiming*2-1,iEvent]));
% %         yyaxis left;
% %         plot(squeeze(powerCorrs(iTiming,iEvent,:)),'linewidth',2);
% %         ylim([-0.5 0.5]);
% %         ylabel('rho');
% %         yyaxis right;
% %         plot(squeeze(powerPvals(iTiming,iEvent,:)),'linewidth',1);
% %         ylim([0 1]);
% %         ylabel('p-value');
% %         title([eventFieldnames{iEvent},' power ' ,timingFields{iTiming}]);
% %     end
% %     
% %     for iEvent = 1:7
% %         subplot(rows,cols,prc(cols,[iTiming*2,iEvent]));
% %         yyaxis left;
% %         plot(squeeze(phaseCorrs(iTiming,iEvent,:)),'linewidth',2);
% %         ylim([-0.5 0.5]);
% %         ylabel('rho');
% %         yyaxis right;
% %         plot(squeeze(phasePvals(iTiming,iEvent,:)),'linewidth',1);
% %         ylim([0 1]);
% %         ylabel('p-value');
% %         title([eventFieldnames{iEvent},' phase ' ,timingFields{iTiming}]);
% %     end
% % end