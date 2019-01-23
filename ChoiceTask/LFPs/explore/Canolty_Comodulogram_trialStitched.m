% load('session_20180925_entrainmentSurrogates.mat', 'eventFieldnames')
% load('session_20180925_entrainmentSurrogates.mat', 'all_trials')
% load('session_20180925_entrainmentSurrogates.mat', 'LFPfiles_local')
% load('session_20180925_entrainmentSurrogates.mat', 'selectedLFPFiles')
% 
% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
% load('session_20180919_NakamuraMRL.mat', 'all_trials')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
% load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
% load('session_20180919_NakamuraMRL.mat', 'all_ts')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local_altLookup')

doSetup = true;
doSave = false;
doPlot = false;

if ismac
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/canoltyMethod/bySession';
else
    savePath = '\\172.20.138.142\RecordingsLeventhal2\ChoiceTask\MthalLFPs\CanoltySessions';
end

% dbstop if error
% dbclear all

tWindow = 0.5;
freqList = logFreqList([1 200],30);
eventFieldnames_wFake = {eventFieldnames{:} 'outTrial'};
nShuff = 100;
zThresh = 5;

iSession = 0;
corrMatrix_rho = NaN(numel(selectedLFPFiles),numel(eventFieldnames_wFake),numel(freqList),numel(freqList));
corrMatrix_pval = corrMatrix_rho;
shuff_corrMatrix_rho_mean = corrMatrix_rho;
shuff_corrMatrix_pval = corrMatrix_rho;

for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    disp(['Session #',num2str(iSession)]);
    if doSetup
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        trials = all_trials{iNeuron};
        trials = addEventToTrials(trials,'outTrial');
        [trialIds,allTimes] = sortTrialsBy(trials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        sevFilt = artifactThresh(sevFilt,[1],2000);
        sevFilt = sevFilt - mean(sevFilt);
        [W,all_data] = eventsLFPv2(trials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames_wFake);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        
        for iEvent = 1:size(W,1)
            disp(['working on event #',num2str(iEvent)]);
            for iA1 = 1:numel(freqList)
                A1 = squeeze(abs(W(iEvent,:,:,iA1)).^2);
                A1 = A1(:);
                for iA2 = iA1:numel(freqList)
                    A2 = squeeze(abs(W(iEvent,:,:,iA2)).^2);
                    A2 = A2(:);
                    [rho,pval] = corr(A1,A2);
                    corrMatrix_rho(iSession,iEvent,iA1,iA2) = rho;
                    corrMatrix_pval(iSession,iEvent,iA1,iA2) = pval;
                    
                    all_shuff_rho = NaN(nShuff,1);
                    for iShuff = 1:nShuff
                        shuff_A2 = squeeze(abs(W(iEvent,:,randperm(size(W,3),size(W,3)),iA2)).^2);
                        shuff_A2 = shuff_A2(:);
                        [shuff_rho,~] = corr(A1,shuff_A2);
                        all_shuff_rho(iShuff) = shuff_rho;
                    end
 
                    shuff_corrMatrix_rho_mean(iSession,iEvent,iA1,iA2) = mean(all_shuff_rho);
                    shuff_corrMatrix_pval(iSession,iEvent,iA1,iA2) = 1 - sum(abs(rho) > abs(all_shuff_rho)) / nShuff;
                end
            end
        end
    end
end

save('Canolt_comodulogram_20190122','corrMatrix_rho','corrMatrix_pval','shuff_corrMatrix_rho_mean','shuff_corrMatrix_pval',...
'eventFieldnames_wFake','freqList','nShuff');

% % % % if doPlot
% % % %     useSessions = [1:30];
% % % %     h = CanoltyPAC_trialStitched_print(all_corrMatrix,all_shuff_MImatrix_mean,all_corrMatrix_pvals,useSessions,...
% % % %     eventFieldnames_wFake,freqList_p,freqList_a,freqList,bandLabels);
% % % %     if doSave
% % % %         saveFile = ['s',num2str(useSessions(1)),'-',num2str(useSessions(end)),'_allEvent.png'];
% % % %         saveas(h,fullfile(savePath,saveFile));
% % % %         close(h);
% % % %     end
% % % % end