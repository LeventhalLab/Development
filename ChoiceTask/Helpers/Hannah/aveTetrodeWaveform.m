function waveforms = aveTetrodeWaveform(ts, sevfiles)
%Function to get the average waveform across wires of a tetrode
%
%Inputs:
%   -vector of timestamps
%   -cell of SEV files for tetrode
%
%Outputs:
%   -3D matrix (timestamp x wire x waveform)

%loop through each wire and read the raw data
for ii = 1:4
    [sev(ii,:), header] = read_tdt_sev(sevfiles{ii});
end

%Filter
[b, a] = butter(4, [.02, .2]);
for jj = 1:size(sev,1)
    sev(jj,:) = filtfilt(b, a, double(sev(jj,:)));
end

halfWindow = .002*header.Fs;

%Loop through each timestamp, take the mean along each wire for 2
%milliseconds on either side of the timestamp
for iTs = 1:length(ts)
    for iWire = 1:4
        waveforms(iTs, iWire, :) = sev(iWire,round(header.Fs*ts(iTs) - halfWindow) : round(header.Fs*ts(iTs)+halfWindow));      
    end
end
end