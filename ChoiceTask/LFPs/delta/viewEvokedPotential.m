% % load('session_20181106_entrainmentData.mat', 'selectedLFPFiles');
% % load('session_20181106_entrainmentData.mat', 'eventFieldnames');
% % load('session_20181106_entrainmentData.mat', 'LFPfiles_local');
% % load('session_20181106_entrainmentData.mat', 'all_trials');

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/delta';

doSetup = true;

doRaw = true;
doSession = false;
doTrials = false;

freqList = 2.5; % hilbert method
tWindow = 1;
zThresh = 5;
Wlength = 1000;

if doSetup
    % tWindow = 1 here, 2 below where z-scoring occurs
    for iSession = 19
        iNeuron = selectedLFPFiles(iSession);
        disp(num2str(iSession));
        sevFile = LFPfiles_local{iNeuron};
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        curTrials = all_trials{iNeuron};

        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        all_data = all_data(:,:,keepTrials);
        allTimes = allTimes(keepTrials);
    end
end

if doRaw
    doSave = false;
    useEvents = [3,4];
    rows = 1;
    cols = 2;
    lineWidth = 1;
    xlimVals = [-0.8 0.8];
    nSmooth = 300;
    divideBy = 10;
    t = linspace(-tWindow,tWindow,size(all_data,2));
    colors = cool(numel(allTimes));
    h = ff(800,800);
    for iEvent = 1:2
        subplot(rows,cols,prc(cols,[1,iEvent]));
        for iTrial = 1:numel(allTimes)
            data = smooth(all_data(useEvents(iEvent),:,iTrial),nSmooth);
            plot(t,data,'color',[colors(iTrial,:),0.1]);
            hold on;
        end
        ylabel('raw data trials');
        xlim(xlimVals);
        xticks(sort([xlim,0]));
        title({eventFieldnames{useEvents(iEvent)}});
        grid on;
    end
end

if doSession
    close all
    doSave = false;
    t = linspace(-tWindow,tWindow,Wlength);
    t_all = linspace(-tWindow*2,tWindow*2,size(all_data,2));
    rows = 4;
    cols = 7;
    xlimVals = [-0.4 0.4];
    for iSession = 28
        iNeuron = selectedLFPFiles(iSession);
        disp(num2str(iSession));
        sevFile = LFPfiles_local{iNeuron};
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        curTrials = all_trials{iNeuron};

        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow*2,Fs,freqList,eventFieldnames);
        keepTrials = threshTrialData(all_data,zThresh);
        W = W(:,:,keepTrials,:);
        [Wz,Wz_angle] = zScoreW(W,Wlength); % power Z-score
        all_data = all_data(:,:,keepTrials);
    
        h = ff(1400,800);
        for iEvent = 1:7
            subplot(rows,cols,prc(cols,[1 iEvent]));
            data = squeeze(Wz(iEvent,:,:));
            imagesc(t,1:size(Wz,3),data');
            colormap(gca,jet);
            caxis([-2 5]);
            xlim(xlimVals);
            xticks(sort([0,xlim]));
            if iEvent == 1
                ylabel('trials by RT');
                yticks([1 size(Wz,3)]);
                title({['S',num2str(iSession,'%02d'),', ',num2str(freqList,'%1.2f'),'Hz'],eventFieldnames{iEvent},'power'});
            else
                yticks([]);
                title({'',eventFieldnames{iEvent},'power'});
            end
            grid on;
            
            subplot(rows,cols,prc(cols,[2 iEvent]));
            data = squeeze(Wz_angle(iEvent,:,:));
            imagesc(t,1:size(Wz_angle,3),data');
            colormap(gca,parula);
            caxis([-pi pi]);
            xlim(xlimVals);
            xticks(sort([0,xlim]));
            title('phase');
            yticks([1 size(Wz,3)])
            if iEvent == 1
                ylabel('trials by RT');
            end
            grid on;
            
            subplot(rows,cols,prc(cols,[3 iEvent]));
            timeMRL = [];
            for iTime = 1:size(Wz_angle,2)
                timeMRL(iTime) = circ_r(squeeze(Wz_angle(iEvent,iTime,:)));
            end
            plot(t,timeMRL,'k-','linewidth',2);
            xlim(xlimVals);
            xticks(sort([0,xlim]));
            ylim([0 1]);
            yticks(ylim);
            if iEvent == 1
                ylabel('MRL');
            end
            title('MRL');
            grid on;
            
            subplot(rows,cols,prc(cols,[4 iEvent]));
            data = mean(squeeze(all_data(iEvent,:,:)),2);
            plot(t_all,data,'linewidth',2);
            if iEvent == 1
                ylabel('uV');
                xtrema = round((max(data) - min(data)) * 2);
                ylimVals = [-xtrema xtrema];
            end
            xlim(xlimVals);
            xticks(sort([0,xlim]));
            ylim(ylimVals);
            yticks(sort([0,ylim]));
            title('mean raw data');
            grid on;
        end
        set(gcf,'color','w');
        if doSave
            saveas(h,fullfile(savePath,['deltaERP_S',num2str(iSession,'%02d'),'.png']));
            close(h);
        end
    end
end

if doTrials
    doSave = true;
    useEvents = [3,4];
    rows = 2;
    cols = 2;
    lineWidth = 1;
    xlimVals = [-0.8 0.8];
    nSmooth = 200;
    t = linspace(-tWindow,tWindow,size(all_data,2));
    for iTrial = 1:numel(allTimes)
        h = ff(1000,500);
        for iEvent = 1:2
            subplot(rows,cols,prc(cols,[1 iEvent]));
            yyaxis left;
            plot(t,all_data(useEvents(iEvent),:,iTrial),'k-','lineWidth',lineWidth);
            ylim(repmat(max(abs(ylim)),[1 2]).*[-1 1]);
            yticks(sort([ylim,0]));
            yyaxis right;
            plot(t,smooth(all_data(useEvents(iEvent),:,iTrial),nSmooth),'r-','lineWidth',2);
            ylim(repmat(max(abs(ylim)),[1 2]).*[-1 1]);
            yticks(sort([ylim,0]));
            xlim(xlimVals);
            xticks(sort([xlim,0]));
            title({eventFieldnames{useEvents(iEvent)},['Raw, RT = ',num2str(allTimes(iTrial),2),'s']});
            grid on;

            subplot(rows,cols,prc(cols,[2 iEvent]));
            yyaxis left;
            plot(t,real(W(useEvents(iEvent),:,iTrial)),'lineWidth',lineWidth);
            xlim(xlimVals);
            xticks(sort([xlim,0]));
            ylabel('real');
            yticks(ylim);

            yyaxis right;
            plot(t,angle(W(useEvents(iEvent),:,iTrial)),'lineWidth',lineWidth);
            xlim(xlimVals);
            xticks(sort([xlim,0]));
            ylabel('phase');
            yticks([-pi,0,pi]);
            yticklabels({'-\pi','0','\pi'});
            ylim([-4 4]);
            xlabel('time (s)');
            title('\delta-band');
            grid on;
        end

        set(gcf,'color','w');
        if doSave
            saveas(h,fullfile(savePath,['deltaRawPhase_s',num2str(iSession,'%02d'),'_t',num2str(iTrial,'%03d'),'.png']));
            close(h);
        end
    end
end