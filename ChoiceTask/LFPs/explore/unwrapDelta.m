savePath = '/Users/matt/Documents/Data/ChoiceTask/LFPs/delta/unwrap';

figPath = '/Users/matt/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.02 .02];
doLabels = false;
doSave = true;

if ~exist('selectedLFPFiles')
    load('session_20181106_entrainmentData.mat', 'selectedLFPFiles');
    load('session_20181106_entrainmentData.mat', 'eventFieldnames');
    % %     load('session_20181106_entrainmentData.mat', 'LFPfiles_local');
    load('session_20181106_entrainmentData.mat', 'all_trials');
end
load('LFPfiles_local_matt');

eventFieldnames_wFake = {eventFieldnames{:} 'interTrial'};
tWindow = 1;
zThresh = 5;
xlimVals = [-1 1];
freqList = 2.5;
useSessions = [1:30];
dataLabel = 'allSessions';
minpeakdist = 200;
minpeakh = 1e-4;

if ~exist('dataArr')
    dataPhase = [];
    dataArr = [];
    timeArr = [];
    locsCell = {};
    phaseSessions = {};
    trialCount = zeros(8,1);
    for iSession = useSessions
        iNeuron = selectedLFPFiles(iSession);
        disp(num2str(iSession));
        sevFile = LFPfiles_local{iNeuron};
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        trials = all_trials{iNeuron};
        trials = addEventToTrials(trials,'interTrial');
        
        [trialIds,allTimes] = sortTrialsBy(trials,'RT');
        [W,all_data] = eventsLFPv2(trials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames_wFake);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        all_data = all_data(:,:,keepTrials);
        allTimes = allTimes(keepTrials);
        
        for iEvent = 1:8
            if numel(locsCell) < iEvent
                locsCell{iEvent} = []; % init
            end
            for iTrial = 1:size(W,3)
                trialCount(iEvent) = trialCount(iEvent) + 1;
                if iEvent == 1
                    timeArr(trialCount(iEvent)) = allTimes(iTrial);
                end
                trialPhase = angle(squeeze(W(iEvent,:,iTrial)));
                trialDiffUnwrapped = diff(unwrap(trialPhase),2);
                % %                 [locs,pks] = peakseek(trialDiffUnwrapped,minpeakdist,minpeakh);
                % %                 locsCell{iEvent} = [locsCell{iEvent} locs];
                dataPhase(iEvent,trialCount(iEvent),:) = trialPhase;
                dataArr(iEvent,trialCount(iEvent),:) = trialDiffUnwrapped;
            end
            phaseSessions{iSession} = angle(W);
        end
    end
    % clean
    t = [];
    trialCount = 0;
    for iTrial = 1:size(dataPhase,2)
        saveIt = true;
        for iEvent = 1:size(dataPhase,1)
            if unwrap(squeeze(dataPhase(iEvent,iTrial,:))) < 0
                saveIt = false;
            end
        end
        if saveIt
            trialCount = trialCount + 1;
            t(:,trialCount,:) = squeeze(dataPhase(:,iTrial,:));
        end
    end
    dataPhase = t;
end

% per session
doAllSessions = true;
if doAllSessions
    useSessions = 1;
else
    useSessions = 1:numel(phaseSessions);
end
close all;
useEvents = [2,3,4];
rows = 3;
cols = numel(useEvents);
lw = 0.05;
maxr = 0.3;
colors = lines(2);
nLines = 75;
lightColor = [repmat(0.5,[1 3]),0.25];
for iSession = useSessions
    h = ff(800,400);
    iCol = 0;
    lns = [];
    for iEvent = useEvents
        iCol = iCol + 1;
        if doAllSessions
            thisPhase = squeeze(dataPhase(iEvent,:,:));
        else
            thisPhase = squeeze(phaseSessions{iSession}(iEvent,:,:))';
        end
        t = linspace(-tWindow,tWindow,size(thisPhase,2));
        
        subplot_tight(rows,cols,prc(cols,[1,iCol]),subplotMargins);
        useTrials = randsample(1:size(thisPhase,1),nLines);
        for iTrial = useTrials %1:size(thisPhase,1)
            plot(t,thisPhase(iTrial,:),'color',lightColor,'lineWidth',lw);
            hold on;
        end
        plot(t,circ_mean(thisPhase),'color',colors(2,:),'linewidth',1);
        xticks([-tWindow 0 tWindow]);
        xlim([-tWindow tWindow]);
        ylim([-4 4]);
        yticks([-pi 0 pi]);
        plot([0,0],ylim,'k:'); % center line
        if doLabels
            if iCol == 1
                if doAllSessions
                    title({['allSessions, ',num2str(size(thisPhase,1)),' trials'],eventFieldnames_wFake{iEvent},'Phase'});
                else
                    title({['session ',num2str(iSession),', ',num2str(size(thisPhase,1)),' trials'],eventFieldnames_wFake{iEvent},'Phase'});
                end
            else
                title({eventFieldnames_wFake{iEvent},'Phase'});
            end
            xlabel('Time (s)');
            grid on;
            yticklabels({'-\pi','0','\pi'});
        else
            xticks([]);
            xticklabels([]);
            yticklabels([]);
        end
        
        subplot_tight(rows,cols,prc(cols,[2,iCol]),subplotMargins);
        
        useTrials = randsample(1:size(thisPhase,1),nLines);
        for iTrial = useTrials %1:size(thisPhase,1)
            plot(t,unwrap(thisPhase(iTrial,:)),'color',lightColor,'lineWidth',lw);
            hold on;
        end
        plot(t,mean(unwrap(thisPhase,pi,2)),'color','k','linewidth',1);
        xticks([-tWindow 0 tWindow]);
        xlim([-tWindow tWindow]);
        ylim([-10 40]);
        yticks(sort([0,ylim]));
        plot([0,0],ylim,'k:'); % center line
        box on;
        grid on;
        if doLabels
            title('Phase Unwrapped');
            xlabel('Time (s)');
        else
            xticks([]);
            xticklabels([]);
            yticklabels([]);
        end
        
        subplot_tight(rows,cols,prc(cols,[3,iCol]),subplotMargins);
        t0 = round(size(thisPhase,2)/2);
        phaseMean = circ_mean(thisPhase(:,t0));
