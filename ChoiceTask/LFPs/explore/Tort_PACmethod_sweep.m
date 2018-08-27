doSetup = true;
doSave = true;
doPlot = true;

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/tortMethod';
zThresh = 2;
tWindow = 2;
tSweep = 1;
nSteps = 21;
freqList = logFreqList([1 200],10);

freqLabels = num2str(freqList(:),'%2.1f');
Wlength = 200;
nBins = 18;

iSession = 0;
all_MImatrix = [];
session_MIMatrix_byRT = {};
MImatrix_RT = {};
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;

    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    curTrials = all_trials{iNeuron};
    [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
    W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    secSamples = size(W,2) / (tWindow * 2);
    sweepSamples = round(secSamples * tSweep);
    sweepCenters = round(linspace((size(W,2)/2)-secSamples*tSweep,(size(W,2)/2)+secSamples*tSweep,nSteps));
    tSweeps = (sweepCenters - size(W,2)/2) / secSamples;

%     fakeTrials = generateFakeTrials(100,curTrials,eventFieldnames);
%     W = eventsLFPv2(fakeTrials,sevFilt,tWindow,Fs,freqList,eventFieldnames);
%         [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
%         [Wz_power,keepTrials] = removeWzTrials(Wz_power,zThresh);
%         Wz_phase = Wz_phase(:,:,keepTrials,:);

    MImatrix = NaN(size(W,1),size(W,3),nSteps,numel(freqList),numel(freqList));
    for iEvent = 1:size(W,1)
        for iTrial = 1:size(W,3)
            for iSweep = 1:nSteps
                disp(['e',num2str(iEvent),' t',num2str(iTrial),' s',num2str(iSweep)]);
                sweepRange = (sweepCenters(iSweep) - sweepSamples : sweepCenters(iSweep) + sweepSamples - 1) + 1;
                for ifp = 1:numel(freqList)
                    for ifA = ifp:numel(freqList)
                        cur_W = W(:,sweepRange,:,:);
                        cur_fp = angle(cur_W(iEvent,:,iTrial,ifp));
                        binEdges = linspace(-pi,pi,nBins+1);
                        [N,edges,bin] = histcounts(cur_fp,binEdges);

                        cur_fA = abs(cur_W(iEvent,:,iTrial,ifA).^2);
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
                        MImatrix(iEvent,iTrial,iSweep,ifp,ifA) = MI;
                    end
                end
            end
        end
    end
    session_MIMatrix_byRT{iSession} = MImatrix;
    MImatrix_RT{iSession} = allTimes;
    
    ifp_range = 1:2;
    ifA_range = 6:7;
    if doPlot
        h2 = figuree(400,800);
        for iEvent = 1:size(MImatrix,1)
%             h = figuree(600,600);
%             rowscols = ceil(sqrt(nSteps));
%             for iSweep = 1:nSteps
%                 subplot(rowscols,rowscols,iSweep);
%                 curMat = squeeze(nanmean(MImatrix(iEvent,:,iSweep,:,:),2));
%                 imagesc(curMat');
%                 colormap(jet);
%                 set(gca,'ydir','normal');
%                 caxis([0 0.25]);
%                 xticks(1:numel(freqList));
%                 xticklabels(freqLabels);
%                 xtickangle(90);
%                 xlabel('phase (Hz)');
%                 yticks(1:numel(freqList));
%                 yticklabels(freqLabels);
%                 ylabel('amp (Hz)');
%                 set(gca,'fontsize',8);
%                 title({['e',num2str(iEvent)],['+/- ',num2str(tSweep),'s @ ',num2str(tSweeps(iSweep),'%1.2f')]});
%             end
%             set(gcf,'color','w');
%             saveFile = ['s',num2str(iSession,'%02d'),'_e',num2str(iEvent),'_allTrialsByRT.png'];
%             saveas(h,fullfile(savePath,saveFile));
%             close(h);
            
            figure(h2);
            subplot(7,1,iEvent);
            sweepSeries = squeeze(mean(mean(squeeze(nanmean(squeeze(MImatrix(iEvent,:,:,ifp_range,ifA_range)))),2),3));
            plot(tSweeps,sweepSeries,'k-','linewidth',2);
            ylim([0.1 0.2]);
            ylabel('MI');
            yticks(ylim);
            title(eventFieldnames{iEvent});
            grid on;
        end
    end
end
