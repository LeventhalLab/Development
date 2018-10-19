% all_MImatrix_surrEvents = [];
load('session_20180925_entrainmentSurrogates.mat', 'eventFieldnames')
load('session_20180925_entrainmentSurrogates.mat', 'all_trials')
load('session_20180925_entrainmentSurrogates.mat', 'LFPfiles_local')
load('session_20180925_entrainmentSurrogates.mat', 'selectedLFPFiles')
freqList = logFreqList([2 200],30);
all_MImatrix_surr = [];
iSession = 0;
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);
    curTrials = all_trials{iNeuron};
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
% %     all_MImatrix_surrEvents(iSession,:,:,:,:) = tort_PACsurrogateEvents(sevFilt,Fs,curTrials,freqList,eventFieldnames);
    all_MImatrix_surr(iSession,:,:,:) = tort_PACsurrogates(sevFilt,Fs,curTrials,freqList);
end