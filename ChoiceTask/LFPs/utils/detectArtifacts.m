function tsNogo = detectArtifacts(sevFile)
thresh = 1000;
decimateFactor = 10;

[sev,header] = read_tdt_sev(sevFile);
sevFilt = decimate(double(sev),decimateFactor);
Fs = header.Fs / decimateFactor;
data = abs(butterme(sevFilt,Fs,[0.5 200]));
tsNogo = find(data > thresh == 1) ./ Fs;