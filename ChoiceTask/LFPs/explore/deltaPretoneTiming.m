% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
% load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')

doSetup = true;

tWindow = 1;
useSessions = 1:30;
if doSetup
    compiled_RTs = [];
    compiled_pretones = [];
    for iNeuron = selectedLFPFiles(useSessions)'
        sevFile = LFPfiles_local{iNeuron};
        [~,name,~] = fileparts(sevFile);

        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        compiled_RTs = [compiled_RTs allTimes];
        for iTrial = 1:numel(allTimes)
            compiled_pretones = [compiled_pretones all_trials{1,iNeuron}(trialIds(iTrial)).timing.pretone];
        end
% %         [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,[2,20],eventFieldnames);
    end
end

figure;
scatter(compiled_RTs,compiled_pretones,'filled');
xlim([0 0.4]);
ylim([0.5 1]);

[rho,pval] = corr(compiled_RTs',compiled_pretones');
% rho =
%    -0.1409
% pval =
%    1.9165e-11