% %         polarplot([phaseMean,phaseMean],[0,maxr],'linewidth',1,'color',colors(2,:));
% %         hold on;
        polarhistogram(thisPhase(:,t0),12,'FaceColor',colors(2,:),'normalization','probability','FaceAlpha',1);
        rlim([0 maxr]);
        pax = gca;
        pax.ThetaZeroLocation = 'left';
        thetaticks([0,90,180,270]);
        rlim([0 0.3]);
        rticks(rlim);
        if ~doLabels
            rticklabels({});
            thetaticklabels({});
        end
        
% % % %         t = linspace(-tWindow,tWindow,size(thisPhase,2)-1);
% % % %         subplot(rows,cols,prc(cols,[4,iCol]));
% % % %         trialData = [];
% % % %         for iTrial = 1:size(thisPhase,1)
% % % %             trialData(iTrial,:) = diff(unwrap(thisPhase(iTrial,:)));
% % % %             plot(t,trialData(iTrial,:),'color',lightColor,'lineWidth',lw);
% % % %             hold on;
% % % %         end
% % % %         lns(1) = plot(t,mean(trialData),'color','r','lineWidth',2);
% % % %         lns(2) = plot(t,median(trialData),'color','b','lineWidth',2);
% % % %         xticks([-tWindow 0 tWindow]);
% % % %         xlim([-tWindow tWindow]);
% % % %         ylim([0 0.025]);
% % % %         yticks(ylim);
% % % %         title('Diff(Phase Unwrapped)');
% % % %         xlabel('Time (s)');
% % % %         grid on;
    end
    % add median and mean labels
    if doLabels
        legend(lns,{'mean','median'});
    end
% % % %     if doSave
% % % %         if doAllSessions
% % % %             saveas(h,fullfile(savePath,['deltaUnwrapped_allSessions.png']));
% % % %         else
% % % %             saveas(h,fullfile(savePath,['deltaUnwrapped_','session',num2str(iSession,'%02d'),'.png']));
% % % %         end
% % % %         close(h);
% % % %     end
% %     tightfig; % does not work
    set(gcf,'color','w');
    if doSave
        setFig('','',[1.5,1.4]);
        print(gcf,'-painters','-depsc',fullfile(figPath,'UNWRAPPEDDELTA.eps'));
        close(h);
    end
end

% OLD CODE

% % % % doLabels = false;
% % % % % single example
% % % % close all;
% % % % nTrials = 100;
% % % % rows = 3;
% % % % cols = 2;
% % % % lightColor = repmat(0.7,[1 4]);
% % % % colors = lines(nTrials);
% % % % lw = 1;
% % % % h = ff(800,800);
% % % % iCol = 0;
% % % % doLabels = true;
% % % % for iEvent = 3:4
% % % %     iCol = iCol + 1;
% % % %     for iTrial = 1:nTrials
% % % %         thisPhase = squeeze(dataPhase(iEvent,iTrial,:));
% % % %         
% % % %         subplot_tight(rows,cols,prc(cols,[1 iCol]),subplotMargins);
% % % %         t = linspace(-tWindow,tWindow,size(dataPhase,3));
% % % %         plot(t,thisPhase,'color',colors(iTrial,:),'lineWidth',lw);
% % % %         hold on;
% % % %         xticks([-tWindow 0 tWindow]);
% % % %         xlim([-tWindow tWindow]);
% % % %         ylim([-4 4]);
% % % %         yticks([-pi 0 pi]);
% % % %         yticklabels({'-\pi','0','\pi'});
% % % %         if doLabels
% % % %             title({[eventFieldnames_wFake{iEvent},', ',num2str(nTrials),' trials'],'Phase'});
% % % %             xlabel('Time (s)');
% % % %         end
% % % %         
% % % %         subplot_tight(rows,cols,prc(cols,[2 iCol]),subplotMargins);
% % % %         t = linspace(-tWindow,tWindow,size(dataPhase,3)-1);
% % % %         plot(t,diff(unwrap(thisPhase)),'color',colors(iTrial,:),'lineWidth',lw);
% % % %         hold on;
% % % %         xticks([-tWindow 0 tWindow]);
% % % %         xlim([-tWindow tWindow]);
% % % %         ylim([-.03 .03]);
% % % %         yticks(sort([0 ylim]));
% % % %         if doLabels
% % % %             title("Unwrapped Phase'");
% % % %             xlabel('Time (s)');
% % % %         end
% % % %         
% % % %         subplot_tight(rows,cols,prc(cols,[3 iCol]),subplotMargins);
% % % %         plot(t,unwrap(thisPhase),'color',colors(iTrial,:),'lineWidth',lw);
% % % %         hold on;
% % % %         xticks([-tWindow 0 tWindow]);
% % % %         xlim([-tWindow tWindow]);
% % % %         ylim([-10 40]);
% % % %         yticks(sort([0 ylim]));
% % % %         if doLabels
% % % %             title('Unwrapped Phase');
% % % %             xlabel('Time (s)');
% % % %         end
% % % %     end
% % % % end

