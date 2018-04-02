function of_zParams = openField_zParams(trialActograms,px2mm)
% values are per-frame
zParams_mm = {};
all_means = [];
all_stds = [];
for iTrial = 1:size(trialActograms,1)
    allCenters = filter_allCenters(trialActograms{iTrial,3});
    z = smoothn({allCenters(:,1),allCenters(:,2)},'robust');
    D = getDist(z) * px2mm;
    all_means(iTrial) = mean(D);
    all_stds(iTrial) = std(D);
end
zMean_mm = mean(all_means);
zStd_mm = mean(all_stds);
of_zParams = [zMean_mm,zStd_mm];