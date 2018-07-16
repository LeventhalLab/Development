function [Wz_thresh,keepTrials] = removeWzTrials(Wz_power,zThresh)

Wz_thresh = [];
trialCount = 0;
keepTrials = [];
for iTrial = 1:size(Wz_power,3)
    removeTrial = false;
    for iEvent = 1:7
        scaloData = squeeze(Wz_power(iEvent,:,iTrial,:));
        if mean2(scaloData) > zThresh
            removeTrial = true;
        end
    end
    
    if iEvent == 7 && ~removeTrial
        trialCount = trialCount + 1;
        Wz_thresh(:,:,trialCount,:) = Wz_power(:,:,iTrial,:);
        keepTrials(trialCount) = iTrial;
    end
end