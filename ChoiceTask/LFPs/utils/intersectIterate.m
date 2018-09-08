function overlap = intersectIterate(trialTimeRanges,Brange)
overlap = false;
for ii = 1:size(trialTimeRanges,1)
    thisRange = trialTimeRanges(ii,1):trialTimeRanges(ii,2);
    C = intersect(thisRange,Brange);
    if ~isempty(C)
        overlap = true;
        return;
    end
end