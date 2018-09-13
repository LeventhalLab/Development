function spikes = compileSpikeWaveforms(LFPfiles_local,all_ts)
% see: determineSpikeWaveformBounds.m
spikes = [];
nSpikes = 1000;
testWindow = 0.005;
for iNeuron = 1:numel(all_ts)
    ts = all_ts{iNeuron};
    sevFile = LFPfiles_local{iNeuron};
    disp(num2str(iNeuron));
    [sev,header] = read_tdt_sev(sevFile);
    nSamples = round(testWindow * header.Fs);
    ts_start = find(ts > testWindow,1);
    ts_end = min([numel(find(ts < numel(sev) / header.Fs - testWindow)),nSpikes]);
    ts_samples = round(ts(ts_start:ts_end) * header.Fs);
    spikeArr = [];
    for iSpike = 1:numel(ts_samples)
        spikeArr(:,iSpike) = sev(ts_samples(iSpike) - nSamples:ts_samples(iSpike) + nSamples - 1);
        spikeArr(:,iSpike) = spikeArr(:,iSpike) - mean(spikeArr(:,iSpike));
    end
    spikes(iNeuron,:) = mean(spikeArr,2);
end