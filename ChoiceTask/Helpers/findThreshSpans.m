function spans = findThreshSpans(s,thresh,occurs)
% s = time-varying data
% thresh = positive: greater than, negative: less than, [n n]: between
% occurs = meets threshold criteria consecutively this many times

% modified from: https://www.mathworks.com/matlabcentral/answers/230702-how-to-find-consecutive-values-above-a-certain-threshold

% threshold mode
if length(thresh) == 1
    if thresh < 0
        [b,n] = RunLength(-s > thresh & s > 0);
    else
        [b,n] = RunLength(s >= thresh);
    end
else
    [b,n] = RunLength(s >= thresh(1) & s < thresh(2));
end

b(n < occurs) = 0;
mask = RunLength(b,n);
% values = s(mask);

% savvy method
startIdxs = find(diff(mask) == 1) + 1;
endIdxs = find(diff(mask) == -1);
% handle ends
if any([startIdxs endIdxs])
    if mask(1) == 1 % meets critera at start
        startIdxs = [1 startIdxs];
    end
    if mask(end) == 1 % meets criteria at end
        endIdxs = [endIdxs length(mask)];
    end
end

spans = [startIdxs' endIdxs'];