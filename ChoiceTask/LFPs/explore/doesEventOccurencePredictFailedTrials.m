doSetup = true;
iCond = 3;
if doSetup
    successArr = {};
    failureArr = {};
    successArr_binary = {};
    failureArr_binary = {};
    loopCount = 0;
    for iNeuron = 1:numel(compiled_eventsArr)
        if isempty(compiled_eventsArr(iNeuron).eventsArr)
            continue;
        end
        loopCount = loopCount + 1;
        eventsArr = compiled_eventsArr(iNeuron).eventsArr;
        eventsArr_meta = compiled_eventsArr(iNeuron).eventsArr_meta;
        eventRTcorr = compiled_eventsArr(iNeuron).eventRTcorr;
        eventMTcorr = compiled_eventsArr(iNeuron).eventMTcorr;

        for iFreq = 1:size(eventsArr,1)
            if numel(successArr) < iFreq
                successArr{iFreq} = [];
                failureArr{iFreq} = [];
                successArr_binary{iFreq} = [];
                failureArr_binary{iFreq} = [];
            end
% %             theseRs = freqRs{iFreq};
% %             if theseRs(loopCount) < 0.1
% %                 continue;
% %             end
            
            for iTrial = 1:size(eventsArr,2)
                transientTiming = eventsArr_meta{iFreq,iTrial};
                if ~isempty(transientTiming(1,:))
                    if isnan(eventRTcorr(iTrial))
                        failureArr{iFreq} = [failureArr{iFreq} transientTiming(1,:)];
                    else
                        successArr{iFreq} = [successArr{iFreq} transientTiming(1,:)];
                    end
                end
%                 if ~isempty(transientTiming(1,:))
                    if isnan(eventRTcorr(iTrial))
                        failureArr_binary{iFreq} = [failureArr_binary{iFreq} eventsArr(iFreq,iTrial,iCond)];
                    else
                        successArr_binary{iFreq} = [successArr_binary{iFreq} eventsArr(iFreq,iTrial,iCond)];
                    end
%                 else
%                      if isnan(eventRTcorr(iTrial))
%                         failureArr_binary{iFreq} = [failureArr_binary{iFreq} 0];
%                     else
%                         successArr_binary{iFreq} = [successArr_binary{iFreq} 0];
%                     end
%                 end
            end
        end
    end
end
figuree(900,900);
for iFreq = 1:numel(freqList)
    subplot(6,5,iFreq);
    data = {failureArr_binary{iFreq};successArr_binary{iFreq}};
    y = [failureArr_binary{iFreq} successArr_binary{iFreq}];
    groups = ones(size(y));
    groups(1:numel(failureArr_binary{iFreq})) = zeros(1,numel(failureArr_binary{iFreq}));
    pvals(iCond,iFreq) = anova1(y,groups,'off');
    plotSpread(data,'showMM',1);
    xticks([1 2]);
    xticklabels({'failure','success'});
    ylimVals = ylim;
    ylim([0 ceil(ylimVals(2))]);
    yticks([0:ceil(ylimVals(2))]);
    title({[num2str(freqList(iFreq),'%2.1f'),' Hz'],['p = ',num2str(pvals(iCond,iFreq),'%0.3f')]});
end
figuree(800,300);
plot(pvals');
ylim([0 1]);
yticks(sort([0.05 ylim]));
ylabel('p-value');
xlim([0 numel(freqList)+1]);
xticks(1:numel(freqList));
xticklabels({num2str(freqList(:),'%2.1f')});
xtickangle(90);
xlabel('Freq (Hz)');
title('Do events predict failure or success?');
grid on;
legend({'before','after','total'});


figuree(900,900);
binEdges = -1:.05:1;
for iFreq = 1:numel(freqList)
    subplot(6,5,iFreq);
    counts = histcounts(successArr{iFreq},binEdges) ./ numel(successArr{iFreq});
    t = linspace(-1,1,numel(counts));
    plot(t,counts,'b-');
    hold on;

    counts = histcounts(failureArr{iFreq},binEdges) ./ numel(failureArr{iFreq});
    plot(t,counts,'r-');

    xlim([-1 1]);
    xticks(sort([xlim,0]));
    xlabel('time (s)');
%     ylim([0 0.1]);
    yticks(ylim);
    ylabel('probability');
    grid on;
    title([num2str(freqList(iFreq),'%2.1f'),' Hz']);
end