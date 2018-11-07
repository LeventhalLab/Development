function W = calculateComplexSpectrum(sevFilt,Fs,freqList)
% freqList is cell
W = [];
for iFreq = 1:size(freqList{:},1)
    disp(['Filtering ',num2str(freqList{:}(iFreq,1)),' - ',num2str(freqList{:}(iFreq,2)),' Hz']);
    W(:,iFreq) = hilbert(eegfilt(sevFilt,Fs,freqList{:}(iFreq,1),freqList{:}(iFreq,2)));
end