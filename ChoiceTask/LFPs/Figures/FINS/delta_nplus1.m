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

totalTrials = 0;
totalRts = 0;
for iSession = 1%:numel(WRT)
    totalTrials = totalTrials + size(WRT(iSession).Wz_power,3);
    totalRts = totalRts + numel(WRT(iSession).trialIds);
end

delta_corr = zeros(numel(eventNames),totalTrials);
rt_corr = zeros(1,totalRts);
curPos_delta = 1;
curPos_rt = 1;
for iEvent = 1:numel(eventNames)
    for iSession = 1%:numel(WRT)
        thisPower = mean(squeeze(WRT(iSession).Wz_power(iEvent,:,:)));
        delta_corr(iEvent,curPos_delta:curPos_delta+numel(thisPower)-1) = thisPower;
        
        if iEvent == 1
            theseTrials = WRT(iSession).trialIds;
            [v,k] = sort(theseTrials);
            theseRT = WRT(iSession).allTimes;
            theseRT = theseRT(k);
            rt_corr(1,curPos_rt:curPos_rt+numel(theseRT)-1) = theseRT;
        end
        curPos_delta = curPos_delta + numel(thisPower);
        curPos_rt = curPos_rt + numel(theseRT);
    end
    curPos_delta = 1;
    curPos_rt = 1;
end

nR = 10;
r_plot = zeros(3,nR);
p_plot = zeros(3,nR);
for n = 0:nR
    for iEvent = 1:numel(eventNames)
        data = squeeze(delta_corr(iEvent,:));
        [data_rm,Ix] = rmoutliers(data);
        x = data_rm(1:end-n)';
        y = data_rm(n+1:end)';
        [r,p] = corr(x,y);
        r_plot(iEvent,n+1) = r;
        p_plot(iEvent,n+1) = p;
    end
end

for n = 0:nR
    data = squeeze(rt_corr(1,:));
    data_rm = data(data > 0);
    x = data_rm(1:end-n)';
    y = data_rm(n+1:end)';
    [r,p] = corr(x,y);
    r_plot(3,n+1) = r;
    p_plot(3,n+1) = p;
end

close all
ff(1200,400);
rows = 2;
cols = numel(eventNames)+1;
n = 1;
for iEvent = 1:numel(eventNames)
    data = squeeze(delta_corr(iEvent,:));
    [data_rm,Ix] = rmoutliers(data);
    x = data_rm(1:end-n)';
    y = data_rm(n+1:end)';
    
    subplot(rows,cols,prc(cols,[1,iEvent]));
    f = fit(x,y,'poly1');
    plot(f,x,y,'k.');
    [r,p] = corr(x,y);
%     xlim([0,20]);
%     ylim(xlim);
    title({eventNames{iEvent},sprintf('p = %1.2e, r = %1.2f',p,r)});
    xlabel('\delta power trial_n');
    ylabel(['\delta power trial_{n+',num2str(n),'}']);
    
    subplot(rows,cols,prc(cols,[2,iEvent]));
    plot(r_plot(iEvent,:),'k-','linewidth',2);
    hold on;
    ps = p_plot(iEvent,:);
    ln1 = plot(find(ps < 0.05),r_plot(iEvent,ps < 0.05),'r*');
    title('Corr. Coeff (r)');
    xlabel('trial_n x trial_{n+x}');
    ylabel('r');
    xlim([0 numel(r_plot(iEvent,:))]);
    ylim([0 1]);
    legend(ln1,'p < 0.05')
end

data = squeeze(rt_corr(1,:));
data_rm = data(data > 0);
x = data_rm(1:end-n)';
y = data_rm(n+1:end)';
subplot(rows,cols,prc(cols,[1,3]));
f = fit(x,y,'poly1');
plot(f,x,y,'k.');
[r,p] = corr(x,y);
xlim([0,0.8]);
ylim(xlim);
title({'Trial RT',sprintf('p = %1.2e, r = %1.2f',p,r)});
xlabel('RT (s) trial_n');
ylabel(['RT (s) trial_{n+',num2str(n),'}']);

subplot(rows,cols,prc(cols,[2,3]));
plot(r_plot(3,:),'k-','linewidth',2);
hold on;
ps = p_plot(3,:);
ln1 = plot(find(ps < 0.05),r_plot(3,ps < 0.05),'r*');
title('Corr. Coeff (r)');
xlabel('trial_n x trial_{n+x}');
ylabel('r');
xlim([1 numel(r_plot(iEvent,:))]);
ylim([0 0.5]);
legend(ln1,'p < 0.05');