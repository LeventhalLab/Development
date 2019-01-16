h = ff(1400,500);
rows = 1;
cols = 7;
iTrial = 5;
iFreq = 17;
for iEvent = 1:7
    subplot(rows,cols,prc(cols,[1,iEvent]));
    imagesc(lag,1:numel(freqList),squeeze(acors(iTrial,iEvent,:,:)));
end