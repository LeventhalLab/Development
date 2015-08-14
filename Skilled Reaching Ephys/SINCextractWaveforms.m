 function [waveforms,ts] = SINCextractWaveforms( data, ts, peakLoc, waveLength )
%
% usage: waveforms = extractWaveforms( data, ts, peakLoc, waveLength )
%
% INPUTS:
%   data - m x n matrix containing wavelet filtered data; m is the number
%       of wires, n is the number of samples
%   ts - timestamps of the waveform peaks in SAMPLES
%   peakLoc - desired location of the peak within the waveform (ie, 
%       peakLoc = 8 means that the peak will be placed at the 8th sample -
%       that is, start the waveform at ts - peakLoc + 1
%   waveLength - number of points to extract for each waveform. Waveforms
%       extend from (ts - peakLoc + 1) to ((ts - peakLoc + 1 + waveLength)
%
% OUTPUTS:
%   waveforms - m x n x p matrix, where m is the number of timestamps
%       (spikes), n is the number of points in a single waveform, and p is
%       the number of wires

%FYS edits. Now this function upsamples the original signal through a sinc
%interpolation. New sampling rate = old sampling rate*10. 

numWires   = size(data, 1);
numSamples = size(data, 2);

%sinc interpolate


ts = ts(ts > peakLoc + 1);
ts = ts(ts < (numSamples + peakLoc - waveLength));

numSpikes = length(ts);
waveforms = zeros(numSpikes, 10*(waveLength-1)+1, numWires);

for i = 1 : numSpikes
    waveStart = ts(i) - peakLoc + 1;
    waveEnd   = ts(i) - peakLoc + waveLength;
    
    t= waveStart:waveEnd;
    %upsampled time range. Upsampled by 10, so new Fs ~ 244140 Hz
    t2= waveStart-1:.1:waveEnd+1;
    for j=1:numWires
        %sinc interpolation
        sincData = sinc_interp(data(j,t),t,t2);
        shiftedLoc = peakseek(abs(sincData(11:end-10)),length(sincData)-20);

    %(1/x)*(n-1) + 1  to convert to new upsamples
        %create new time stamp at upsampled shifted Location
        ts(i) = 10*(ts(i)-1)+1+(shiftedLoc+10-(10*(peakLoc+1-1)+1));

        %ran into problems with it shifting by more than 10 samples which
        %theoretically shouldnt happen
        if abs(shiftedLoc+10-(10*(peakLoc+1-1)+1))>10
            continue;
        end
       % shiftedLoc+10-(10*(peakLoc+1-1)+1)
        waveforms(i, :,j) = sincData(11+((shiftedLoc+10-(10*(peakLoc+1-1)+1))):end-10+(shiftedLoc+10-(10*(peakLoc+1-1)+1)))';
    end



end