% % % % close all;
% % % % t = linspace(-tWindow,tWindow,size(dataArr,3));
% % % % h = ff(1400,300);
% % % % rows = 1;
% % % % cols = 8;
% % % % for iEvent = 4
% % % %     %     subplot(rows,cols,prc(cols,[1,iEvent]));
% % % %     for iTrial = 1:size(dataArr,2)
% % % %         plot(squeeze(dataArr(iEvent,iTrial,:)),'color',repmat(0.7,[1 4]));
% % % %         hold on;
% % % %     end
% % % %     thisData = median(squeeze(dataArr(iEvent,:,:)));
% % % %     plot(thisData,'-','color','k');
% % % %     ylim([-.00001 .00001]);
% % % % end

% END
% debug
doDebug = false;
if doDebug
    a = angle(squeeze(W(iEvent,:,iTrial)));
    h = ff(400,800);
    subplot(311);
    plot(a);
    xlim([1 numel(trialDiffUnwrapped)]);
    title('delta phase, single trial');
    
    subplot(312);
    plot(unwrap(a));
    xlim([1 numel(trialDiffUnwrapped)]);
    title('delta phase unwrapped');
    
    subplot(313);
    plot((diff(unwrap(a),2)));
    title('diff(unwrapped phase,2)');
    xlim([1 numel(trialDiffUnwrapped)]);
end

% save('20190410_unwrapDelta','dataArr','timeArr','dataLabel');
% save('20190410_unwrapDelta_notR0142','dataArr','timeArr','dataLabel');
% save('20190410_unwrapDelta_onlyR0142','dataArr','timeArr','dataLabel');
doArchive = false;
if doArchive
    % close all
    h = ff(1400,600);
    rows = 2;
    cols = 8;
    t = linspace(-tWindow,tWindow,size(dataArr,3));
    nTimes = 1;
    colors = copper(nTimes);
    timeMarks = round(linspace(1,numel(timeArr),nTimes+1));
    sorted_timeArr = sort(timeArr);
    timeValues = sorted_timeArr(timeMarks);
    nSmooth = 100;
    timeLabels = {};
    lns = [];
    for iTime = 1:nTimes
        useTrials = timeArr > timeValues(iTime) & timeArr < timeValues(iTime+1);
        timeLabels{iTime} = sprintf('%1.3f - %1.3f s',timeValues(iTime),timeValues(iTime+1));
        for iEvent = 1:cols
            subplot(rows,cols,prc(cols,[1 iEvent]));
            medn = mean(squeeze(dataArr(iEvent,useTrials,:)));% - mean(median(squeeze(dataArr(8,useTrials,:))));
            lns(iTime) = plot(t,smooth(medn,nSmooth),'-','linewidth',2,'color',colors(iTime,:));
            hold on;
            %         ylim([-6e-7 6e-7]);
            yticks(sort([ylim,0]));
            xticks(sort([xlim,0]));
            title(eventFieldnames_wFake{iEvent});
            plot([0 0],ylim,'k:');
            grid on;
            if iEvent == 1
                ylabel('median diff(phase,2)');
            end
            
            subplot(rows,cols,prc(cols,[2 iEvent]));
            nBins = 21;
            counts = histcounts(locsCell{iEvent},nBins);
            bar(linspace(-1,1,nBins),counts,'k');
            ylabel('# phase shifts');
            ylim([0 60]);
            grid on;
            hold on;
            yticks(ylim);
            plot([0 0],ylim,'k:');
        end
        
    end
    legend(lns,timeLabels);
    
    addNote(h,{'all sessions (2.5 Hz)','1. unwrap phase','2. Take diff(phase,2)','3. Plot median for all trials',...
        '','sorted by RT'});
    set(gcf,'color','w');
    if doSave
        saveas(h,fullfile(savePath,[dataLabel,'_deltaPhaseUnwrapped_n',num2str(nTimes),'.png']));
        close(h);
    end
end