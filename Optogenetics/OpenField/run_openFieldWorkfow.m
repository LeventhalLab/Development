doSetup = false;

if doSetup
    % single session video (contains all trials)
    filename = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/videos_overhead/R0244_20180330_01-480p.mov';

    % extract trials from LED
    startStop = [180,1680];
    trialTimes = videoTrialTimes(filename,startStop);

    % chop session into trial videos
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0244/R0244-openfield/20180330/matlab/session1';
    videoFiles = chopVideos(filename,savePath,trialTimes);

    % analyze each trial
    resizePx = 200;
    trialActograms = processActograms(savePath,resizePx);
end

stimIDs_20180330 = [4 2 1 1 2 3 1 5 1 1 4 3 5 3 4 5 2 3 4 3 2 4 2 5 5];

colors = lines(5);
stimID_actograms = zeros(5,5); % stimID x trial
fillIdxs = ones(5,1);
for iTrial = 1:size(trialActograms,1)
    actogram = trialActograms{iTrial,3};
    stimID = stimIDs_20180330(trialActograms{iTrial,2});
    stimID_actograms(stimID,fillIdxs(stimID)) = mean(actogram);
    fillIdxs(stimID) = fillIdxs(stimID) + 1;
end

minMove = min(min(stimID_actograms));
figuree(600,600);
subplot(211);
bar(normalize((stimID_actograms-minMove))');
xlabel('trials');
ylabel('movement');
title('trial by trial');

agg_mean = mean((stimID_actograms-minMove)');
subplot(212);
bar(normalize(agg_mean - min(agg_mean)));
xlabel('trials');
ylabel('movement');
title('aggregate');