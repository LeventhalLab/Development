if ~exist('selectedLFPFiles')
    load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
    load('session_20180919_NakamuraMRL.mat', 'all_trials')
    load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
    load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
end
load('LFPfiles_local_matt.mat');

doSetup = false;

iSession = 0;
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    disp([num2str(iSession),':',LFPfiles_local{iNeuron}(end-30:end)]);
end

tWindow = 0.5;
freqList = 2.5;
Wlength = 400;
eventNames = {eventFieldnames{1},eventFieldnames{4}};

if doSetup
    WRT = struct;
    iSession = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(iSession);
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        trials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(trials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        sevFilt = artifactThreshv2(sevFilt,2000);
        sevFilt = sevFilt - mean(sevFilt);
        
        [W,all_data] = eventsLFPv2(trials,sevFilt,tWindow*2,Fs,freqList,eventNames);
        [Wz_power,~] = zScoreW(W,Wlength); % power Z-score
        WRT(iSession).trialIds = trialIds;
        WRT(iSession).allTimes = allTimes;
        WRT(iSession).Wz_power = Wz_power;%abs(W).^2;
    end
end

% % totalTrials = 0;
% % totalRts = 0;
% % for iSession = 1%:numel(WRT)
% %     totalTrials = totalTrials + size(WRT(iSession).Wz_power,3);
% %     totalRts = totalRts + numel(WRT(iSession).trialIds);
% % end

close all
ff(1200,400);
rows = 1;
cols = 3;
iEvent = 1;
n = 1;
op = 0.15;
prettyNames = {'Cue','Nose Out'};
mean_data = [];
lns = [];

for iSession = 1:numel(WRT)
    disp(iSession);
    delta_corr = zeros(numel(eventNames),size(WRT(iSession).Wz_power,3));
    rt_corr = zeros(1,numel(WRT(iSession).trialIds));
    curPos_delta = 1;
    curPos_rt = 1;
    for iEvent = 1:numel(eventNames)
        
        thisPower = mean(squeeze(WRT(iSession).Wz_power(iEvent,:,:)));
        delta_corr(iEvent,:) = thisPower;
        
        if iEvent == 1
            theseTrials = WRT(iSession).trialIds;
            [v,k] = sort(theseTrials);
            theseRT = WRT(iSession).allTimes;
            theseRT = theseRT(k);
            rt_corr(1,:) = theseRT;
        end
    end
    
    nR = 10;
    r_plot = zeros(3,nR);
    p_plot = zeros(3,nR);
    for n = 1:nR
        for iEvent = 1:numel(eventNames)
            data = squeeze(delta_corr(iEvent,:));
            [data_rm,Ix] = rmoutliers(data);
            x = data_rm(1:end-n)';
            y = data_rm(n+1:end)';
            [r,p] = corr(x,y);
            r_plot(iEvent,n) = r;
            p_plot(iEvent,n) = p;
        end
    end
    
    for n = 1:nR
        data = squeeze(rt_corr(1,:));
        data_rm = data(data > 0);
        x = data_rm(1:end-n)';
        y = data_rm(n+1:end)';
        [r,p] = corr(x,y);
        r_plot(3,n) = r;
        p_plot(3,n) = p;
    end
    
    t = fliplr(-(1:nR));
    for iEvent = 1:numel(eventNames)
        subplot(rows,cols,prc(cols,[1,iEvent]));
        plot(t,r_plot(iEvent,-t),'-','linewidth',1,'color',[0 0 0 op]);
        mean_data(iEvent,iSession,:) = r_plot(iEvent,-t);
        hold on;
        ps = p_plot(iEvent,:);
        plot(xlim,[0,0],':','color',[0 0 0 0.3]);
        plot(-find(ps < 0.05),r_plot(iEvent,ps < 0.05),'*','color',[1 0 0 op]);
        title(prettyNames{iEvent});
        xlabel('Trials back');
        ylabel('Corr. Coeff');
        xlim([min(t) max(t)]);
        xticks(t);
        ylim([-1 1]);
        set(gca,'fontsize',14);
    end
    
    subplot(rows,cols,prc(cols,[1,3]));
    lns(1) = plot(t,r_plot(3,-t),'-','linewidth',1,'color',[0 0 0 op]);
    mean_data(3,iSession,:) = r_plot(3,-t);
    hold on;
    ps = p_plot(3,:);
    plot(xlim,[0,0],':','color',[0 0 0 0.3]);
    if sum(ps < 0.05) > 0
        lns(3) = plot(-find(ps < 0.05),r_plot(3,ps < 0.05),'*','color',[1 0 0 op]);
    end
    title('Reaction Time');
    xlabel('Trials back');
    xticks(t);
    ylabel('Corr. Coeff');
    xlim([min(t) max(t)]);
    ylim([-1 1]);
    set(gca,'fontsize',14);
    drawnow;
end

for ii = 1:3
    subplot(rows,cols,ii);
    lns(2) = plot(t,squeeze(mean(mean_data(ii,:,:))),'k-','linewidth',2);
end
legend(lns,{'Single Session','mean(All Sessions)','p < 0.05'},'location','northwest');
legend box off;