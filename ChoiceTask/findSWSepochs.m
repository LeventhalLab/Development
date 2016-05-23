% decimateFactor = 100;
% scalogramWindow = 2; % seconds
% [sevRaw,header] = read_tdt_sev(sevFilename);
% sev = decimate(double(sevRaw),decimateFactor);
% Fs = header.Fs/decimateFactor;
% freqList = linspace(.5,60,120);

data = sev(1:Fs*scalogramWindow);

[W, freqList] = calculateComplexScalograms_EnMasse(data,...
    'Fs',Fs,'freqlist',freqList);

