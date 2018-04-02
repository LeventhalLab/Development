function [s,binned,kernel,sigma] = spikeDensityEstimate(ts,tsEnd,sigma)
% ts = timestamps in seconds
% trialLength = trial length in seconds (max(ts) is a rough estimate)
% sigma = std deviations for kernel edges
% modified from: MATLAB for Neuroscientists, p.319-320
% s = SDE at every ms of recording
% binned = integer of spikes for each ms of recording
% kernel = smoothing kernel

binWidth = .001; % 1ms
if ~exist('tsEnd','var')
    tsEnd = ts(end);
end
if ~exist('sigma','var')
    sigma = .05; % kernel std, 50ms
%     sigma = mean(diff(ts)) * 2;
end

tsEnd = round(tsEnd,3); % round to ms-precision
binned = hist(ts,[binWidth:binWidth:tsEnd]); % bin data
edges = [-3*sigma:.001:3*sigma]; % time ranges
kernel = normpdf(edges,0,sigma); % eval guassian kernel
kernel = kernel*.001; % multiply by bin width
s = conv(binned,kernel); % convolve
center = ceil(length(edges)/2); % index of kernel center
s = s(center:tsEnd*1000 + center-1);

% [ ] only plot a subset, this plot is clunky
if false
    figure;
    t = linspace(binWidth,tsEnd,length(s));
    plot(t,s)
    hold on;
    spikeIdx = find(binned == 1);
    plot(t(spikeIdx),zeros(length(spikeIdx),1),'+'); % plotted as seconds
end

% hold on; plot(t(spansUpper),[upperThresh upperThresh])
% hold on; plot(t(spansLower),[lowerThresh lowerThresh])
% hold on; plot(t(spansMiddle),[lowerThresh upperThresh])