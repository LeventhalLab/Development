% how many artifacts do we get rid of?
if ~exist('all_trials')
    load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
    load('session_20180919_NakamuraMRL.mat', 'all_trials')
    load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
    load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
    load('session_20180919_NakamuraMRL.mat', 'all_ts')
    load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local_altLookup')
    load('session_20180919_NakamuraMRL.mat', 'analysisConf')
end
load('LFPfiles_local_matt');
nexPath = '/Users/matt/Documents/Data/ChoiceTask/NEX Files';

loc_count = [];
iSession = 0;
nBins = 500;
t = linspace(0,60*60,nBins); % 1 hour of seconds
bin_mat = zeros(30,nBins);
affectedTrials = 0;
close all;
ff(1000,1000);
rows = 3;
cols = 2;
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    sessionName = analysisConf.sessionConfs{iSession,1}.sessions__name;
    filelist = dir(fullfile(nexPath,[sessionName,'*']));
    load(fullfile(filelist(1).folder,filelist(1).name));
    behaviorStartTime = getBehaviorStartTime(nexStruct);
    disp(iSession);
    sevFile = LFPfiles_local{iNeuron};
    trials = all_trials{iNeuron};
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
    [sevFilta,locs] = artifactThreshv2(sevFilt,2000);
    if iSession == 11
        xs = round([7.430876e+04, 2.816820e+05]);
        xt = round(7.9616e+04) / Fs;
        tplot = linspace(0,diff(xs)/Fs,diff(xs)+1);
        for iPlot = 1:2
            subplot(rows,cols,iPlot);
            plot(tplot,sevFilt(xs(1):xs(2)));
            hold on;
            plot(tplot,sevFilta(xs(1):xs(2)));
            xlim([0 max(tplot)]);
            xlabel('Time (s)')
            ylabel('uV');
            title('Session 11 Line pop');
            set(gca,'fontSize',12);
        end
        ylim([-500 500]);
        xlim([xt-1 xt+1]);
        legend({'original','artifact removed'});
    end
    for iLoc = 1:numel(locs)
        ts = locs(iLoc) / Fs;
        id = closest(t,ts);
        bin_mat(iSession,id) = 2;
    end
% % % %     ts = trials(1).timestamps.cueOn + behaviorStartTime;
% % % %     id = closest(t,ts);
% % % %     bin_mat(iSession,id) = 1;
    startFlag = 0;
    for iTrial = 1:numel(trials)
        if trials(iTrial).valid
            ts = trials(iTrial).timestamps.cueOn + behaviorStartTime;
            id = closest(t,ts);
            if id <= size(bin_mat,2)
                if startFlag
                    if bin_mat(iSession,id) == 2
                        bin_mat(iSession,id) = 3; % escalate to conflict
                        affectedTrials = affectedTrials + 1;
                    end
                else
                    bin_mat(iSession,id) = 1;
                    startFlag = 1;
                end
            end
        end
    end
    loc_count(iSession) = numel(locs);
end

subplot(rows,cols,[3:6]);
colors = [0.9 0.9 0.9;1 0 0;0 0 0;0 1 0];
lns = [];
for ii = 1:size(colors,1)
    lns(ii) = plot([-5,-6],[-7,-8],'color',colors(ii,:),'lineWidth',3);
    hold on;
end
legend(lns,{'none','start behavior','artifact','artifact & trial'},'location','southoutside');
imagesc(bin_mat);
colormap(colors);
yticks(1:30);
ylim([0.5 30.5]);
ylabel('Session #')
xticks([0.5 nBins]);
xticklabels({'0','60'});
xlim([0.5 nBins]);
xlabel('Time (min)');
set(gca,'fontSize',12);
set(gca, 'TickDir', 'out')
title('High Amplitude Artifact Removal');