% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
% load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')

doSetup = false;

tWindow = 1;
useSessions = 1:30;
if doSetup
    compiled_RTs = [];
    compiled_MTs = [];
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
            compiled_MTs = [compiled_MTs all_trials{1,iNeuron}(trialIds(iTrial)).timing.MT];
        end
% %         [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,[2,20],eventFieldnames);
    end
end

RTlim = [0 0.4];
MTlim = [0.1 0.5];
prelim = [0.5 1];
h = ff(900,300);
subplot(131);
[rho,pval] = corr(compiled_RTs',compiled_MTs','type','Spearman');
scatter(compiled_RTs,compiled_MTs,'filled');
xlim(RTlim);
ylim(MTlim);
title(['RTxMT: rho = ',num2str(rho,2),', pval = ',num2str(pval,2)]);

subplot(132);
[rho,pval] = corr(compiled_RTs',compiled_pretones','type','Spearman');
scatter(compiled_RTs,compiled_pretones,'filled');
xlim(RTlim);
ylim(prelim);
title(['RTxPRE: rho = ',num2str(rho,2),', pval = ',num2str(pval,2)]);

subplot(133);
[rho,pval] = corr(compiled_MTs',compiled_pretones','type','Spearman');
scatter(compiled_MTs,compiled_pretones,'filled');
xlim(MTlim);
ylim(prelim);
title(['MTxPRE: rho = ',num2str(rho,2),', pval = ',num2str(pval,2)]);

% rho =
%    -0.1409
% pval =
%    1.9165e-11