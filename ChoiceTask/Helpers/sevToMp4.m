function sevToMp4(sev,Fs,saveAs)
sevFilt = eegfilt(sev,Fs,500,0);
% if written as double, must be +/- 1: *normalize may not work well if there
% are large artifacts
audiowrite(saveAs,(normalize(sevFilt)*2)-1,round(Fs));