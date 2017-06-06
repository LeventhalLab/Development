function [meanWaveform, pks, windowSize] = peakToPeakfromSEV(ts, SEVfilename, varargin)

windowSize = .004; %2 milliseconds

for iarg = 1: 2 : nargin - 2
    switch varargin{iarg}
        case 'windowSize'
            windowSize = varargin{iarg + 1}/1000;
    end
end

%Read in data and filter
[sev, header] = read_tdt_sev(SEVfilename);
window = round((windowSize* header.Fs)/2);
[b,a] = butter(4, [0.02 0.5]);
sev = filtfilt(b,a,double(sev));

waveforms = [];

%Create the segments of the wave form
maxWaveforms = min(length(ts),5000); % minimize processing time
tsRand = randsample(ts,maxWaveforms);
for ii = 1:maxWaveforms
    if round(header.Fs*tsRand(ii))-window > 0 %full waveform must be within window
        waveforms = [waveforms; sev(round(header.Fs*tsRand(ii))-window:round(header.Fs*tsRand(ii))+window)];
    end
end    

%Calculate the mean for each column in the waveform vector
meanWaveform = mean(waveforms,1);

if size(ts,2)==1, ts=ts'; end

% Find all maxima and ties
locs=find(ts(2:end-1)>=ts(1:end-2) & ts(2:end-1)>=ts(3:end))+1;

minpeakdist = 0;

if nargin<2, minpeakdist=1; end % If no minpeakdist specified, default to 1.

if nargin>2 % If there's a minpeakheight
    locs(ts(locs)<=minpeakh)=[];
end

if minpeakdist>1
    while 1

        del=diff(locs)<minpeakdist;

        if ~any(del), break; end

        pks=ts(locs);

        [garb, mins]=min([pks(del) ; pks([false del])]);

        deln=find(del);

        deln=[deln(mins==1) deln(mins==2)+1];
        
        locs(deln)=[];

    end
end

if nargout>1
    pks=ts(locs);
end




