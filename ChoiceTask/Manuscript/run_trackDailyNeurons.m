% [] !!this does not address sort quality of a single session

% uses the unitID toolbox
% https://www.mathworks.com/matlabcentral/fileexchange/30113-tracking-neurons-over-multiple-days
% cd to unitID folder: >> mex relativeHist.c

% waveforms: m units x n mean waveform data points (+/- 2 ms, in uV)
% sameWire: m units x n wires, where units on same wire are logical 1
% wireLabels: 1 x n wires, string/name for each wire

% Each argument is a #days x 1 cell array where each element represents one
% day of recording.
%
% channel{day}: #neurons vector of channel numbers
% unit{day}: #neurons vector of sort id numbers, would be between 1 and
%   4 if your system has the capacity to sort 4 neurons on each channel.
% spiketimes{day}: #neurons cell array of #spikes vector of spike
%   times.  spiketimes{day}{i} would be the vector of spiketimes for
%   channel{day}{i} unit number unit{day}{i}.
% wmean{day}: #neurons cell array of #samples vector representing a mean
%   waveform.  wmean{day}{i} would be the mean waveform for channel{day}{i}
%   unit number unit{day}{i}.

channel = {};
unit = {};
spiketimes = {};
wmean = {};

sessions = analysisConf.sessionNames;
[C,ia,ic] = unique(sessions);
for iDay = 1:4%numel(C)
    sameWire_day = sameWire(ic == iDay,:);
    startNeuron = find(ic == iDay,1);
    
    % setup
    channelData = [];
    unitData = [];
    spiketimesData = {};
    wmeanData = {};
    unitCount = 1;
    for iNeuron = 1:size(sameWire_day,1)
        channelData(iNeuron) = find(sameWire_day(iNeuron,:) == 1) + (startNeuron - 1);
        spiketimesData{iNeuron} = all_ts{iNeuron + (startNeuron - 1)};% all_ts(iNeuron + (startNeuron - 1));
        wmeanData{iNeuron} = waveforms(iNeuron + (startNeuron - 1),[1:32]+8); % 32 centered samples
        unitData(iNeuron) = unitCount;
        
        unitCount = unitCount + 1;
    end
    channel{iDay,1}  = channelData;
    unit{iDay,1} = unitData;
    spiketimes{iDay,1} = spiketimesData;
    wmean{iDay,1} = wmeanData;
end
[survival, score, corrscore, wavescore, autoscore, basescore, correlations] = unitIdentification(channel, unit, spiketimes, wmean);