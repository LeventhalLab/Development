function info = extractPhasAmplitudeLFP(data,ts,tWindow,Fs,freqs)

smoothdata = eegfilt(data,Fs,freqs(1),freqs(2),epochframes,filtorder,revfilt,firtype,causal)

angle(hilbert(squeeze(filteredData(channelCount, :, :))));
hx = hilbert(filtData(i,:));
phases(i,:) = atan2(imag(hx),real(hx));
instPhase = atan2(imag(hx),real(hx));
circ_dist

betaPower = abs(sevHilbert).^2;