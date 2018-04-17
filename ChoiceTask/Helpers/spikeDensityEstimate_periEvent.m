function [s,counts,kernel,sigma] = spikeDensityEstimate_periEvent(ts,tWindow)
% ts = timestamps in seconds
% sigma = std deviations for kernel edges
% modified from: MATLAB for Neuroscientists, p.319-320
% s = SDE at every ms of recording
% binned = integer of spikes for each ms of recording
% kernel = smoothing kernel

binWidth = .001; % 1ms

sigma = .050; % kernel std, 50ms
% sigma = mean(diff(ts));% * 2; % !!! variable kernel width ???

binEdges = -tWindow:binWidth:tWindow;
counts = histcounts(ts,binEdges); % bin data
edges = [-3*sigma:binWidth:3*sigma]; % time ranges
kernel = normpdf(edges,0,sigma); % eval guassian kernel
kernel = kernel*binWidth; % multiply by bin width
sConv = conv(counts,kernel); % convolve

halfKernel = ceil(numel(edges)/2); % index of kernel center
s = sConv(halfKernel:halfKernel + numel(counts) - 1); % remove kernel smoothing from edges

% [ ] only plot a subset, this plot is clunky
if false
    figure;
    t = linspace(-tWindow,tWindow,numel(s));
    plot(t,s)
    hold on;
    spikeIdx = find(counts == 1);
    plot(t(spikeIdx),zeros(length(spikeIdx),1),'+'); % plotted as seconds
end

% hold on; plot(t(spansUpper),[upperThresh upperThresh])
% hold on; plot(t(spansLower),[lowerThresh lowerThresh])
% hold on; plot(t(spansMiddle),[lowerThresh upperThresh])