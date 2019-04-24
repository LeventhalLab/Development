% SUASESSTRIAL, still using doSetup to init values, !!consider saving structures
if ~exist('all_ts')
    load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
    load('session_20180919_NakamuraMRL.mat', 'all_trials')
    load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
    load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
    load('session_20180919_NakamuraMRL.mat', 'all_ts')
end

figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.02 .02];

doSave1 = false;
doSave2 = true;
doLabels = false;

close all
tWindow = 1;
iTrial = 3;
eventFieldnames_wFake = {eventFieldnames{:} 'interTrial'};
useEvents = 2:4;
rows = 6;
cols = numel(useEvents);
xlimVals = [-1 1];
nSmooth = 200;
freqList = 2.5;
Wlength = 1000;
topRows = [10 16;11 17;12 18];
zThresh = 5;
% % reshape(1:6*3,[6,3]); % design

if ~exist('trial_Wz_power')
    trial_Wz_power = [];
    trial_Wz_phase = [];
    session_Wz_rayleigh_pval = [];
    compiledRTs = [];
    iSession = 0;
    trialCount = 0;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(iSession);
        sevFile = LFPfiles_local{iNeuron};
        trials = all_trials{iNeuron};
        trials = addEventToTrials(trials,'interTrial');
        [trialIds,allTimes] = sortTrialsBy(trials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        sevFilt = artifactThresh(sevFilt,[1],2000);
        sevFilt = sevFilt - mean(sevFilt);
        
        [W,all_data] = eventsLFPv2(trials(trialIds),sevFilt,tWindow*2,Fs,freqList,eventFieldnames_wFake);
        keepTrials = threshTrialData(all_data,zThresh);
        all_data = all_data(:,:,keepTrials);
        compiledRTs = [compiledRTs allTimes(keepTrials)];
        W = W(:,:,keepTrials,:);
        [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
        
        trialCount = trialCount + size(Wz_power,3);
        % iEvent, iTrial, iTime, iFreq
        if iSession == 1
            trial_Wz_power = Wz_power;
            trial_Wz_phase = Wz_phase;
        else
            trial_Wz_power(:,:,size(trial_Wz_power,3)+1:trialCount,:) = Wz_power;
            trial_Wz_phase(:,:,size(trial_Wz_phase,3)+1:trialCount,:) = Wz_phase;
        end
    end
    data_source = {trial_Wz_power trial_Wz_phase};
    iNeuron = 361;
    tsPeths = eventsPeth(trials(trialIds),all_ts{iNeuron},tWindow,eventFieldnames_wFake);
    tsPeths = tsPeths(keepTrials,:);
    [~,rtk] = sort(compiledRTs);
    % for iTrial == 3, session 30
    yTrialMark = rtk(end-91);
    t = linspace(-tWindow*2,tWindow*2,size(all_data,2));
    tz = linspace(-tWindow,tWindow,Wlength);
end

h = ff(800,800);
for iEvent = 1:numel(useEvents)
    subplot_tight(rows,cols,prc(cols,[1 iEvent]),subplotMargins);
    yyaxis left;
    plot(t,all_data(useEvents(iEvent),:,iTrial),'k-','lineWidth',0.5);
    hold on;
    plot([0,0],ylim,'k:'); % center line
    ylim([-250 250]);
    yticks(sort([ylim,0]));
    if doLabels
        ylabel('uV');
    else
        yticklabels({});
    end
    yyaxis right;
    realSignal = squeeze(real(W(useEvents(iEvent),:,iTrial)));
    plot(t,realSignal,'r-','lineWidth',1);
% %     plot(t,smooth(all_data(useEvents(iEvent),:,iTrial),nSmooth),'r-','lineWidth',1);
    ylim([-5 5]);
    yticks(sort([ylim,0]));
    xlim(xlimVals);
    xticks(sort([xlim,0]));
    if doLabels
        title(['Wideband trial ',num2str(iTrial),', RT = ',num2str(allTimes(iTrial),3),'s']);
        grid on;
    else
        yticklabels({});
        xticklabels({});
    end
    
    subplot_tight(rows,cols,prc(cols,[2 iEvent]),subplotMargins);
    yyaxis left;
    plot(tz,Wz_power(useEvents(iEvent),:,iTrial),'lineWidth',1);
    hold on;
    plot([0,0],ylim,'k:'); % center line
    xlim(xlimVals);
    xticks(sort([xlim,0]));
    ylim([-5 10]);
    yticks(sort([0,ylim]));
    if doLabels
        ylabel('z-power');
    else
        yticklabels({});
    end
    yyaxis right;
    plot(tz,Wz_phase(useEvents(iEvent),:,iTrial),'lineWidth',1);
    hold on;
    ts = tsPeths{iTrial,useEvents(iEvent)};
    for iTs = 1:numel(ts)
        plot([ts(iTs),ts(iTs)],[-1 1],'-','color','k');
    end
    xlim(xlimVals);
    xticks(sort([xlim,0]));
    yticks([-pi,0,pi]);
    ylim([-4 4]);
    if doLabels
        title({eventFieldnames{useEvents(iEvent)},['\delta trial ',num2str(iTrial),', unit ',num2str(iNeuron)]});
        grid on;
        ylabel('phase');
        yticklabels({'-\pi','0','\pi'});
        xlabel('time (s)');
    else
        yticklabels({});
        xticklabels({});
    end
    
    % add spike MRL
    subplot_tight(rows,cols,prc(cols,[3 iEvent]),subplotMargins);
    theta = [];
    for iTs = 1:numel(ts)
        tIdx = closest(tz,ts(iTs));
        theta(iTs) = Wz_phase(useEvents(iEvent),tIdx,iTrial);
    end
    colors = lines(2);
    polarhistogram(theta,10,'FaceColor',colors(2,:),'normalization','probability','FaceAlpha',1);
    pax = gca;
    pax.ThetaZeroLocation = 'left';
    thetaticks([0,90,180,270]);
    rlim([0 0.3]);
    rticks(rlim);
    if doLabels
        title({eventFieldnames{useEvents(iEvent)},['MRL trial ',num2str(iTrial),', unit ',num2str(iNeuron)]});
    else
        rticklabels({});
        thetaticklabels({});
    end
    
    % %     subplot_tight(rows,cols,prc(cols,[1 iEvent]));
    subplot_tight(rows,cols,[topRows(iEvent,1) topRows(iEvent,2)],subplotMargins);
    set(gca,'Visible','off')
    
    % export phases individually to deal with vector/print issue
    hh = ff(250,400);
    data = squeeze(trial_Wz_phase(useEvents(iEvent),:,rtk));
    imagesc(t,1:size(trial_Wz_phase,3),data');
    colormap(gca,parula);
    caxis([-pi pi]);
    hold on;
    plot(-1,yTrialMark,'k>','markersize',2);
    plot([0,0],ylim,'k:'); % center line
    if useEvents(iEvent) == 3
        plot(compiledRTs(rtk),1:numel(compiledRTs),'k-','linewidth',1);
    elseif useEvents(iEvent) == 4
        plot(-compiledRTs(rtk),1:numel(compiledRTs),'k-','linewidth',1);
    end
    xlim(xlimVals);
    xticks(sort([0,xlim]));
    ylim([1 size(trial_Wz_phase,3)]-11); % minus trials to handle vector/print issue
    yticks(ylim);
    box on;
    if doLabels
        ylabel('trials by RT');
        grid on;
    else
        yticklabels({});
        xticklabels({});
    end
    tightfig;
    set(gcf,'color','w');
    if doSave2
        setFig('','',[3.2,0]);
        print(gcf,'-painters','-depsc',fullfile(figPath,['SUASESSTRIAL_subplot',num2str(iEvent),'.eps']));
    end
    close(hh);
end

tightfig;
set(gcf,'color','w');
if doSave1
    setFig('','',[1.5,1.4]);
    print(gcf,'-painters','-depsc',fullfile(figPath,'SUASESSTRIAL.eps'));
    close(h);
end