doSetup = false;
stimIDs1 = [4 2 1 1 2 3 1 5 1 1 4 3 5 3 4 5 2 3 4 3 2 4 2 5 5];
stimIDs2 = [4 2 1 1 2 3 1 5 1 1 4 3 5 3 4 5 2 3 4 3 2 4 2 5 5];
stimIDs3 = [4 2 1 1 2 3 1 5 1 1 4 3 5 3 4 5 2 3 4 3 2 4 2 5 5];
stimIDs4 = [0 0 0 0 0 0 0 0 0 0];
stimIDs5 = [4 2 1 1 2 3 1 5 1 1 4 3 5 3 4 5 2 3 4 3 2 4 2 5 5];
stimIDs6 = [5 5 5 5 5 5 5 5 5 5];

% Generate all the data
% also see: /Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/Optogenetics/OpenField/R0244_OpenFieldOpto_config.m
powerList = logFreqList([1 30],5);

% single session video (contains all trials)
filename1 = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/videos_overhead/R0244_20180330_01-480p.mov';
filename2 = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/videos_overhead/R0244_20180330_02-480p.mov';
filename3 = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/videos_overhead/R0244_20180330_03-480p.mov';
filename4 = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/videos_overhead/R0244_20180330_04-480p.mov';
filename5 = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/videos_overhead/R0244_20180330_05-480p.mov';
filename6 = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/videos_overhead/R0244_20180330_06-480p.mov';

% extract trials from LED
startStop1 = [180,1680];
startStop2 = [40,1544];
startStop3 = [46,1560];
startStop4 = [60,660];
startStop5 = [60,1552];
startStop6 = [68,1452];

trialTimes1 = videoTrialTimes(filename1,startStop1);
trialTimes2 = videoTrialTimes(filename2,startStop2);
trialTimes3 = videoTrialTimes(filename3,startStop3);
trialTimes4 = videoTrialTimes(filename4,startStop4);
trialTimes5 = videoTrialTimes(filename5,startStop5);
trialTimes6 = videoTrialTimes(filename6,startStop6);

% chop session into trial videos
savePath1 = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/matlab/session1';
savePath2 = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/matlab/session2';
savePath3 = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/matlab/session3';
savePath4 = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/matlab/session4';
savePath5 = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/matlab/session5';
savePath6 = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/matlab/session6';

videoFiles1 = chopVideos(filename1,savePath1,trialTimes1);
videoFiles2 = chopVideos(filename2,savePath2,trialTimes2);
videoFiles3 = chopVideos(filename3,savePath3,trialTimes3);
videoFiles4 = chopVideos(filename4,savePath4,trialTimes4);
videoFiles5 = chopVideos(filename5,savePath5,trialTimes5);
videoFiles6 = chopVideos(filename6,savePath6,trialTimes6);

% analyze each trial
resizePx = 200;
trialActograms1 = processActograms(savePath1,resizePx);
trialActograms2 = processActograms(savePath2,resizePx);
trialActograms3 = processActograms(savePath3,resizePx);
trialActograms4 = processActograms(savePath4,resizePx);
trialActograms5 = processActograms(savePath5,resizePx);
trialActograms6 = processActograms(savePath6,resizePx);

save('mat-files/20180330_session1_data','powerList','filename1','startStop1','trialTimes1','savePath1','videoFiles1','trialActograms1','px2mm','resizePx','stimIDs1');
save('mat-files/20180330_session2_data','powerList','filename2','startStop2','trialTimes2','savePath2','videoFiles2','trialActograms2','px2mm','resizePx','stimIDs2');
save('mat-files/20180330_session3_data','powerList','filename3','startStop3','trialTimes3','savePath3','videoFiles3','trialActograms3','px2mm','resizePx','stimIDs3');
save('mat-files/20180330_session4_data','powerList','filename4','startStop4','trialTimes4','savePath4','videoFiles4','trialActograms4','px2mm','resizePx','stimIDs4');
save('mat-files/20180330_session5_data','powerList','filename5','startStop5','trialTimes5','savePath5','videoFiles5','trialActograms5','px2mm','resizePx','stimIDs5');
save('mat-files/20180330_session6_data','powerList','filename6','startStop6','trialTimes6','savePath6','videoFiles6','trialActograms6','px2mm','resizePx','stimIDs6');

% get px2mm
px2mm = 2.5098;
filename = fullfile(savePath,trialActograms{1,1});
px2mm = openField_px2mm(filename,resizePx);