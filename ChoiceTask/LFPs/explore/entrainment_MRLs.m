% setup with /explore/entrainmentHighRes_shuffleSetup.m
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/entrainment';

allUnits = 1:366;
condUnits = {allUnits,find(~ismember(allUnits,[dirSelUnitIds,ndirSelUnitIds])),ndirSelUnitIds,dirSelUnitIds};
condLabels = {'allUnits','other','ndirSel','dirSel'};
condLabels_wCount = {['allUnits (n = ',num2str(numel(condUnits{1})),')'],...
    ['other (n = ',num2str(numel(condUnits{2})),')'],...
    ['ndirSel (n = ',num2str(numel(condUnits{3})),')'],...
    ['dirSel (n = ',num2str(numel(condUnits{4})),')']};
shuffleLabels = {'noShuffle','shuffle'};
eventLabels = {eventFieldnames{:},'Inter-trial'};
useEvents = [4,8];
useShuffle = [1,2];
iFreq = 1:8;

doCompile = false;
doPlot_polar = true;
doPlot_4conds = false;
doSave = false;

% % if doCompile
% %     all_condMean = {};
% %     all_condPval = {};
% %     for iCond = 1:numel(condUnits)
% %         condMean = NaN(2,numel(condUnits{iCond}),numel(useEvents));
% %         condPval = NaN(2,numel(condUnits{iCond}),numel(useEvents));
% %         for iShuffle = useShuffle
% %             for iEvent = 1:numel(useEvents)
% %                 neuronCount = 0;
% %                 for iNeuron = condUnits{iCond}
% %                     neuronCount = neuronCount + 1;
% %                     neuronAngles = unitAngles{iShuffle,iNeuron,useEvents(iEvent)}(iFreq,:);
% %                     neuronAngles = neuronAngles(:);
% %                     if isempty(neuronAngles)
% %                         continue;
% %                     end
% %                     condMean(iShuffle,neuronCount,iEvent) = circ_mean(neuronAngles);
% %                     condPval(iShuffle,neuronCount,iEvent) = circ_rtest(neuronAngles);
% %                 end
% %             end
% %         end
% %         all_condMean{iCond} = condMean;
% %         all_condPval{iCond} = condPval;
% %     end
% % end

