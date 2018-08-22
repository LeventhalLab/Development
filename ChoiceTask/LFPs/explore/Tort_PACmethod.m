doSetup = true;
doSave = true;
doPlot = true;

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/tortMethod';
zThresh = 2;
tWindow = 1;
freqList = logFreqList([1 200],30);

freqIdx = floor(linspace(1,numel(freqList),5));
freqLabels = freqList(freqIdx);
freqLabels = num2str(freqLabels(:),'%2.1f');
Wlength = 200;
nBins = 18;

iSession = 0;
all_MImatrix = [];
session_MIMatrix_byRT = {};
MImatrix_RT = {};
for iNeuron = selectedLFPFiles(1)'
    iSession = iSession + 1;

    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    curTrials = all_trials{iNeuron};
    [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
    W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
%     fakeTrials = generateFakeTrials(100,curTrials,eventFieldnames);
%     W = eventsLFPv2(fakeTrials,sevFilt,tWindow,Fs,freqList,eventFieldnames);
    % use t >= tWindow
    W = W(:,round(size(W,2)/2):end,:,:);
%         [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
%         [Wz_power,keepTrials] = removeWzTrials(Wz_power,zThresh);
%         Wz_phase = Wz_phase(:,:,keepTrials,:);

    MImatrix = NaN(size(W,1),size(W,3),numel(freqList),numel(freqList));
    for iEvent = 1:size(W,1)
        for iTrial = 1:size(W,3)
            for ifp = 1:numel(freqList)
                for ifA = ifp:numel(freqList)
                    cur_fp = angle(W(iEvent,:,iTrial,ifp));
                    binEdges = linspace(-pi,pi,nBins+1);
                    [N,edges,bin] = histcounts(cur_fp,binEdges);

                    cur_fA = abs(W(iEvent,:,iTrial,ifA).^2);
                    mi_bins = zeros(1,nBins);
                    for iBin = 1:nBins
                        mi_bins(1,iBin) = sum(cur_fA(bin == iBin)) ./ sum(bin == iBin); % mean
                    end
                    % now get pj
                    pj = zeros(1,nBins);
                    for iBin = 1:nBins
                        pj(1,iBin) = mi_bins(1,iBin) / sum(mi_bins);
                    end
                    % now get H
                    H = 0;
                    for iBin = 1:nBins
                        H = H + (pj(1,iBin) * log(pj(1,iBin)));
                    end
                    H = -H;
                    Hmax = log(nBins);
                    MI = (Hmax - H) / Hmax;
                    MImatrix(iEvent,iTrial,ifp,ifA) = MI;
                end
            end
        end
    end
    session_MIMatrix_byRT{iSession} = MImatrix;
    MImatrix_RT{iSession} = allTimes;
    
    if doPlot
        for iEvent = 1:size(MImatrix,1)
            h = figuree(1200,800);
            rowscols = ceil(sqrt(size(MImatrix,2)));
            for iTrial = 1:size(MImatrix,2)
                subplot(rowscols,rowscols,iTrial);
                curMat = squeeze(MImatrix(iEvent,iTrial,:,:));
                imagesc(curMat');
                colormap(jet);
                set(gca,'ydir','normal');
                caxis([0 0.2]);
                xticks(freqIdx);
                xticklabels(freqLabels);
                xlabel('phase (Hz)');
                yticks(freqIdx);
                yticklabels(freqLabels);
                ylabel('amp (Hz)');
                set(gca,'fontsize',6);
                title(['e',num2str(iEvent),', t',num2str(iTrial)]);
            end
            set(gcf,'color','w');
            saveFile = ['s',num2str(iSession,'%02d'),'_e',num2str(iEvent),'_allTrialsByRT.png'];
            saveas(h,fullfile(savePath,saveFile));
            close(h);
        end

        h = figuree(1200,200);
        for iEvent = 1:7
            subplot(1,7,iEvent);
            curMat = squeeze(nanmean(MImatrix(iEvent,:,:,:)));
            all_MImatrix(iSession,iEvent,:,:) = curMat;
            imagesc(curMat');
            colormap(jet);
            set(gca,'ydir','normal');
            caxis([0 0.2]);
            xticks(freqIdx);
            xticklabels(freqLabels);
            xlabel('phase (Hz)');
            yticks(freqIdx);
            yticklabels(freqLabels);
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            if iEvent == 1
                title({[subjectName,' s',num2str(iSession,'%02d')],eventFieldnames{iEvent}});
            else
                title({'',eventFieldnames{iEvent}});
            end
        end
        set(gcf,'color','w');
        saveFile = ['s',num2str(iSession,'%02d'),'_allEvent.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end

if doPlot
    ifp = 3;
    ifA = 17;
    MI_bars = [];
    h = figuree(1400,500);
    rows = 2;
    cols = 7;
    freqLabels = num2str(freqList(:),'%2.1f');
    for iEvent = 1:size(all_MImatrix,2)
        subplot(rows,cols,prc(cols,[1 iEvent]));
        curMat = squeeze(nanmean(squeeze(all_MImatrix(:,iEvent,:,:)))) - squeeze(nanmean(squeeze(all_MImatrix_surr(:,iEvent,:,:))));
        MI_bars(iEvent) = curMat(ifp,ifA);
        imagesc(curMat');
        colormap(jet);
        set(gca,'ydir','normal');
        caxis([0 0.2]);
        xticks(1:numel(freqList));
        xticklabels(freqLabels);
        xtickangle(90);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList));
        yticklabels(freqLabels);
        ylabel('amp (Hz)');
        title({'',eventFieldnames{iEvent}});
        if iEvent == 7
            cb = cbAside(gca,'MI','k');
        end

        subplot(rows,cols,prc(cols,[2 iEvent]));
        for iSession = 1:size(all_MImatrix,1)
            plot(squeeze(all_MImatrix(iSession,iEvent,ifp,:)),'color',repmat(.8,[1,3]));
            hold on;
        end
        plot(curMat(ifp,:),'k');
        xticks(1:numel(freqList));
        xticklabels(freqLabels);
        xtickangle(90);
        ylim([0 0.2]);
        yticks(ylim);
        ylabel('MI');
        title(['phase: ',num2str(freqList(ifp))]);
    end

    figuree(400,400);
    bar(MI_bars,'k');
    xticks(1:7);
    xticklabels(eventFieldnames);
    xtickangle(90);
    ylim([0 0.2]);
    yticks(ylim);
    ylabel('MI');
    title(['phase: ',num2str(freqList(ifp)),', amp: ',num2str(freqList(ifA))]);
end