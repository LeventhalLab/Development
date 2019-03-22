function [intrialSamples,intertrialSamples] = findIntertrialTimeRanges(intrialTimeRanges,Fs)
    intrialSamples = round(intrialTimeRanges * Fs);
    intertrialSamples = NaN(size(intrialSamples));
    minSample = min(intrialSamples(:,1));
    maxSample = max(intrialSamples(:,2));
    for iTrial = 1:size(intrialTimeRanges,1)
        thisRange = diff(intrialSamples(iTrial,:));
% %         disp(['--> t',num2str(iTrial,'%03d'),', searching for ',num2str(thisRange/Fs,3),'s intertrial']);
        doSearch = true;
        while doSearch
            testStart = round((maxSample-minSample).*rand + minSample);
            testEnd = testStart + thisRange - 1;
            if testEnd < maxSample
                doSearch = any((testStart >= intrialSamples(:,1) & testStart <= intrialSamples(:,2)) | ...
                    (testEnd >= intrialSamples(:,1) & testEnd <= intrialSamples(:,2)));
            end
        end
        intertrialSamples(iTrial,:) = [testStart,testEnd];
    end
end