if doPlot_polar
    rows = 2;
    cols = 3;
    for iShuffle = 1%:2
        h = ff(1400,800);
        colors = [repmat(0.2,[1,3]);repmat(0.8,[1,3]);lines(2)];
        useCond = [1:4];
        rlimVals = [0 0.5];
        lns = [];
        pThresh = 0.05;
        for iEvent = 1:2
            statsTable = cell(numel(useCond),2); % mean angle, std, pval
            kuiperMat = NaN(numel(useCond));
            for iCond = 1:numel(useCond)
                subplot(rows,cols,prc(cols,[iEvent 1]));
                condMean = all_condMean{useCond(iCond)};
    % %             condPval = all_condPval{useCond(iCond)};

    % %             useUnits = condPval(iShuffle,:,iEvent) < pThresh;

                theta = condMean(iShuffle,:,useEvents(iEvent));
                theta(isnan(theta)) = [];
                pval = circ_rtest(theta);
                mu = circ_mean(theta');
                r = circ_r(theta');
                lns(iCond) = polarplot([mu mu],[0 r],'lineWidth',6,'color',colors(iCond,:));
                hold on;
                thetaticks([0 90 180 270]);
                pax = gca;
                pax.ThetaZeroLocation = 'top';
                pax.ThetaDir = 'clockwise';
                rlim(rlimVals);
                rticks(rlim);

                if pval < pThresh
                    polarplot(mu,r,'*','color',colors(iCond,:),'markerSize',15);
                end
                [s,s0] = circ_std(theta');
                statsTable{iCond,1} = [num2str(rad2deg(mu),'%2.1f'),char(176),' ',char(177),...
                    num2str(rad2deg(s0),'%2.1f')];
                statsTable{iCond,2} = num2str(pval,2);
            end
            set(gca,'fontSize',16);
            legend(lns,{condLabels_wCount{useCond}},'location','southoutside');
            title(['\delta-MRL at ',eventLabels{useEvents(iEvent)}]);

            hs = subplot(rows,cols,prc(cols,[iEvent 2]));
            pos = get(hs,'position');
            un = get(hs,'Units');
            delete(hs);
            uit = uitable(h,'Data',statsTable,'Units',un,'Position',pos,'ColumnWidth',{100});
            uit.FontSize = 14;
            uit.ColumnName = {['Mean ',char(177),' Std'],'P-value'};
            uit.RowName = condLabels;

            % Kuiper Test
            for iCond = 1:numel(useCond)
                cond1Mean = all_condMean{useCond(iCond)};
                alpha1 = cond1Mean(iShuffle,:,useEvents(iEvent));
                for jCond = iCond:numel(useCond)
                    cond2Mean = all_condMean{useCond(jCond)};
                    alpha2 = cond2Mean(iShuffle,:,useEvents(iEvent));
                    kuiperMat(jCond,iCond) = circ_kuipertest(alpha1,alpha2);
                end
            end
            subplot(rows,cols,prc(cols,[iEvent 3]));
            imagesc(kuiperMat,'AlphaData',~isnan(kuiperMat));
            caxis([0 0.05]);
            cb = colorbar;
            cb.Ticks = caxis;
            cb.Label.String = 'p-value';
            xticks(1:3);
            xticklabels({condLabels{useCond}});
            xtickangle(90);
            yticks(1:3);
            yticklabels({condLabels{useCond}});
            title('Kuiper Test Matrix');
            set(gca,'fontSize',16);

            for iCond = 1:numel(useCond)
                for jCond = iCond:numel(useCond)
    %                 text(iCond,jCond,[num2str(iCond),',',num2str(jCond)]);%num2str(kuiperMat(iCond,jCond),2));
                    text(iCond,jCond,num2str(kuiperMat(jCond,iCond),2),'horizontalAlignment','center');
                end
            end
        end
        set(gcf,'color','w');
        if doSave
            saveFile = ['entrainment_polarPlot_iShuffle',num2str(iShuffle),'.png'];
            saveas(h,fullfile(savePath,saveFile));
            close(h);
        end
    end
end

if doPlot_4conds
    rows = 4;
    cols = 4;
    iShuffle = 1;
%     close all;
    h = ff(1400,900);
    pThresh = 0.05;
    colors = {'k','r'};
    lineStyles = {'-',':'};
    rlimVals = [0 0.5];
    ylimVals = [0 0.2];
    lns = [];
    for iCond = 1:4
        condMean = all_condMean{iCond};
        condPval = all_condPval{iCond};
        for iShuffle = 1:2
            for iEvent = 1:2
                subplot(rows,cols,prc(cols,[iShuffle*2-1,iCond]));
                rawHist = mean(squeeze(condCounts(iShuffle,iCond,useEvents(iEvent),iFreq,:)))';
                thisHist = rawHist ./ sum(rawHist);
                lns(iEvent) = plot(repmat(thisHist,[2,1]),'lineWidth',3,'color',colors{iEvent},'lineStyle',lineStyles{iShuffle});
                hold on;
                ylim(ylimVals);
                ylabel({'Frac. of Units','Pref. Phase'});
    %             xticks([1,6.5,12.5,18.5,24]);
    %             xticklabels([0 180 360 540 720]-180);
                degBins = rad2deg(binEdges) + 180;
                degBinsHist = [degBins degBins(2:end)];
                degBinsHist = circshift(degBinsHist,7);
                xticks([1:25]-0.5);
                xticklabels(degBinsHist);
    %             xtickLocs = [1 4 7 8 11 14 17 20 23];
    %             xticks(xtickLocs);
    %             xticklabels(degBinsHist(xtickLocs));
                xtickangle(270);
                xlabel('Spike phase (deg)');
                yticks(ylim);
                title({condLabels{iCond},shuffleLabels{iShuffle}});
                grid on;
                if iCond == 1 && iEvent == 2
                    legend(lns,eventLabels,'location','northwest');
                end

                subplot(rows,cols,prc(cols,[iShuffle*2,iCond]));
                theta = condMean(iShuffle,:,iEvent);
                theta(isnan(theta)) = [];
                pval = circ_rtest(theta);
                mu = circ_mean(theta');
                r = circ_r(theta');
                polarplot([mu mu],[0 r],'lineWidth',3,'color',colors{iEvent},'lineStyle',lineStyles{iShuffle});
                hold on;
                thetaticks([0 90 180 270]);
                pax = gca;
                pax.ThetaZeroLocation = 'top';
                pax.ThetaDir = 'clockwise';
                rlim(rlimVals);
                rticks(rlim);

                if pval < pThresh
                    polarplot(mu,r,'*','color',colors{iEvent},'markerSize',15);
                end

    % %             sigIdx = condPval(iShuffle,:,iEvent) < pThresh;
    % %             theta = condMean(iShuffle,sigIdx,iEvent);
    % %             mu = circ_mean(theta');
    % %             r = circ_r(theta');
    % %             polarplot([mu mu],[0 r],'lineWidth',3,'color','r');

    %             polarhistogram(theta,20);
            end
        end
    end
    set(gcf,'color','w');
end