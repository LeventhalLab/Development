function [avgWF, tWidth upperStd, lowerStd] = avgWF(ts, HPdata,tBefore,tAfter,samplingRate, varargin)
%Function to get average WF 
%
%Inputs: 
%   ts - vector of time stamps
%  HPdata - High passed version of data
%  tBefore - time before WF detection in u seconds
%  tAfter - time after WF detection in u seconds
%  samplingRate

%
% Outputs:
%   meanWaveforms - vector to plot the waveform later
%   upperStd - the waveform one standard deviation above the mean
%   lowerStd - the waveform one standard deviation below the mean
%   ch - channel number
%   windowSize 

samplesBefore = round(tBefore*samplingRate*1E-6);
samplesAfter  = round(tAfter*samplingRate*1E-6);

%make sure early signals don't clip
if ts(1)*samplingRate-samplesBefore<0
  ts = ts(find(ts.*samplingRate-samplesBefore>0)) 
end

waveforms = zeros(length(ts), samplesBefore+samplesAfter+1);
for i = 1:length(ts)
    waveforms(i,:) = HPdata(ts(i).*samplingRate-samplesBefore:ts(i).*samplingRate+samplesAfter);
end

tWidth = linspace(-tBefore,tAfter,samplesBefore+samplesAfter+1);
avgWF = mean(waveforms);

upperStd = avgWF + std(avgWF); 
lowerStd = avgWF - std(avgWF);

