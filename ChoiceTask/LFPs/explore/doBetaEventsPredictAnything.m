freqList = logFreqList([3.5 100],30);
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/transientLFPevents/Tone';


sevFile = '';
iEvent = 4;
compiled_eventsArr = {};
for iNeuron = 1%:numel(LFPfiles_local)
    % only unique sev files
    if strcmp(sevFile,LFPfiles_local{iNeuron})
        continue;
    end
    eventArr = []; % trials x stats[cols = before,after,total]
    eventRTcorr = [];
    eventMTcorr = [];
    trialCount = 0;
    disp(num2str(iNeuron));
    sevFile = LFPfiles_local{iNeuron};
    [~,name,~] = fileparts(sevFile);
    curTrials = all_trials{iNeuron};
    [W,freqList,~] = getW(sevFile,curTrials,eventFieldnames,freqList,'');
    [RTtrialIds,RTs] = sortTrialsBy(curTrials,'RT');
    [MTtrialIds,MTs] = sortTrialsBy(curTrials,'MT');

    for iFreq = 1:numel(freqList)
        refW = squeeze(squeeze(W(1,1:round(size(W,2)/2),:,iFreq)));
        cutoffPower = nanmedian(abs(refW(:)).^2) * 6;
        for iTrial = 1:size(W,3)
            eventArrCount = trialCount + iTrial;
            curW = abs(squeeze(squeeze(W(iEvent,:,iTrial,iFreq)))).^2;
            [locs,pks] = peakseek(curW,round(size(curW,1)/2/freqList(iFreq)),cutoffPower);
            eventArr(iFreq,eventArrCount,:) = [sum(locs < numel(curW)/2) sum(locs >= numel(curW)/2) numel(locs)];
            eventArr_meta{iFreq,eventArrCount} = [(locs/numel(curW)*2) - 1;pks/cutoffPower];

            if ismember(iTrial,RTtrialIds)
                eventRTcorr(eventArrCount) = RTs(RTtrialIds == iTrial);
                eventMTcorr(eventArrCount) = MTs(MTtrialIds == iTrial);
            else
                eventRTcorr(eventArrCount) = NaN;
                eventMTcorr(eventArrCount) = NaN;
            end
        end
    end
    compiled_eventsArr(iNeuron).eventsArr = eventArr;
    compiled_eventsArr(iNeuron).eventsArr_meta = eventArr_meta;
    compiled_eventsArr(iNeuron).eventRTcorr = eventRTcorr;
    compiled_eventsArr(iNeuron).eventMTcorr = eventMTcorr;
% %     trialCount = trialCount + iTrial; % accumulate


    rows = 3;
    Rs = [];
    Ps = [];
    h = figuree(1200,900);
    for iPlot = 1:2
        subplot(rows,1,iPlot);
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
                    x = squeeze(eventArr(iFreq,~isnan(useCorr),ii))';
                    y = useCorr(~isnan(useCorr))';
                    [R,P] = corr(x,y);
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
        b1 = bar(Rs.*pValIdx,0.5,'FaceColor','r','EdgeColor','r');
        hold on;

        b2 = bar(Rs,1);
        xlim([0 numel(freqList)+1]);
        xticks(1:numel(freqList));
        xticklabels({num2str(freqList(:),'%2.1f')});
        xlabel('Freq (Hz)');
        ylim([-.5 .5]);
        yticks(sort([0,ylim]));
        ylabel('R');
        legend(b2,{'before','after','total'});
        title([corrType, ' (red bar p < 0.05)']);
        grid on;
    end

    failurePs = [];
    for iFreq = 1:numel(freqList)
        for iCond = 1:3
            [p,~,stats] = anova1(eventArr(iFreq,:,iCond),~isnan(eventRTcorr),'off');
            failurePs(iFreq,iCond) = p * sign(diff(stats.means));
        end
    end
    subplot(rows,1,3);
    b = bar(failurePs,1);
    xlim([0 numel(freqList)+1]);
    xticks(1:numel(freqList));
    xticklabels({num2str(freqList(:),'%2.1f')});
    xlabel('Freq (Hz)');
    ylim([-1 1]);
    yticks(sort([0.05,-0.05,ylim]));
    ylabel('p-value');
    legend(b,{'before','after','total'});
    title({'ANOVA Failure vs. Success','i.e., do LFP transients affect success?','+p means transient incidence is greater for success'});
    grid on;

    saveas(h,fullfile(savePath,[num2str(iNeuron,'%03d'),'_transientLFPevents_Tone.png']));
    close(h);
end