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
h3 = figuree(1400,900);
h4 = figuree(1400,900);
h5 = figuree(1400,900);
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

            for iFreq = 1:size(eventsArr,1)
                RTs = [];
                numberOfEvents = [];
                trialCount = 0;
                for iTrial = 1:numel(useEventCorr)
                    transientTiming = eventsArr_meta{iFreq,iTrial};
                    if isnan(useEventCorr(iTrial))
                        continue;
                    end
                    trialCount = trialCount + 1;
                    RTs(trialCount) = useEventCorr(iTrial);
                    numberOfEvents(trialCount) = eventsArr(iFreq,iTrial,iCond);
                end
                [R,P] = corr(RTs',numberOfEvents');

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
        
        if ~isempty(h1)
            figure(h1);
            subplot(3,2,prc(2,[iCond,iTiming]));
            colors = jet(101);
        end
        for iFreq = 1:numel(freqRs)
            theseRs = freqRs{iFreq};
            thesePs = freqPs{iFreq};
            for iR = 1:numel(theseRs)
                if thesePs(iR) < 0.05
                    continue;
                else
                    pColor = repmat(0.8,[1,3]);
                end
                if ~isempty(h1)
                    plot(iFreq,theseRs(iR),'x','MarkerSize',5,'Color',pColor);
                    hold on;
                end
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
                if ~isempty(h1)
                    plot(iFreq,theseRs(iR),'.','MarkerSize',20,'Color',pColor);
                    hold on;
                end
            end
        end

        Ravg = [];
        for iFreq = 1:numel(freqRs)
            theseRs = freqRs{iFreq};
            thesePs = freqPs{iFreq};
            Ravg(iFreq) = mean(theseRs(thesePs >= 0.05));
        end
        if ~isempty(h1)
            plot(Ravg,'color',repmat(0.8,[1,3]));
        end
        Ravg = [];
        for iFreq = 1:numel(freqRs)
            theseRs = freqRs{iFreq};
            thesePs = freqPs{iFreq};
            Ravg(iFreq) = mean(theseRs(thesePs < 0.05 & thesePs >= 0.01));
        end
        if ~isempty(h1)
            plot(Ravg,'color','r');
        end

        Ravg = [];
        for iFreq = 1:numel(freqRs)
            theseRs = freqRs{iFreq};
            thesePs = freqPs{iFreq};
            Ravg(iFreq) = mean(theseRs(thesePs < 0.01));
        end
        if ~isempty(h1)
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
        end
        
        pSC = [];
        for iFreq = 1:numel(freqPs)
            pSC(iFreq,:) = freqPs{iFreq};
        end
        if ~isempty(h2)
            figure(h2);
            subplot(3,2,prc(2,[iCond,iTiming]));
            imagesc(pSC');
            colormap([jet(100);repmat(0.8,[1,3])]);
            cb = colorbar;
            caxis([0 0.05]);
            set(cb,'YTick',sort([0.01 caxis]));
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
            set(gcf,'color','w');
        end
        
        
        [uniqueLFPfiles,ic,ia] = unique(LFPfiles_local);
        allBars_primEvents = [];
        allBars_dirEvents = [];
        for iFreq = 1:size(pSC,1)
            primEvents = [];
            dirEvents = [];
            for iSession = 1:size(pSC,2)
                if pSC(iFreq,iSession) < 0.05
                    neuronIds = find(strcmp(uniqueLFPfiles{iSession},LFPfiles_local) == 1);
                    primEvents = [primEvents primSec(neuronIds,1)'];
                    dirEvents = [dirEvents ismember(neuronIds,dirSelUnitIds)];
                end
            end
            primEvents(isnan(primEvents)) = 8;
            allBars_primEvents(iFreq,:) = histcounts(primEvents,[0.5:1:8.5]);
            allBars_dirEvents(iFreq,:) = [sum(dirEvents==0) sum(dirEvents==1)];
        end
        
        if ~isempty(h3)
            figure(h3);
            subplot(3,2,prc(2,[iCond,iTiming]));
            bar(allBars_dirEvents,'stacked');
            xlim([0 numel(freqList)+1]);
            xticks(1:numel(freqList));
            xticklabels({num2str(freqList(:),'%2.1f')});
            xtickangle(90);
            xlabel('Freq (Hz)');
            ylim([0 100]);
            yticks(ylim);
            ylabel('unit count');
            title(['Unit Class p < 0.05 - Timing Corr x ',timingField,' ',condLabels{iCond},' ',useEventArr]);
            grid on;
            set(gcf,'color','w');
            legend({'~dir','dir'},'location','eastoutside');
        end
        
        if ~isempty(h4)
            figure(h4);
            subplot(3,2,prc(2,[iCond,iTiming]));
            bar(allBars_primEvents,'stacked');
            xlim([0 numel(freqList)+1]);
            xticks(1:numel(freqList));
            xticklabels({num2str(freqList(:),'%2.1f')});
            xtickangle(90);
            xlabel('Freq (Hz)');
            ylim([0 100]);
            yticks(ylim);
            ylabel('unit count');
            title(['Unit Class p < 0.05 - Timing Corr x ',timingField,' ',condLabels{iCond},' ',useEventArr]);
            grid on;
            set(gcf,'color','w');
            legend({eventFieldnames{:},'NaN'},'location','eastoutside');
        end
        
        if ~isempty(h5)
            figure(h5);
            sigBar = [];
            nsigBar = [];
            xspace = 0.25;
            xPos = [];
            colorgroup = [];
            for iFreq = 1:size(pSC,1)
                sigDVs = NaN(1,366);
                nsigDVs = NaN(1,366);
                for iSession = 1:size(pSC,2)
                    neuronIds = find(strcmp(uniqueLFPfiles{iSession},LFPfiles_local) == 1);
                    theseCoords = abs(all_coords(neuronIds,3))*-1;
                    if pSC(iFreq,iSession) < 0.05
                        sigDVs(neuronIds) = theseCoords;
                    else
                        nsigDVs(neuronIds) = theseCoords;
                    end
                end
                sigBar(iFreq*2-1,:) = sigDVs;
                sigBar(iFreq*2,:) = nsigDVs;
                colorgroup = [colorgroup;1 0 0;repmat(0.5,[1,3])];
                xPos = [xPos (iFreq*3-1)-xspace (iFreq*3-1)+xspace];
            end

            subplot(3,2,prc(2,[iCond,iTiming]));
            boxplot(sigBar','position',xPos,'PlotStyle','compact','ColorGroup',colorgroup);
            set(gca,'XTickLabel',{' '});
            xticks([2:3:90]);
            xticklabels({num2str(freqList(:),'%2.1f')});
            xtickangle(90);
            ylim([-9 -5]);
            yticks(-9:.5:-5);
            box_vars = findall(gca,'Tag','Box');
            hLegend = legend(box_vars([1,2]), {'Non-significant','Significant'});

            title(['Unit Class p < 0.05 - Timing Corr x ',timingField,' ',condLabels{iCond},' ',useEventArr]);
            set(gcf,'color','w');
        end
        drawnow;
    end
end