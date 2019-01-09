 function keepLocs = dklPeakDetect(LFP,iEvent)
doDebug = false;
% LFP is [flank,power,flank]
% LFP: events x samples x trials x freqs
% this method is only slightly different: instead of finding the crossing of 1std after a beta peak, it uses the local
% minima on either side of the beta peak as the beginning/end of the epoch.
ms100 = (size(LFP,2) / 2) / 10;

ref_power = [];
ref_std = [];
for iRef = 1:3
    ref_power(iRef) = mean2(abs(squeeze(LFP(1,:,:,iRef))).^2);
    ref_std(iRef) = mean(std(abs(squeeze(LFP(1,:,:,iRef))).^2));
end

keepLocs = {};
for iTrial = 1:size(LFP,3)
    keepLocs{iTrial} = [];
    trialPower = abs(squeeze(LFP(iEvent,:,iTrial,2))).^2;
    flankPower = mean([abs(squeeze(LFP(iEvent,:,iTrial,1))).^2;...
                       abs(squeeze(LFP(iEvent,:,iTrial,3))).^2]);
    cutoffPower = ref_power(2) + ref_std(2) * 2;
    ncutoffPower = max(-trialPower - min(-trialPower)) - (ref_power(2) + ref_std(2));
    locs = peakseek(trialPower,1,cutoffPower);
    nlocs = peakseek(-trialPower - min(-trialPower),1,ncutoffPower);
    nlocs = unique(sort([nlocs,1,numel(trialPower)])); % add beginning and end
    % duration >= 100ms @ 1STD, power 2x mean of flanking bands
    
    for iLoc = 1:numel(locs)
        thisLoc = locs(iLoc);
        if trialPower(thisLoc) > flankPower(thisLoc) * 2
            nloc1 = max(nlocs(nlocs < thisLoc));
            nloc2 = min(nlocs(nlocs > thisLoc));
            if nloc2 - nloc1 >= ms100
                keepLocs{iTrial} = [keepLocs{iTrial};nloc1 thisLoc nloc2];
%                 keepLocs{iTrial} = [keepLocs{iTrial} thisLoc];
            end
        end
    end
    
    if doDebug
        h = figure;
        plot(trialPower,'k-');
        hold on;
        plot(size(trialPower),[cutoffPower cutoffPower],'k--');
        plot(size(trialPower),[ref_power(2) + ref_std(2) ref_power(2) + ref_std(2)],'k--');
        plot(flankPower,'r:');
        plot(locs,trialPower(locs),'ko');
        plot(nlocs,trialPower(nlocs),'k.','markerSize',10);
        for iLoc = 1:size(keepLocs{iTrial},1)
            plot(keepLocs{iTrial}(iLoc,2),trialPower(keepLocs{iTrial}(iLoc,2)),'rx');
        end
        hold off;
        close(h);
    end
end