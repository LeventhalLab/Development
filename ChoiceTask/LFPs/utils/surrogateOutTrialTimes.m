function trialTimeRanges_out = surrogateOutTrialTimes(trialTimeRanges_samples)

minSamp = min(trialTimeRanges_samples(:,1));
maxSamp = max(trialTimeRanges_samples(:,2));
rangeLength = median(diff(trialTimeRanges_samples'));

trialTimeRanges_out = [];
for ii = 1:size(trialTimeRanges_samples,1)
    disp(['surrogate trial: ',num2str(ii)]);
    overlap = true;
    whileCount = 0;
    while overlap
        randStart = randi([minSamp,maxSamp]);
        useRange = randStart:randStart+rangeLength-1;
        overlap = intersectIterate(trialTimeRanges_samples,useRange);
    end
    trialTimeRanges_out(ii,:) = [useRange(1),useRange(end)];
end