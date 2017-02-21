function [s,binned,kernel] = spikeDensityEstimate_Fs(ts,endTs,sigma,Fs)
% ts = timestamps in seconds
% trialLength = trial length in seconds (max(ts) is a rough estimate)
% sigma = std deviations for kernel edges
% modified from: MATLAB for Neuroscientists, p.319-320
% s = SDE at every ms of recording
% binned = integer of spikes for each ms of recording
% kernel = smoothing kernel

% endTs = round(endTs,3); % round to ms-precision
binned = hist(ts,[0:1/Fs:endTs]); % bin data
% sigma = .05; % kernel std, 50ms
edges = [-3*sigma:1/Fs:3*sigma]; % time ranges
kernel = normpdf(edges,0,sigma); % eval guassian kernel
kernel = kernel*(1/Fs); % multiply by bin width
s = conv(binned,kernel); % convolve
center = ceil(length(edges)/2); % index of kernel center
s = s(center:endTs*(Fs) + center - 1);

% [ ] only plot a subset, this plot is clunky
if false
    figure;
    t = linspace(1/Fs,endTs,length(s));
    plot(t,s)
    hold on;
    spikeIdx = find(binned == 1);
    plot(t(spikeIdx),zeros(length(spikeIdx),1),'+'); % plotted as seconds
end

% hold on; plot(t(spansUpper),[upperThresh upperThresh])
% hold on; plot(t(spansLower),[lowerThresh lowerThresh])
% hold on; plot(t(spansMiddle),[lowerThresh upperThresh])