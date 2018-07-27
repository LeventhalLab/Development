doSetup = true;
doDebug = true;
nSurr = 10;
zThresh = 2;
freqList = logFreqList([1 200],30);
ytickIds = [1 closest(freqList,20) closest(freqList,55) numel(freqList)]; % selected from freqList
ytickLabelText = freqList(ytickIds);
ytickLabelText = num2str(ytickLabelText(:),'%3.0f');
[sessionNames,~,ia] = unique(analysisConf.sessionNames);
cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/colormap_pval.jpg';
cmap = mycmap(cmapPath);
Wlength = 200;
tWindow = 1;
t = linspace(-tWindow,tWindow,Wlength);

for iSession = 15%:numel(sessionNames)
    if doSetup
        sessionTs = [];
        for iNeuron = find(ia == iSession)'
            sessionTs = [sessionTs;all_ts{iNeuron}];
        end
        sessionTs = sort(sessionTs);
        
%         sevFile = LFPfiles_local{selectedLFPFiles(iSession)};
%         curTrials = all_trials{iNeuron};
%         [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
%         [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
%         W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
%         [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
%         [Wz_power,keepTrials] = removeWzTrials(Wz_power,zThresh);
%         
%         tsPeths = eventsPeth(curTrials(trialIds(keepTrials)),sessionTs,2,eventFieldnames); % tWindow=2
        
        all_SDEz = [];
        xcorrBands_events = [];
        for iEvent = 1:size(tsPeths,2)
            for iTrial = 1:size(tsPeths,1)
                thisSDE = get_SDE(tsPeths{iTrial,iEvent},tWindow,Wlength);
                if iEvent == 1
                    refMean = mean(thisSDE);
                    refStd = std(thisSDE);
                end
                thisSDEz = (thisSDE - refMean) ./ refStd;
                all_SDEz(iEvent,iTrial,:) = thisSDEz;
                xcorrBands = [];
                for iBand = 1:numel(freqList)
                    x = squeeze(Wz_power(iEvent,:,iTrial,iBand))';
                    y = thisSDEz;
                    [r,lags] = xcorr(x,y);
                    xcorrBands(:,iBand) = r;
                end
                xcorrBands_trial(iTrial,:,:) = xcorrBands;
                if iEvent == 4 && iTrial == 1
                    figure;
                    imagesc(xcorrBands');
                    colormap(jet);
                    set(gca,'ydir','normal');
                    xlim([100 300])
                    grid on;
                end
            end
            xcorrBands_events(iEvent,:,:) = squeeze(mean(xcorrBands_trial));
        end

        xcorrBands_events_perm = [];
        for iSurr = 1:nSurr
            iTrial_perm = randperm(size(tsPeths,1));
            for iEvent = 1:size(tsPeths,2)
                for iTrial = 1:size(tsPeths,1)
                    thisSDE = get_SDE(tsPeths{iTrial_perm(iTrial),iEvent},tWindow,Wlength);
                    if iEvent == 1
                        refMean = mean(thisSDE);
                        refStd = std(thisSDE);
                    end
                    thisSDEz = (thisSDE - refMean) ./ refStd;
                    xcorrBands = [];
                    for iBand = 1:numel(freqList)
                        x = squeeze(Wz_power(iEvent,:,iTrial,iBand))';
                        y = thisSDEz;
                        [r,lags] = xcorr(x,y);
                        xcorrBands(:,iBand) = r;
                    end
                    xcorrBands_trial(iTrial,:,:) = xcorrBands;
                end
                xcorrBands_events_perm(iSurr,iEvent,:,:) = squeeze(mean(xcorrBands_trial));
            end
        end

        surr_result = [];
        for iEvent = 1:7
            xcorrArr = squeeze(xcorrBands_events(iEvent,:,:));
            for iSurr = 1:nSurr
                surrArr = squeeze(xcorrBands_events_perm(iSurr,iEvent,:,:));
                surr_result(iEvent,iSurr,:,:) = sign(xcorrArr - surrArr);
            end
        end
    end
    
    % -- DEBUG
    if doDebug
        savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/xcorrBySession';
        rows = 3;
        cols = 7;
        for iTrial = 1:size(tsPeths,1)
            h = figuree(1300,500);
            for iEvent = 1:size(tsPeths,2)
                thisSDE = get_SDE(tsPeths{iTrial,iEvent},tWindow,Wlength);
                if iEvent == 1
                    refMean = mean(thisSDE);
                    refStd = std(thisSDE);
                end
                thisSDEz = (thisSDE - refMean) ./ refStd;
                all_SDEz(iEvent,iTrial,:) = thisSDEz;
                xcorrBands = [];
                for iBand = 1:numel(freqList)
                    x = squeeze(Wz_power(iEvent,:,iTrial,iBand))';
                    y = thisSDEz;
                    [r,lags] = xcorr(x,y);
                    xcorrBands(:,iBand) = r;
                end
                
                if iEvent == 4 && iTrial == 1
                    figure;
                    imagesc(xcorrBands');
                    colormap(jet);
                    set(gca,'ydir','normal');
                    xlim([100 300])
                    grid on;
                end

                subplot(rows,cols,prc(cols,[1,iEvent]));
                imagesc(t,1:numel(freqList),squeeze(Wz_power(iEvent,:,iTrial,:))');
                colormap(gca,jet);
                set(gca,'YDir','normal');
                xlim([-1 1]);
                xticks(sort([xlim 0]));
                yticks(ytickIds);
                yticklabels(ytickLabelText);
                caxis([-5 5]);
                if iEvent == 7
                    cb = cbAside(gca,'trial power','k');
                    cb.Ticks = caxis;
                end
                primCount = sum(primSec(find(ia == iSession),1) == iEvent);
                secCount = sum(primSec(find(ia == iSession),2) == iEvent);
                if iEvent == 1
                    title({['t',num2str(iTrial),', u',num2str(find(ia == iSession,1)),'-',num2str(find(ia == iSession,1,'last'))],...
                        [eventFieldnames{iEvent}]});
                    ylabel('freq (Hz)');
                else
                    title({'',[eventFieldnames{iEvent}]});
                end
                grid on;

                subplot(rows,cols,prc(cols,[2,iEvent]));
                plot(t,thisSDEz,'k-','lineWidth',1);
                xlim([-1 1]);
                xticks(sort([xlim 0]));
                ylim([-5 5]);
                yticks(sort([ylim 0]));
                if iEvent == 1
                    ylabel('trial SDE Z');
                end
                grid on;

                subplot(rows,cols,prc(cols,[3,iEvent]));
                imagesc(t_xcorr,1:numel(freqList),xcorrBands');
                colormap(gca,jet);
                set(gca,'YDir','normal');
                xlim([-1 1]);
                xticks(sort([xlim 0]));
                yticks(ytickIds);
                yticklabels(ytickLabelText);
                if iEvent == 1
                    ylabel('freq (Hz)');
                end
                caxis(round(minmaxRed(xcorrBands_events))*5);
                if iEvent == 7
                    cb = cbAside(gca,'trial xcorr','k');
                    cb.Ticks = caxis;
                end
                grid on;
            end
            set(gcf,'color','w');
            saveFile = ['debug_t',num2str(iTrial),'_u',num2str(find(ia == iSession,1)),'-',num2str(find(ia == iSession,1,'last'))];
            saveas(h,fullfile(savePath,[saveFile,'.png']));
            close(h);
        end
    end
    % -- DEBUG

    figuree(1300,900);
    rows = 4;
    cols = 7;
    t_xcorr = linspace(-tWindow*2,tWindow*2,size(xcorrBands,1));
    for iEvent = 1:7
        subplot(rows,cols,prc(cols,[1,iEvent]));
        imagesc(t,1:numel(freqList),squeeze(mean(squeeze(Wz_power(iEvent,:,:,:)),2))');
        colormap(gca,jet);
        set(gca,'YDir','normal');
        xlim([-1 1]);
        xticks(sort([xlim 0]));
        yticks(ytickIds);
        yticklabels(ytickLabelText);
        caxis([-3 3]);
        if iEvent == 7
            cb = cbAside(gca,'mean power','k');
            cb.Ticks = caxis;
        end
        primCount = sum(primSec(find(ia == iSession),1) == iEvent);
        secCount = sum(primSec(find(ia == iSession),2) == iEvent);
        if iEvent == 1
            title({['s',num2str(iSession),', u',num2str(find(ia == iSession,1)),'-',num2str(find(ia == iSession,1,'last'))],...
                [eventFieldnames{iEvent}],[num2str(primCount),'^{primary}, ',num2str(secCount),'^{secondary}']});
            ylabel('freq (Hz)');
        else
            title({'',[eventFieldnames{iEvent}],...
                [num2str(primCount),'^{primary}, ',num2str(secCount),'^{secondary}']});
        end
        grid on;
        
        subplot(rows,cols,prc(cols,[2,iEvent]));
        plot(t,mean(squeeze(all_SDEz(iEvent,:,:))),'k-','lineWidth',1);
        xlim([-1 1]);
        xticks(sort([xlim 0]));
        ylim([-3 3]);
        yticks(sort([ylim 0]));
        if iEvent == 1
            ylabel('mean SDE Z');
        end
        grid on;
        
        subplot(rows,cols,prc(cols,[3,iEvent]));
        imagesc(t_xcorr,1:numel(freqList),squeeze(xcorrBands_events(iEvent,:,:))');
        colormap(gca,jet);
        set(gca,'YDir','normal');
        xlim([-1 1]);
        xticks(sort([xlim 0]));
        yticks(ytickIds);
        yticklabels(ytickLabelText);
        if iEvent == 1
            ylabel('freq (Hz)');
        end
        caxis(round(minmaxRed(xcorrBands_events)));
        if iEvent == 7
            cb = cbAside(gca,'mean xcorr','k');
            cb.Ticks = caxis;
        end
        grid on;
        
        subplot(rows,cols,prc(cols,[4,iEvent]));
        theseSurr = squeeze(surr_result(iEvent,:,:,:));
        fracSurr = squeeze(sum(theseSurr)) ./ nSurr;
        imagesc(t_xcorr,1:numel(freqList),fracSurr');
        colormap(gca,cmap);
        set(gca,'YDir','normal');
        xlim([-1 1]);
        xticks(sort([xlim 0]));
        xlabel('time (s)');
        yticks(ytickIds);
        yticklabels(ytickLabelText);
        if iEvent == 1
            ylabel('freq (Hz)');
        end
        if iEvent == 7
            cb = cbAside(gca,'shuffle sign.','k');
            cb.Ticks = caxis;
        end
        caxis([-1 1]);
        grid on;
    end
    set(gcf,'color','w');
end


% attempting to keep settings self-contained
function s = get_SDE(ts,tWindow,nBins)
sigma = .020; % kernel std
sigmaMult = 3;
% binWidth = .001; % 1ms
% binEdges = -tWindow:binWidth:tWindow;
binEdges = linspace(-tWindow-sigmaMult*sigma,tWindow+sigmaMult*sigma,nBins+1+(2*sigmaMult));
binWidth = mean(diff(binEdges));
counts = histcounts(ts,binEdges); % bin data
edges = -sigmaMult*sigma:binWidth:sigmaMult*sigma; % time ranges
kernel = normpdf(edges,0,sigma); % eval guassian kernel
kernel = kernel*binWidth; % multiply by bin width
sConv = conv(counts,kernel); % convolve

halfKernel = ceil(numel(edges)/2); % index of kernel center
s = sConv(halfKernel:halfKernel + numel(counts) - 1); % remove kernel smoothing from edges
s = s(sigmaMult+1:end-sigmaMult);
end