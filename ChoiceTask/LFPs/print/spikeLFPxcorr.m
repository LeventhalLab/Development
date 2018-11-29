% function spikeLFPxcorr(LFPfiles,all_trials,all_SDEs_zscore,eventFieldnames)
% load('session_20180717_SDExcorr.mat', 'all_SDEs_zscore')
sevFile = '';
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/xcorrTrials';
tWindow = 1;
cols = 7;  
rows = 3;
freqList = logFreqList([1 200],10);
ytickIds = 1:numel(freqList);%[1 7 10 14 17 20 25 30]; % selected from freqList
Wlength = 200;
cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
cmap = mycmap(cmapPath);
zThresh = 2;

allNeuron_scaloData_xcorr = {};
for iNeuron = 1:numel(LFPfiles_local)
    saveFolder = fullfile(savePath,['u',num2str(iNeuron,'%03d')]);
    if ~exist(saveFolder)
        mkdir(saveFolder)
    end
    % only unique sev files
    if ~strcmp(sevFile,LFPfiles_local{iNeuron})
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        [Wz_power,Wz_phase] = zScoreW(W,numel(all_SDEs_zscore{1}{1,1})); % power Z-score
        [~,keepTrials] = removeWzTrials(Wz_power,zThresh);
    end
    curSDEs = all_SDEs_zscore{iNeuron};
    allTrial_scaloData_xcorr = [];
    allTrial_scaloData = [];
    allTrial_curSDE = [];
    trialCount = 1;
    for iTrial = keepTrials
        h = figuree(1300,900);
        trialCount = trialCount + 1;
        for iEvent = 1:cols
            % power
            subplot(rows,cols,prc(cols,[1 iEvent]));
            scaloData = squeeze(Wz_power(iEvent,:,iTrial,:));
            allTrial_scaloData(trialCount,:,:) = scaloData;
            t = linspace(-tWindow,tWindow,size(scaloData,1));
            imagesc(t,1:numel(freqList),scaloData');
            set(gca,'YDir','normal');
            colormap(gca,jet);
            xticks([-tWindow 0 tWindow]);
            xlim([-tWindow tWindow]);
            titleText = eventFieldnames{iEvent};
            ylabelText = {['#',num2str(iTrial)],['RT ',num2str(allTimes(iTrial),'%0.3f'), 's'],'Freq (Hz)'};
            if iEvent == 1
                ylabel(ylabelText);
                title({['unit ',num2str(iNeuron,'%03d')],eventFieldnames{iEvent}});
            else
                title({'',eventFieldnames{iEvent}});
            end
            yticks(ytickIds);
            ytickLabels = round(freqList(ytickIds));
            yticklabels(ytickLabels);
            caxis([-8 8]);
            if iEvent == 7
                cb = colorbar('location','east');
                cb.Ticks = caxis;
            end
            grid on;
            
            % SDE
            subplot(rows,cols,prc(cols,[2 iEvent]));
            curSDE = curSDEs{iTrial,iEvent};
            allTrial_curSDE(trialCount,:) = curSDE;
            plot(t,curSDE,'k','linewidth',2);
            if iEvent == 1
                ylabel('SDE (Z)');
            end
            ylim([-2 5]);
            yticks(sort([0 ylim]));
            grid on;
            
            % xcorr
            subplot(rows,cols,prc(cols,[3 iEvent]));
            scaloData_xcorr = [];
            for iBand = 1:size(scaloData,2)
                [r,lags] = xcorr(scaloData(:,iBand)',curSDE);
                scaloData_xcorr(:,iBand) = r;
            end
            allTrial_scaloData_xcorr(trialCount,:,:) = scaloData_xcorr;
            imagesc(linspace(-tWindow*2,tWindow*2,size(scaloData_xcorr,1)),1:numel(freqList),scaloData_xcorr');
            set(gca,'YDir','normal');
            xticks([-tWindow 0 tWindow]);
            xlim([-tWindow tWindow]);
            yticks(ytickIds);
            yticklabels(ytickLabels);
            if iEvent == 1
                ylabel('Freq (Hz)');
            end
            colormap(gca,cmap);
            title('xcorr');
            xlabel('time (s)');
            caxis([-4 4]*10e2);
            if iEvent == 7
                cb = colorbar('location','east');
                cb.Ticks = caxis;
                cb.Color = 'w';
            end
            grid on;
        end
        
        set(gcf,'color','w');
        saveFile = ['unit',num2str(iNeuron,'%03d'),'_trial',num2str(iTrial,'%03d'),'.png'];
        saveas(h,fullfile(saveFolder,saveFile));
        close(h);
    end
    % make average plot
    
    allNeuron_scaloData_xcorr{iNeuron} = allTrial_scaloData_xcorr;
end