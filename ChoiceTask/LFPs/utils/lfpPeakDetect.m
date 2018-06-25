function [locs_dkl,locs_jones] = lfpPeakDetect(LFP,iEvent,medianMult)
doDebug = false;
% LFP is [flank,power,flank]
% LFP: events x samples x trials x freqs
% this method is only slightly different: instead of finding the crossing of 1std after a beta peak, it uses the local
% minima on either side of the beta peak as the beginning/end of the epoch.
ms100 = (size(LFP,2) / 2) / 10;
minpeakdist = ms100 / 10; % 10 ms

ref_power_mean = [];
ref_power_median = [];
ref_power_std = [];
for iRef = 1:3
    ref_power_mean(iRef) = mean2(abs(squeeze(LFP(1,:,:,iRef))).^2);
    ref_power_median(iRef) = median(mean(abs(squeeze(LFP(1,:,:,iRef))).^2));
    ref_power_std(iRef) = mean(std(abs(squeeze(LFP(1,:,:,iRef))).^2));
end

locs_dkl = {};
for iTrial = 1:size(LFP,3)
    locs_dkl{iTrial} = [];
    trialPower = abs(squeeze(LFP(iEvent,:,iTrial,2))).^2;
    flankPower = mean([abs(squeeze(LFP(iEvent,:,iTrial,1))).^2;...
                       abs(squeeze(LFP(iEvent,:,iTrial,3))).^2]);
    
    cutoffPower_jones = ref_power_median(2) * medianMult;
    locs_jones_putative = peakseek(trialPower,minpeakdist,cutoffPower_jones);
    locs_jones{iTrial} = locs_jones_putative;
    cutoffPower_dkl = ref_power_mean(2) + ref_power_std(2) * 2;
    ncutoffPower_dkl = max(-trialPower - min(-trialPower)) - (ref_power_mean(2) + ref_power_std(2));
    locs_dkl_putative = peakseek(trialPower,minpeakdist,cutoffPower_dkl);
    nlocs_dkl_putative = peakseek(-trialPower - min(-trialPower),1,ncutoffPower_dkl);
    nlocs_dkl_putative = unique(sort([nlocs_dkl_putative,minpeakdist,numel(trialPower)])); % add beginning and end
    % duration >= 100ms @ 1STD, power 2x mean of flanking bands
    for iLoc = 1:numel(locs_dkl_putative)
        thisLoc = locs_dkl_putative(iLoc);
        if trialPower(thisLoc) > flankPower(thisLoc) * 2
            nloc1 = max(nlocs_dkl_putative(nlocs_dkl_putative < thisLoc));
            nloc2 = min(nlocs_dkl_putative(nlocs_dkl_putative > thisLoc));
            if nloc2 - nloc1 >= ms100
% %                 keepLocs{iTrial} = [keepLocs{iTrial};nloc1 thisLoc nloc2];
                locs_dkl{iTrial} = [locs_dkl{iTrial} thisLoc];
            end
        end
    end
    
    if doDebug
        h = figure;
        plot(trialPower,'k-');
        hold on;
        plot(size(trialPower),[cutoffPower_dkl cutoffPower_dkl],'k--');
        plot(size(trialPower),[ref_power_mean(2) + ref_power_std(2) ref_power_mean(2) + ref_power_std(2)],'k--');
        plot(flankPower,'r:');
        plot(locs_dkl_putative,trialPower(locs_dkl_putative),'ko');
        plot(nlocs_dkl_putative,trialPower(nlocs_dkl_putative),'k.','markerSize',10);
        for iLoc = 1:size(locs_dkl{iTrial},1)
            plot(locs_dkl{iTrial}(iLoc,2),trialPower(locs_dkl{iTrial}(iLoc,2)),'rx');
        end
        hold off;
        close(h);
    end
end