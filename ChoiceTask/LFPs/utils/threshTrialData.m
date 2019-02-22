function keepTrials = threshTrialData(data,zThresh)
fractionOfTrial = 0.95;

% [ ] is this function ever used with vectors?
if size(data,3) > 1
    data = reshape(permute(data,[2,1,3]),[size(data,1) * size(data,2),size(data,3)]);
end

zmean = mean(mean(data));
zstd = mean(std(data));

keepTrials = [];

for iTrial = 1:size(data,2)
    ztrial = (data(:,iTrial) - zmean) ./ zstd;
    % z-scored data is less than z-thresh for at least fractionOfTrial
    if sum(ztrial < zThresh) / numel(ztrial) > fractionOfTrial
        keepTrials = [keepTrials;iTrial];
    end
end