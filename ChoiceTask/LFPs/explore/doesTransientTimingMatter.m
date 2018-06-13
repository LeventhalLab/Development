% compiled_eventsArr(iNeuron).
% eventsArr
% eventsArr_meta
% eventRTcorr
% eventMTcorr

useEventArr = 'Tone';
condLabels = {'before','after','before+after'};

if strcmp(useEventArr,'Tone')
    compiled_eventsArr = compiled_eventsArr_Tone;
else
    compiled_eventsArr = compiled_eventsArr_NoseOut;
end

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/transientTiming/MT';
freqList = logFreqList([3.5 100],30);
h1 = figuree(1400,900);
h2 = figuree(1400,900);
lineLabels = {};
loopCount = 0;
for iTiming = 1:2
    if iTiming == 1
        timingField = 'RT';
    else
        timingField = 'MT';
    end
    for iCond = 1:3
        freqRs = {};
        freqPs = {};
        for iNeuron = 1:numel(compiled_eventsArr)
            if isempty(compiled_eventsArr(iNeuron).eventsArr)
                continue;
            end
            if iTiming == 1 && iCond == 1
                loopCount = loopCount + 1;
                [~,name,~] = fileparts(LFPfiles_local{iNeuron});
                lineLabels{loopCount} = name;
            end
            
            eventsArr = compiled_eventsArr(iNeuron).eventsArr;
            eventsArr_meta = compiled_eventsArr(iNeuron).eventsArr_meta;
            eventRTcorr = compiled_eventsArr(iNeuron).eventRTcorr;
            eventMTcorr = compiled_eventsArr(iNeuron).eventMTcorr;
            if strcmp(timingField,'RT')
                useEventCorr = eventRTcorr;
            else
                useEventCorr = eventMTcorr;
            end

            Rs = [];
            Ps = [];
            for iFreq = 1:size(eventsArr,1)
                RTs = [];
                timeToEvent = [];
                trialCount = 0;
                for iTrial = 1:numel(useEventCorr)
                    transientTiming = eventsArr_meta{iFreq,iTrial};
                    if isnan(useEventCorr(iTrial))
                        continue;
                    end
                    trialCount = trialCount + 1;
                    RTs(trialCount) = useEventCorr(iTrial);

%                     if isempty(transientTiming) || sum(transientTiming(1,:) <= 0) == 0
%                         timeToEvent(trialCount) = -1;
%                     else
%                         idx = transientTiming(1,:) <= 0;
%                         timeToEvent(trialCount) = -max(0 - transientTiming(1,idx));
%                     end
                    timeToEvent(trialCount) = eventsArr(iFreq,iTrial,iCond);
                end
                [R,P] = corr(RTs',timeToEvent');
                Rs(iFreq) = R;
                Ps(iFreq) = P;

                if numel(freqRs) < iFreq
                    freqRs{iFreq} = [];
                    freqPs{iFreq} = [];
                end
        %         if P < 0.05
                    freqRs{iFreq} = [freqRs{iFreq} R];
                    freqPs{iFreq} = [freqPs{iFreq} P];
        %         end
            end
        % %     h = figuree(1200,600);
        % %     subplot(211);
        % %     bar(Rs);
        % %     xlim([0 numel(freqList)+1]);
        % %     xticks(1:numel(freqList));
        % %     xticklabels({num2str(freqList(:),'%2.1f')});
        % %     xlabel('Freq (Hz)');
        % %     ylim([-.5 .5]);
        % %     yticks(sort([0,ylim]));
        % %     ylabel('R');
        % %     title('Timing Corr x MT');
        % %     grid on;
        % % 
        % %     subplot(212);
        % %     bar(Ps);
        % %     xlim([0 numel(freqList)+1]);
        % %     xticks(1:numel(freqList));
        % %     xticklabels({num2str(freqList(:),'%2.1f')});
        % %     xlabel('Freq (Hz)');
        % %     ylim([0 1]);
        % %     yticks(sort([0.05,ylim]));
        % %     ylabel('P');
        % %     grid on;
        % %     
        % %     set(h,'color','white');
        % %     saveas(h,fullfile(savePath,[num2str(iNeuron,'%03d'),'_doesTransientTimingMatter_MT.png']));
        % %     close(h);
        end
        
        figure(h1);
        subplot(3,2,prc(2,[iCond,iTiming]));
        colors = jet(101);
        for iFreq = 1:numel(freqRs)
            theseRs = freqRs{iFreq};
            thesePs = freqPs{iFreq};
            for iR = 1:numel(theseRs)
                if thesePs(iR) < 0.05
                    continue;
                else
                    pColor = repmat(0.8,[1,3]);
                end
                plot(iFreq,theseRs(iR),'x','MarkerSize',5,'Color',pColor);
                hold on;
            end
        end
        for iFreq = 1:numel(freqRs)
            theseRs = freqRs{iFreq};
            thesePs = freqPs{iFreq};
            for iR = 1:numel(theseRs)
                if thesePs(iR) < 0.05
                    pColor = colors(round(thesePs(iR)*2000)+1,:);
                else
                    continue;
                end
                plot(iFreq,theseRs(iR),'.','MarkerSize',20,'Color',pColor);
                hold on;
            end
        end

        Ravg = [];
        for iFreq = 1:numel(freqRs)
            theseRs = freqRs{iFreq};
            thesePs = freqPs{iFreq};
            Ravg(iFreq) = mean(theseRs(thesePs >= 0.05));
        end
        plot(Ravg,'color',repmat(0.8,[1,3]));

        Ravg = [];
        for iFreq = 1:numel(freqRs)
            theseRs = freqRs{iFreq};
            thesePs = freqPs{iFreq};
            Ravg(iFreq) = mean(theseRs(thesePs < 0.05 & thesePs >= 0.01));
        end
        plot(Ravg,'color','r');

        Ravg = [];
        for iFreq = 1:numel(freqRs)
            theseRs = freqRs{iFreq};
            thesePs = freqPs{iFreq};
            Ravg(iFreq) = mean(theseRs(thesePs < 0.01));
        end
        plot(Ravg,'color','b');

        xlim([0 numel(freqList)+1]);
        xticks(1:numel(freqList));
        xticklabels({num2str(freqList(:),'%2.1f')});
        xtickangle(90);
        xlabel('Freq (Hz)');
        ylim([-1 1]);
        yticks(sort([0,ylim]));
        ylabel('R');
        title(['Timing Corr x ',timingField,' ',condLabels{iCond},' ',useEventArr]);
        cb = colorbar;
        colormap(jet);
        caxis([0 0.05]);
        set(cb,'YTick',sort([0.01 caxis]));
        ylabel(cb,'p-value');
        grid on;
        set(gcf,'color','w');
        pSC = [];
        
        figure(h2);
        for iFreq = 1:numel(freqPs)
            pSC(iFreq,:) = freqPs{iFreq};
        end
        subplot(3,2,prc(2,[iCond,iTiming]));
        imagesc(pSC');
        colormap(hot);
        caxis([0 1]);
        cb = colorbar;
        caxis([0 1]);
        set(cb,'YTick',sort([0.05 caxis]));
        ylabel(cb,'p-value');
        xticks(1:size(pSC,1));
        xticklabels({num2str(freqList(:),'%2.1f')});
        xtickangle(90);
        xlabel('Freq (Hz)');
        yticks(1:size(pSC,2));
% %         yticklabels(lineLabels);
        yticklabels({});
        set(gca,'FontSize',10);
        yax = get(gca,'YAxis');
% %         set(yax,'FontSize',5);
    end
    drawnow;
end