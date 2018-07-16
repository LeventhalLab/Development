savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/crossFrequencyRTMTPowerCorr';
doSave = true;

timingFields = {'RT','MT'};
tWindow = 1;
freqList = logFreqList([1 200],30);
Wlength = 200;
decimateFactor = 20;

rows = 4;
cols = 7;
climVals = [-1 1];
cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
cmap = mycmap(cmapPath);

if false
    timeCorrs_power = [];
    timeCorrs_angle = [];
    sevFile = '';
    iSession = 0;
    all_timeCorrs_power = {};
    all_timeCorrs_phase = {};
    for iNeuron = selectedLFPFiles'%1:numel(LFPfiles_local) %
    %     if strcmp(sevFile,LFPfiles_local{iNeuron})
    %         continue;
    %     end
        iSession = iSession + 1;
        disp(num2str(iNeuron));
        sevFile = LFPfiles_local{iNeuron};
        [~,name,~] = fileparts(sevFile);

        [sev,header] = read_tdt_sev(sevFile);
        sevFilt = decimate(double(sev),decimateFactor);
        Fs = header.Fs / decimateFactor;
        clear sev;

        curTrials = all_trials{iNeuron};

        h = figuree(1400,800);
        for iTiming = 1:2
            [trialIds,allTimes] = sortTrialsBy(curTrials,timingFields{iTiming});
            W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
            [Wz,Wz_angle] = zScoreW(W,Wlength); % power Z-score
            for iFreq = 1:numel(freqList)
                for iTime = 1:size(Wz,2)
                    for iEvent = 1:7
                        x = allTimes';
                        y = squeeze(squeeze(Wz(iEvent,iTime,:,iFreq)));
                        [RHO,PVAL] = corr(x,y);
                        timeCorrs_power(iEvent,iTime,iFreq) = RHO;

                        y = squeeze(squeeze(Wz_angle(iEvent,iTime,:,iFreq)));
                        [RHO,PVAL] = circ_corrcl(y,x); % (alpha,x)
                        timeCorrs_phase(iEvent,iTime,iFreq) = RHO;
                    end
                end
            end
            % save
            all_timeCorrs_power{iSession,iTiming} = timeCorrs_power;
            all_timeCorrs_phase{iSession,iTiming} = timeCorrs_phase;
            for iEvent = 1:7
                subplot(rows,cols,prc(cols,[iTiming,iEvent]));
                imagesc(linspace(-tWindow,tWindow,size(Wz,2)),1:numel(freqList),squeeze(timeCorrs_power(iEvent,:,:))');
                colormap(gca,cmap);
                hold on;
                plot([-1 1],repmat(closest(freqList,13),[1 2]),'w-');
                plot([-1 1],repmat(closest(freqList,30),[1 2]),'w-');
                text(-.9,closest(freqList,mean([13 30])),'\beta','color','w');
                set(gca,'ydir','normal');
                caxis(climVals);
                xlim([-tWindow tWindow]);
                xticks(sort([xlim 0]));
                xlabel('time (s)');
                yticks(1:numel(freqList));
                yticklabels(num2str(freqList(:),'%2.1f'));
                if iTiming == 1
                    title({name(1:14),eventFieldnames{iEvent},[timingFields{iTiming},' Power']},'interpreter','none');
                else
                    title([timingFields{iTiming},' Power']);
                end
                set(gca,'fontSize',8);
                grid on;
                if iEvent == 7
                    cb = colorbar('Location','east');
                    cb.Ticks = climVals;
                    % cb.Label.String = 'corr';
                    cb.Color = 'w';
                end

                subplot(rows,cols,prc(cols,[iTiming+2,iEvent]));
                imagesc(linspace(-tWindow,tWindow,size(Wz,2)),1:numel(freqList),squeeze(timeCorrs_phase(iEvent,:,:))');
                hold on;
                plot([-1 1],repmat(closest(freqList,13),[1 2]),'w-');
                plot([-1 1],repmat(closest(freqList,30),[1 2]),'w-');
                text(-.9,closest(freqList,mean([13 30])),'\beta','color','w');
                colormap(gca,cmap);
                set(gca,'ydir','normal');
                caxis(climVals);
                xlim([-tWindow tWindow]);
                xticks(sort([xlim 0]));
                xlabel('time (s)');
                yticks(1:numel(freqList));
                yticklabels(num2str(freqList(:),'%2.1f'));
                title([timingFields{iTiming},' Phase']);
                set(gca,'fontSize',8);
                grid on;
                if iEvent == 7
                    cb = colorbar('Location','east');
                    cb.Ticks = climVals;
                    % cb.Label.String = 'corr';
                    cb.Color = 'w';
                end
            end
        end
        set(gcf,'color','w');
        if doSave
            saveas(h,fullfile(savePath,[name(1:14),'_',num2str(iNeuron,'%03d'),'_crossFreqRTMT.png']));
            close(h);
        end
    end
end

climVals_power = [-.25 .25];
climVals_phase = [-0.5 .5];
h = figuree(1400,800);
for iEvent = 1:7
    for iTiming = 1:2
        subplot(rows,cols,prc(cols,[iTiming iEvent]));
        timeCorrs_power = [];
        for iSession = 1:size(all_timeCorrs_power,1)
            timeCorrs_power(iSession,:,:) = squeeze(all_timeCorrs_power{iSession,iTiming}(iEvent,:,:));
        end
        imagesc(linspace(-tWindow,tWindow,size(Wz,2)),1:numel(freqList),squeeze(mean(timeCorrs_power))');
        colormap(gca,cmap);
        hold on;
        plot([-1 1],repmat(closest(freqList,13),[1 2]),'w-');
        plot([-1 1],repmat(closest(freqList,30),[1 2]),'w-');
        text(-.9,closest(freqList,mean([13 30])),'\beta','color','w');
        set(gca,'ydir','normal');
        caxis(climVals_power);
        xlim([-tWindow tWindow]);
        xticks(sort([xlim 0]));
        xlabel('time (s)');
        yticks(1:numel(freqList));
        yticklabels(num2str(freqList(:),'%2.1f'));
        set(gca,'fontSize',8);
        grid on;
        if iTiming == 1
            title({name(1:14),eventFieldnames{iEvent},[timingFields{iTiming},' Power']},'interpreter','none');
        else
            title([timingFields{iTiming},' Power']);
        end
        if iEvent == 7
            cb = colorbar('Location','east');
            cb.Ticks = climVals_power;
            % cb.Label.String = 'corr';
            cb.Color = 'w';
        end
        
        subplot(rows,cols,prc(cols,[iTiming+2 iEvent]));
        timeCorrs_phase = [];
        for iSession = 1:size(all_timeCorrs_phase,1)
            timeCorrs_phase(iSession,:,:) = squeeze(all_timeCorrs_phase{iSession,iTiming}(iEvent,:,:));
        end
        imagesc(linspace(-tWindow,tWindow,size(Wz,2)),1:numel(freqList),squeeze(mean(timeCorrs_phase))');
        colormap(gca,cmap);
        hold on;
        plot([-1 1],repmat(closest(freqList,13),[1 2]),'w-');
        plot([-1 1],repmat(closest(freqList,30),[1 2]),'w-');
        text(-.9,closest(freqList,mean([13 30])),'\beta','color','w');
        set(gca,'ydir','normal');
        caxis(climVals_phase);
        xlim([-tWindow tWindow]);
        xticks(sort([xlim 0]));
        xlabel('time (s)');
        yticks(1:numel(freqList));
        yticklabels(num2str(freqList(:),'%2.1f'));
        set(gca,'fontSize',8);
        grid on;
        if iTiming == 1
            title({name(1:14),eventFieldnames{iEvent},[timingFields{iTiming},' Phase']},'interpreter','none');
        else
            title([timingFields{iTiming},' Phase']);
        end
        if iEvent == 7
            cb = colorbar('Location','east');
            cb.Ticks = climVals_phase;
            % cb.Label.String = 'corr';
            cb.Color = 'w';
        end
    end
end
set(gcf,'color','w');
if doSave
    saveas(h,fullfile(savePath,['allSessions_crossFreqRTMT.png']));
    close(h);
end
