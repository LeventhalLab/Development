function [meanWaveform, upperStd, lowerStd, ch, windowSize] = aveWaveform(ts, SEVfilename, varargin)
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
%   ch - channel number
%   windowSize 



% color = [145/255, 205/255, 114/255];
windowSize = .002; %2 milliseconds

for iarg = 1: 2 : nargin - 2
    switch varargin{iarg}
%         case 'color'
%             color = varargin{iarg + 1};
        case 'windowSize'
            windowSize = varargin{iarg + 1}/1000;
    end
end

%Read in data and filter
[sev, header] = read_tdt_sev(SEVfilename);
window = round((windowSize* header.Fs)/2);
[b,a] = butter(4, [.02, .2]);
% why is this in a loop? size(sev,1) is just 1?
for ii = 1:size(sev,1)
    sev(ii,:) = filtfilt(b,a,double(sev));
end

waveforms = [];

%Create the segments of the wave form
for ii = 1:length(ts)
    waveforms = [waveforms; sev(round(header.Fs*ts(ii))-window:round(header.Fs*ts(ii))+window)];     
end    

%Calculate the mean for each column in the waveform vector
meanWaveform = mean(waveforms,1);

%Calculate the standard deviations
stdDev = std(waveforms);
upperStd = meanWaveform + stdDev;
lowerStd = meanWaveform - stdDev;
ch = getSEVChFromFilename(SEVfilename);

end