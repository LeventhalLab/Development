% get zParams
doSetup = false;
doSave = true;
if doSetup
    zParams = openField_zParams(trialActograms4,px2mm);
end
figPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/Optogenetics/OpenField/figs';
exts = {'fig','png'};


% extinction trials over time
report_extinguishTrials(trialActograms6,px2mm,zParams,20,30);
saveFile = 'report_extinguishTrials_6_extinction';
run_saveFigs(figPath,saveFile,exts,doSave);


% controls grid
report_allTrialMotionGrid(trialActograms4,stimIDs4,0,px2mm,20);
saveFile = 'report_allTrialMotionGrid_4_controls';
run_saveFigs(figPath,saveFile,exts,doSave);

% opto grid
report_allTrialMotionGrid(trialActograms5,stimIDs5,powerList,px2mm,0);
saveFile = 'report_allTrialMotionGrid_5_0Hz';
run_saveFigs(figPath,saveFile,exts,doSave);

report_allTrialMotionGrid(trialActograms1,stimIDs1,powerList,px2mm,20);
saveFile = 'report_allTrialMotionGrid_1_20Hz';
run_saveFigs(figPath,saveFile,exts,doSave);

report_allTrialMotionGrid(trialActograms2,stimIDs2,powerList,px2mm,50);
saveFile = 'report_allTrialMotionGrid_2_50Hz';
run_saveFigs(figPath,saveFile,exts,doSave);

report_allTrialMotionGrid(trialActograms3,stimIDs3,powerList,px2mm,100);
saveFile = 'report_allTrialMotionGrid_3_100Hz';
run_saveFigs(figPath,saveFile,exts,doSave);

% extinction grid
report_allTrialMotionGrid(trialActograms6,stimIDs6,5,px2mm,20);
saveFile = 'report_allTrialMotionGrid_6_extinction';
run_saveFigs(figPath,saveFile,exts,doSave);

% zDist analysis
zDist5 = report_openField(trialActograms5,stimIDs5,powerList,px2mm,zParams,0);
saveFile = 'report_openField_5_0Hz';
run_saveFigs(figPath,saveFile,exts,doSave);
zDist1 = report_openField(trialActograms1,stimIDs1,powerList,px2mm,zParams,20);
saveFile = 'report_openField_1_20Hz';
run_saveFigs(figPath,saveFile,exts,doSave);
zDist2 = report_openField(trialActograms2,stimIDs2,powerList,px2mm,zParams,50);
saveFile = 'report_openField_2_50Hz';
run_saveFigs(figPath,saveFile,exts,doSave);
zDist3 = report_openField(trialActograms3,stimIDs3,powerList,px2mm,zParams,100);
saveFile = 'report_openField_3_100Hz';
run_saveFigs(figPath,saveFile,exts,doSave);

% all zDist
all_zDist = [zDist5 zDist1 zDist2 zDist3];
report_zDist(all_zDist,powerList);
saveFile = 'report_zDist_5-1-2-3';
run_saveFigs(figPath,saveFile,exts,doSave);