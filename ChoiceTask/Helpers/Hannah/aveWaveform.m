function [meanWaveform, upperStd, lowerStd, windowSize] = aveWaveform(ts,sevFile,varargin)
%Function to plot the average waveform of a unit with the peak centered at
%zero. Default color of summer tree green. Default window size of 4 ms.
%
%Inputs: 
%   ts - vector of time stamps
%   SEVfilename - the path for the SEV file of interest
% 
% possible variable inputs: color (in [R/255, B/255, G/255] format), window
% size (in milliseconds)
%
% Outputs:
%   meanWaveforms - vector to plot the waveform later
%   upperStd - the waveform one standard deviation above the mean
%   lowerStd - the waveform one standard deviation below the mean
%   windowSize 

windowSize = .002;

for iarg = 1: 2 : nargin - 2
    switch varargin{iarg}
        case 'windowSize'
            windowSize = varargin{iarg + 1}/1000;
    end
end

%Read in data and filter
[sev, header] = read_tdt_sev(sevFile);
window = round((windowSize * header.Fs)/2);
[b,a] = butter(4, [0.02 0.5]);
sev = filtfilt(b,a,double(sev));

waveforms = [];

%Create the segments of the wave form
maxWaveforms = min(length(ts),5000); % minimize processing time
tsRand = randsample(ts,maxWaveforms);
for ii = 1:maxWaveforms
    if round(header.Fs*tsRand(ii))-window > 0 % full waveform must be within window
        waveforms = [waveforms; sev(round(header.Fs*tsRand(ii))-window:round(header.Fs*tsRand(ii))+window)];
    end
end    

%Calculate the mean for each column in the waveform vector
meanWaveform = mean(waveforms,1);

%Calculate the standard deviations
stdDev = std(waveforms);
upperStd = meanWaveform + stdDev;
lowerStd = meanWaveform - stdDev;

end