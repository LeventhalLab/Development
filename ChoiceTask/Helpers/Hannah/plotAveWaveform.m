function plotAveWaveform(meanWaveform, upperStd, lowerStd, ch, windowSize, varargin)
% Function to plot the average waveform of a unit
%
% Inputs:
%   filename - path to SEV file
%   waveforms, upperStd, lowerStd - vectors from aveWaveform function
%   windowSize - the number of milliseconds on either side of the peak
%   optional color  in [R/255, G/255, B/255] format

color = [145/255, 205/255, 114/255]; %default color summer tree green

for iarg = 1: 2 : nargin - 5
    switch varargin{iarg}
        case 'color'
            color = varargin{iarg + 1};
    end
end

%Plot the waveform and shade upper and lower standard deviations
figure
grid on
t = linspace(-windowSize/2, windowSize/2, length(meanWaveform));
fill([t fliplr(t)], [upperStd fliplr(lowerStd)], color, 'edgeColor', color);
alpha(.25);
hold on
plot(t, meanWaveform, 'color', color, 'lineWidth', 2)
hold on
xlabel('time (s)');
ylabel('uV');
title(['Channel ', num2str(ch), ' Average Waveform'])