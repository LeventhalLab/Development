savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/crossFrequencyRTMTPowerCorr';
doSetup = true;
doPlot = false;
doSave = true;

timingFields = {'RT','MT'};
tWindow = 1;
freqList = logFreqList([1 200],30);
Wlength = 200;
zThresh = 5;

rows = 4;
cols = 7;
climVals_rho = [-1 1];
climVals_pval = [0 0.1];
cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
cmap = mycmap(cmapPath);

if doSetup
    iSession = 0;
    all_timeCorrs_power_rho = [];
    all_timeCorrs_power_pval = [];
    all_timeCorrs_phase_rho = [];
    all_timeCorrs_phase_pval = [];
    for iNeuron = selectedLFPFiles'%1:numel(LFPfiles_local) %
        iSession = iSession + 1;
        disp(num2str(iNeuron));
        sevFile = LFPfiles_local{iNeuron};
        [~,name,~] = fileparts(sevFile);

        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        curTrials = all_trials{iNeuron};

        for iTiming = 1:2
            if doPlot
                h = figuree(1400,800);
            end
            timeCorrs_power_rho = [];
            timeCorrs_power_pval = [];
            timeCorrs_phase_rho = [];
            timeCorrs_phase_pval = [];
            [trialIds,allTimes] = sortTrialsBy(curTrials,timingFields{iTiming});
            [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
            
            keepTrials = threshTrialData(all_data,zThresh);
            W = W(:,:,keepTrials,:);
            allTimes = allTimes(keepTrials);
            
            [Wz,Wz_angle] = zScoreW(W,Wlength); % power Z-score
            for iFreq = 1:numel(freqList)
                for iTime = 1:size(Wz,2)
                    for iEvent = 1:7
                        x = allTimes';
                        y = squeeze(squeeze(Wz(iEvent,iTime,:,iFreq)));
                        [rho,pval] = corr(x,y);
                        timeCorrs_power_rho(iEvent,iTime,iFreq) = rho;
                        timeCorrs_power_pval(iEvent,iTime,iFreq) = pval;

                        y = squeeze(squeeze(Wz_angle(iEvent,iTime,:,iFreq)));
                        [rho,pval] = circ_corrcl(y,x); % (alpha,x)
                        timeCorrs_phase_rho(iEvent,iTime,iFreq) = rho;
                        timeCorrs_phase_pval(iEvent,iTime,iFreq) = pval;
                    end
                end
            end
            
            % save
% %             save('RTMTpowerCorr_20181108','all_timeCorrs_power_rho','all_timeCorrs_power_pval',...
% %                 'all_timeCorrs_phase_rho','all_timeCorrs_phase_pval','freqList','Wlength');
            all_timeCorrs_power_rho(iSession,iTiming,:,:,:) = timeCorrs_power_rho;
            all_timeCorrs_power_pval(iSession,iTiming,:,:,:) = timeCorrs_power_pval;
            all_timeCorrs_phase_rho(iSession,iTiming,:,:,:) = timeCorrs_phase_rho;
            all_timeCorrs_phase_pval(iSession,iTiming,:,:,:) = timeCorrs_phase_pval;
            
            if doPlot
                for iEvent = 1:7
                    subplot(rows,cols,prc(cols,[1,iEvent]));
                    imagesc(linspace(-tWindow,tWindow,size(Wz,2)),1:numel(freqList),squeeze(timeCorrs_power_rho(iEvent,:,:))');
                    colormap(gca,cmap);
                    hold on;
                    plot([-1 1],repmat(closest(freqList,13),[1 2]),'w-');
                    plot([-1 1],repmat(closest(freqList,30),[1 2]),'w-');
                    text(-.9,closest(freqList,mean([13 30])),'\beta','color','w');
                    set(gca,'ydir','normal');
                    caxis(climVals_rho);
                    xlim([-tWindow tWindow]);
                    xticks(sort([xlim 0]));
                    xlabel('time (s)');
                    yticks(1:numel(freqList));
                    yticklabels(num2str(freqList(:),'%2.1f'));
                    title({name(1:14),eventFieldnames{iEvent},[timingFields{iTiming},' Power']},'interpreter','none');
                    set(gca,'fontSize',8);
                    if iEvent == 7
                        cbAside(gca,'rho','k');
                    end

                    subplot(rows,cols,prc(cols,[2,iEvent]));
                    imagesc(linspace(-tWindow,tWindow,size(Wz,2)),1:numel(freqList),squeeze(timeCorrs_power_pval(iEvent,:,:))');
                    colormap(gca,hot);
                    hold on;
                    plot([-1 1],repmat(closest(freqList,13),[1 2]),'k-');
                    plot([-1 1],repmat(closest(freqList,30),[1 2]),'k-');
                    text(-.9,closest(freqList,mean([13 30])),'\beta','color','k');
                    set(gca,'ydir','normal');
                    caxis(climVals_pval);
                    xlim([-tWindow tWindow]);
                    xticks(sort([xlim 0]));
                    xlabel('time (s)');
                    yticks(1:numel(freqList));
                    yticklabels(num2str(freqList(:),'%2.1f'));
                    title([timingFields{iTiming},' Power']);
                    set(gca,'fontSize',8);
                    if iEvent == 7
                        cbAside(gca,'pval','k');
                    end
                    subplot(rows,cols,prc(cols,[3,iEvent]));
                    imagesc(linspace(-tWindow,tWindow,size(Wz,2)),1:numel(freqList),squeeze(timeCorrs_phase_rho(iEvent,:,:))');
                    colormap(gca,cmap);
                    hold on;
                    plot([-1 1],repmat(closest(freqList,13),[1 2]),'w-');
                    plot([-1 1],repmat(closest(freqList,30),[1 2]),'w-');
                    text(-.9,closest(freqList,mean([13 30])),'\beta','color','w');
                    set(gca,'ydir','normal');
                    caxis(climVals_rho);
                    xlim([-tWindow tWindow]);
                    xticks(sort([xlim 0]));
                    xlabel('time (s)');
                    yticks(1:numel(freqList));
                    yticklabels(num2str(freqList(:),'%2.1f'));
                    title([timingFields{iTiming},' Phase']);
                    set(gca,'fontSize',8);
                    if iEvent == 7
                        cbAside(gca,'rho','k');
                    end

                    subplot(rows,cols,prc(cols,[4,iEvent]));
                    imagesc(linspace(-tWindow,tWindow,size(Wz,2)),1:numel(freqList),squeeze(timeCorrs_phase_pval(iEvent,:,:))');
                    colormap(gca,hot);
                    hold on;
                    plot([-1 1],repmat(closest(freqList,13),[1 2]),'k-');
                    plot([-1 1],repmat(closest(freqList,30),[1 2]),'k-');
                    text(-.9,closest(freqList,mean([13 30])),'\beta','color','k');
                    set(gca,'ydir','normal');
                    caxis(climVals_pval);
                    xlim([-tWindow tWindow]);
                    xticks(sort([xlim 0]));
                    xlabel('time (s)');
                    yticks(1:numel(freqList));
                    yticklabels(num2str(freqList(:),'%2.1f'));
                    title([timingFields{iTiming},' Phase']);
                    set(gca,'fontSize',8);
                    if iEvent == 7
                        cbAside(gca,'pval','k');
                    end
                end
                set(gcf,'color','w');
                if doSave
                    saveas(h,fullfile(savePath,[name(1:14),'_',num2str(iNeuron,'%03d'),'_crossFreq',timingFields{iTiming},'.png']));
                    close(h);
                end
            end
        end
    end
end

climVals_rho = [-0.5 0.5];
climVals_pval = [0 0.5];
for iTiming = 1:2
    h = figuree(1400,800);
    timeCorrs_power_rho = squeeze(mean(all_timeCorrs_power_rho(:,iTiming,:,:,:)));
    timeCorrs_power_pval = squeeze(mean(all_timeCorrs_power_pval(:,iTiming,:,:,:)));
    timeCorrs_phase_rho = squeeze(mean(all_timeCorrs_phase_rho(:,iTiming,:,:,:)));
    timeCorrs_phase_pval = squeeze(mean(all_timeCorrs_phase_pval(:,iTiming,:,:,:)));
    for iEvent = 1:7
        subplot(rows,cols,prc(cols,[1,iEvent]));
        imagesc(linspace(-tWindow,tWindow,size(Wz,2)),1:numel(freqList),squeeze(timeCorrs_power_rho(iEvent,:,:))');
        colormap(gca,cmap);
        hold on;
        plot([-1 1],repmat(closest(freqList,13),[1 2]),'w-');
        plot([-1 1],repmat(closest(freqList,30),[1 2]),'w-');
        text(-.9,closest(freqList,mean([13 30])),'\beta','color','w');
        set(gca,'ydir','normal');
        caxis(climVals_rho);
        xlim([-tWindow tWindow]);
        xticks(sort([xlim 0]));
        xlabel('time (s)');
        yticks(1:numel(freqList));
        yticklabels(num2str(freqList(:),'%2.1f'));
        title({'All Sessions',eventFieldnames{iEvent},[timingFields{iTiming},' Power']},'interpreter','none');
        set(gca,'fontSize',8);
        if iEvent == 7
            cbAside(gca,'rho','k');
        end

        subplot(rows,cols,prc(cols,[2,iEvent]));
        imagesc(linspace(-tWindow,tWindow,size(Wz,2)),1:numel(freqList),squeeze(timeCorrs_power_pval(iEvent,:,:))');
        colormap(gca,hot);
        hold on;
        plot([-1 1],repmat(closest(freqList,13),[1 2]),'k-');
        plot([-1 1],repmat(closest(freqList,30),[1 2]),'k-');
        text(-.9,closest(freqList,mean([13 30])),'\beta','color','k');
        set(gca,'ydir','normal');
        caxis(climVals_pval);
        xlim([-tWindow tWindow]);
        xticks(sort([xlim 0]));
        xlabel('time (s)');
        yticks(1:numel(freqList));
        yticklabels(num2str(freqList(:),'%2.1f'));
        title([timingFields{iTiming},' Power']);
        set(gca,'fontSize',8);
        if iEvent == 7
            cbAside(gca,'pval','k');
        end
        subplot(rows,cols,prc(cols,[3,iEvent]));
        imagesc(linspace(-tWindow,tWindow,size(Wz,2)),1:numel(freqList),squeeze(timeCorrs_phase_rho(iEvent,:,:))');
        colormap(gca,cmap);
        hold on;
        plot([-1 1],repmat(closest(freqList,13),[1 2]),'w-');
        plot([-1 1],repmat(closest(freqList,30),[1 2]),'w-');
        text(-.9,closest(freqList,mean([13 30])),'\beta','color','w');
        set(gca,'ydir','normal');
        caxis(climVals_rho);
        xlim([-tWindow tWindow]);
        xticks(sort([xlim 0]));
        xlabel('time (s)');
        yticks(1:numel(freqList));
        yticklabels(num2str(freqList(:),'%2.1f'));
        title([timingFields{iTiming},' Phase']);
        set(gca,'fontSize',8);
        if iEvent == 7
            cbAside(gca,'rho','k');
        end

        subplot(rows,cols,prc(cols,[4,iEvent]));
        imagesc(linspace(-tWindow,tWindow,size(Wz,2)),1:numel(freqList),squeeze(timeCorrs_phase_pval(iEvent,:,:))');
        colormap(gca,hot);
        hold on;
        plot([-1 1],repmat(closest(freqList,13),[1 2]),'k-');
        plot([-1 1],repmat(closest(freqList,30),[1 2]),'k-');
        text(-.9,closest(freqList,mean([13 30])),'\beta','color','k');
        set(gca,'ydir','normal');
        caxis(climVals_pval);
        xlim([-tWindow tWindow]);
        xticks(sort([xlim 0]));
        xlabel('time (s)');
        yticks(1:numel(freqList));
        yticklabels(num2str(freqList(:),'%2.1f'));
        title([timingFields{iTiming},' Phase']);
        set(gca,'fontSize',8);
        if iEvent == 7
            cbAside(gca,'pval','k');
        end
    end
    set(gcf,'color','w');
    if doSave
        saveas(h,fullfile(savePath,['All Sessions_crossFreq',timingFields{iTiming},'.png']));
        close(h);
    end
end