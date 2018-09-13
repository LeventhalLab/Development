% see compileSpikeWaveforms.m
% waveformBounds = [];
figuree(500,500);
for iNeuron = 1:numel(spikes)
    plot(spikes(iNeuron,:));
    xlim([1 size(spikes,2)]);
    [xs,~] = ginput(2);
    waveformBounds(iNeuron,:) = round(xs);
end
waveformBounds = waveformBounds - size(spikes,2)/2;