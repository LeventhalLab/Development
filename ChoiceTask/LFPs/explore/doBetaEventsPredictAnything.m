doSetup = false;
freqList = logFreqList([3.5 100],30);

if doSetup
    sevFile = '';
    eventArr = []; % trials x stats[cols = total,before,after]
    eventRTcorr = [];
    eventMTcorr = [];
    trialCount = 0;
    for iNeuron = 1%:numel(LFPfiles)
        % only unique sev files
        if strcmp(sevFile,LFPfiles_local{iNeuron})
            continue;
        end
    %     sevFile = LFPfiles_local{iNeuron};
    %     [~,name,~] = fileparts(sevFile);
        curTrials = all_trials{iNeuron};
    %     [W,freqList,~] = getW(sevFile,curTrials,eventFieldnames,freqList,'');
        [RTtrialIds,RTs] = sortTrialsBy(curTrials,'RT');
        [MTtrialIds,MTs] = sortTrialsBy(curTrials,'MT');

        for iFreq = 1:numel(freqList)
            refW = squeeze(squeeze(W(1,1:round(size(W,2)/2),:,iFreq)));
            cutoffPower = nanmedian(abs(refW(:)).^2) * 6;
            for iTrial = 1:size(W,3)
                eventArrCount = trialCount + iTrial;
                curW = abs(squeeze(squeeze(W(4,:,iTrial,iFreq)))).^2;
                [locs,pks] = peakseek(curW,round(size(curW,1)/2/freqList(iFreq)),cutoffPower);
                eventArr(iFreq,eventArrCount,:) = [numel(locs) sum(locs < numel(curW)/2) sum(locs >= numel(curW)/2)];
                
                if ismember(iTrial,RTtrialIds)
                    eventRTcorr(eventArrCount) = RTs(RTtrialIds == iTrial);
                    eventMTcorr(eventArrCount) = MTs(MTtrialIds == iTrial);
                else
                    eventRTcorr(eventArrCount) = NaN;
                    eventMTcorr(eventArrCount) = NaN;
                end
            end
        end
        trialCount = trialCount + iTrial; % accumulate
    end
end

Rs = [];
Ps = [];
figuree(1200,800);
for iPlot = 1:2
    subplot(2,1,iPlot);
    if iPlot == 1
        useCorr = eventRTcorr;
        corrType = 'RT';
    else
        useCorr = eventMTcorr;
        corrType = 'MT';
    end
    for iFreq = 1:numel(freqList)
        for ii = 1:3
            if sum(~isnan(useCorr)) > 5
                [R,P] = corr(squeeze(eventArr(iFreq,~isnan(useCorr),ii))',useCorr(~isnan(useCorr))');
                Rs(iFreq,ii) = R;
                Ps(iFreq,ii) = P;
            else
                Rs(iFreq,ii) = 0;
                Ps(iFreq,ii) = 1;
            end
        end
    end
    
    pValIdx = double(Ps<0.05) + .05;
    pValIdx(find(pValIdx == 0)) = NaN;
    bar(Rs.*pValIdx,0.5,'FaceColor','r','EdgeColor','r');
    hold on;
    
    b = bar(Rs,1);
    xlim([0 numel(freqList)+1]);
    xticks(1:numel(freqList));
    xticklabels({num2str(freqList(:),'%2.1f')});
    xlabel('Freq (Hz)');
    ylim([-.5 .5]);
    yticks(sort([0,ylim]));
    ylabel('R');
    legend(b,{'total','before','after'});
    title(corrType);
    grid on;
end

for iFreq = 1:numel(freqList)
    figuree(800,400);
    
end