savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/crossFrequencyRTMTPowerCorr';
doSetup = false;
doSave = false;

timingFields = {'RT','MT'};
tWindow = 1;
freqList = logFreqList([1 200],30);
Wlength = 400;
zThresh = 5;

if doSetup
    iSession = 0;
    all_timeCorrs_power = [];
    all_timeCorrs_phase = [];
    all_timeCorrs_timing = [];
    trialCount = zeros(1,2);
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(num2str(iNeuron));
        sevFile = LFPfiles_local{iNeuron};
        [~,name,~] = fileparts(sevFile);

        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        sevFilt = artifactThresh(sevFilt,[1],2000);
        sevFilt = sevFilt - mean(sevFilt);
        curTrials = all_trials{iNeuron};

        for iTiming = 1:2
            [trialIds,allTimes] = sortTrialsBy(curTrials,timingFields{iTiming});
            [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
            
            keepTrials = threshTrialData(all_data,zThresh);
            W = W(:,:,keepTrials,:);
            allTimes = allTimes(keepTrials);
            [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
            
            % clear but inefficient
            for iTrial = 1:size(Wz_power,3)
                trialCount(iTiming) = trialCount(iTiming) + 1;
                for iEvent = 1:size(Wz_power,1)
                    for iTime = 1:size(Wz_power,2)
                        for iFreq = 1:size(Wz_power,4)
                            all_timeCorrs_power(trialCount(iTiming),iTiming,iEvent,iTime,iFreq) = Wz_power(iEvent,iTime,iTrial,iFreq);
                            all_timeCorrs_phase(trialCount(iTiming),iTiming,iEvent,iTime,iFreq) = Wz_phase(iEvent,iTime,iTrial,iFreq);
                            all_timeCorrs_timing(trialCount(iTiming),iTiming) = allTimes(iTrial);
                        end
                    end
                end
            end
        end
    end
    save('RMTMcorr_20181208','all_timeCorrs_power','all_timeCorrs_phase','all_timeCorrs_timing','freqList');
end

if true
    rMat_power = [];
    pMat_power = [];
    rMat_phase = [];
    pMat_phase = [];
    for iTiming = 1:2
        for iEvent = 1:size(all_timeCorrs_power,3)
            for iTime = 1:size(all_timeCorrs_power,4)
                for iFreq = 1:size(all_timeCorrs_power,5)
                    [rho,pval] = corr(squeeze(all_timeCorrs_power(:,iTiming,iEvent,iTime,iFreq)),all_timeCorrs_timing(:,iTiming));
                    rMat_power(iTiming,iEvent,iTime,iFreq) = rho;
                    pMat_power(iTiming,iEvent,iTime,iFreq) = pval;
                    [rho,pval] = circ_corrcl(squeeze(all_timeCorrs_phase(:,iTiming,iEvent,iTime,iFreq)),all_timeCorrs_timing(:,iTiming));
                    rMat_phase(iTiming,iEvent,iTime,iFreq) = rho;
                    pMat_phase(iTiming,iEvent,iTime,iFreq) = pval;
                end
            end
        end
    end
end    

rows = 4;
cols = 7;
cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
cmap = mycmap(cmapPath);
climVals_rho = [-0.5 0.5];
climVals_pval = [0 0.5];
t = linspace(-tWindow,tWindow,size(all_timeCorrs_timing,1));
for iTiming = 1:2
    h = figuree(1400,800);
    for iEvent = 1:7
        thisRho = squeeze(rMat_power(iTiming,iEvent,:,:));
        subplot(rows,cols,prc(cols,[1,iEvent]));
        imagesc(t,1:numel(freqList),thisRho');
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

        thisPval = squeeze(pMat_power(iTiming,iEvent,:,:));
        subplot(rows,cols,prc(cols,[2,iEvent]));
        imagesc(t,1:numel(freqList),thisPval');
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
        
        thisRho = squeeze(rMat_phase(iTiming,iEvent,:,:));
        subplot(rows,cols,prc(cols,[3,iEvent]));
        imagesc(t,1:numel(freqList),thisRho');
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

        thisPval = squeeze(pMat_phase(iTiming,iEvent,:,:));
        subplot(rows,cols,prc(cols,[4,iEvent]));
        imagesc(t,1:numel(freqList),thisPval');
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