function allCenters = filter_allCenters(allCenters)
% % thresh = 20 / px2mm; % 20mm movement
nSmooth = 15;
allCenters(:,1) = smooth(allCenters(:,1),nSmooth);
allCenters(:,2) = smooth(allCenters(:,2),nSmooth);