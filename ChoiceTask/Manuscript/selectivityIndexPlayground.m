% these are all units that meet criteria for firing rate > 5 Hz
% and >5 trials in both directions
% they are sorted by unit class (i.e., Fig 2 heatmap)

save('session_20180428_selectivityVars','all_matrixDiffZ','all_contraZ','all_ipsiZ','dirSelUsedNeurons','dirSelNeuronsNO','dirSelUnitIds','ndirSelUnitIds');
all_matrixDiffZ % 366-based, NaNs for units not analyzed
all_contraZ % 366-based contra Z's
all_ipsiZ % 366-based ipsi Z's
dirSelUsedNeurons % ID-based, all units minus 3 sessions with missing Tone Dir
dirSelNeuronsNO % 366-based marking dir selective units, requires dirSelUsedNeurons to know ~dir units
dirSelUnitIds % all the dirSel units used in Fig 5
ndirSelUnitIds % all the ~dirSel units used in Fig 5

% rename vars, leave commented
% % si_dirSelNeurons = selected_dirSelNeurons;
% % si_normalizedBinMethod = selected_sorted_all_ntpIdx_norm;
% % si_zScoreMethod = selected_sorted_all_matrixDiffZ;
% % si_primSecClasses = selected_sorted_primSec;
% % save('selectivityIndexPlayround','si_dirSelNeurons','si_normalizedBinMethod','si_zScoreMethod','si_primSecClasses');
% % save('/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Thalamus_behavior_2017/Resubmission/20180422/selectivityIndexPlayround_20180424',...
% %     'si_dirSelNeurons','si_normalizedBinMethod','si_zScoreMethod','si_primSecClasses',...
% %     'all_ipsiZ','all_contraZ','all_bothZ','key_212_to_366');

analyzeRange = 40:70; % from ipsiContraShuffle.m, same range used for dirSel

% primary tone and nose out unit indexes
toneIdxs = find(si_primSecClasses(:,1) == 3);
noseOutIdxs = find(si_primSecClasses(:,1) == 4);

% AUC example, analyzeRange is 0.5s around Nose Out (event 4)
% note these arrays have to be transposed
tone_zSI = abs(squeeze(si_zScoreMethod(toneIdxs,4,analyzeRange)));
tone_zAUC = trapz(tone_zSI');

noseOut_zSI = abs(squeeze(si_zScoreMethod(noseOutIdxs,4,analyzeRange)));
noseOut_zAUC = trapz(noseOut_zSI');

% a few are driving the mean, but they are similar
figure;
plot(mean(tone_zSI));
hold on;
plot(mean(noseOut_zSI));

group = [ones(size(tone_zAUC)) 2*ones(size(noseOut_zAUC))];
y = [tone_zAUC noseOut_zAUC];
anova1(y,group);


% bin example using Nose Out and Side Out
nOsOIdxs = [find(si_primSecClasses(:,1) == 4);find(si_primSecClasses(:,1) == 6)];
tone_binSI = si_normalizedBinMethod(toneIdxs);
nOsO_binSI = si_normalizedBinMethod(nOsOIdxs);

group = [ones(size(tone_binSI)) 2*ones(size(nOsO_binSI))];
y = [tone_binSI nOsO_binSI];
anova1(y,group);

