% use /explore/entrainmentHighRes_allEvents.m
doSetup = false;
doSave = true;

doPlot_MRL_plotSpread = false;
doPlot_MRL_InOut = true;
doPlot_MRL_allEvents = true;

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/entrainment';

allUnits = 1:366;
condUnits = {allUnits,find(~ismember(allUnits,[dirSelUnitIds,ndirSelUnitIds])),ndirSelUnitIds,dirSelUnitIds};
condLabels = {'allUnits','other','ndirSel','dirSel'};
condLabels_wCount = {['allUnits (n = ',num2str(numel(condUnits{1})),')'],...
    ['other (n = ',num2str(numel(condUnits{2})),')'],...
    ['ndirSel (n = ',num2str(numel(condUnits{3})),')'],...
    ['dirSel (n = ',num2str(numel(condUnits{4})),')']};

eventFieldnames_wFake = {eventFieldnames{:} 'inter-trial'};

% [ ] do dirSel conditions
iShuffle = 1;
if doSetup
    MRLs = NaN(size(unitAngles,2),size(unitAngles,3),size(unitAngles{1},1),4);
    pvals = MRLs;
    mus = MRLs;
    for iNeuron = 1:size(unitAngles,2)
        for iEvent = 1:size(unitAngles,3)
            theseAngles = unitAngles{iShuffle,iNeuron,iEvent};
            if isempty(theseAngles)
                continue;
            end
            for iFreq = 1:size(theseAngles,1)
                MRLs(iNeuron,iEvent,iFreq) = circ_r(theseAngles(iFreq,:)');
                pvals(iNeuron,iEvent,iFreq) = circ_rtest(theseAngles(iFreq,:)');
                mus(iNeuron,iEvent,iFreq) = circ_mean(theseAngles(iFreq,:)');
            end
        end
    end
end

% close all

if doPlot_MRL_plotSpread
    pThresh = 0.05;
    iFreq = 6;
    data_labels = {'MRL',sprintf('frac p < %1.2f',pThresh),'mean angle'};
    data_ylims = {[0 0.5],[0 0.05],[-pi pi]};
    rows = 2;
    cols = 4;
    line_colors = lines(3);
    colors = [0 0 0;1 0 0;line_colors([1,3],:)];
    
    for iType = 1:2
        h = ff(1400,800);
        for iEvent = 1:8
            subplot(rows,cols,iEvent);
            data = {};
            for iCond = 1:4
                if iType == 1
                    data{iCond} = MRLs(condUnits{iCond},iEvent,iFreq);
                else
                    temp = pvals(condUnits{iCond},iEvent,iFreq);
                    data{iCond} = temp(temp < pThresh);
                end
            end
            plotSpread(data,'distributionColors',colors,'showMM',2);

            ylim(data_ylims{iType});
            yticks(ylim);
            ylabel(data_labels{iType});

            xticklabels(condLabels);
            xtickangle(90);

            title(eventFieldnames_wFake{iEvent});
            drawnow;
        end
        set(gcf,'color','w');
        addNote(h,data_labels{iType},25);
        if doSave
            saveas(h,fullfile(savePath,['entrainmentLines_xFreq_tAfter0_delta_',data_labels{iType},'.png']));
            close(h);
        end
    end
end

if doPlot_MRL_InOut
    pThresh = 0.05;
    inOutLabels = {'In-trial','Inter-trial'};
    data_labels = {'MRL',sprintf('frac p < %1.2f',pThresh),'mean angle'};
    data_ylims = {[0 0.05],[0 1],[-pi pi]};
    lineWidths = [1 1 3 3];
    rows = 2;
    cols = 3;
    line_colors = lines(3);
    colors = [0 0 0;1 0 0;line_colors([1,3],:)];
    inOut_data_rs = {all_spikeHist_inTrial_rs,all_spikeHist_rs};
    inOut_data_pvals = {all_spikeHist_inTrial_pvals,all_spikeHist_pvals};
    inOut_data_mus = {all_spikeHist_inTrial_mus,all_spikeHist_mus};
    h = ff(1200,800);
    for iType = 1:3
        for iInOut = 1:2
            for iCond = 1:4
                if iType == 1
                    data = nanmean(inOut_data_rs{iInOut}(condUnits{iCond},:));
                elseif iType == 2
                    data = squeeze(sum(inOut_data_pvals{iInOut}(condUnits{iCond},:) < pThresh)) ./ ...
                        numel(condUnits{iCond});
                else
                    data = nanmean(inOut_data_mus{iInOut}(condUnits{iCond},:));
                end
                
                subplot(rows,cols,prc(cols,[iInOut,iType]));
                plot(data,'lineWidth',lineWidths(iCond),'color',colors(iCond,:));
                hold on;
            end

            ylim(data_ylims{iType});
            yticks(ylim);
            ylabel(data_labels{iType});

            xticks(1:size(MRLs,3));
            xticklabels(compose('%2.1f',freqList));
            xtickangle(270);
            xlim([1 size(MRLs,3)]);
            xlabel('Freq (Hz)');

            title({inOutLabels{iInOut},data_labels{iType}});
            legend(condLabels_wCount,'location','northeast');
            legend boxoff;
            drawnow;
        end
    end
    set(gcf,'color','w');
    if doSave
        saveas(h,fullfile(savePath,['entrainmentLines_xFreq_inOut.png']));
        close(h);
    end
end

if doPlot_MRL_allEvents
    pThresh = 0.05;
    data_labels = {'MRL',sprintf('frac p < %1.2f',pThresh),'mean angle'};
    data_ylims = {[0 0.25],[0 1],[-pi pi]};
    lineWidths = [1 1 3 3];
    rows = 2;
    cols = 4;
    line_colors = lines(3);
    colors = [0 0 0;1 0 0;line_colors([1,3],:)];
    for iType = 1:3
        h = ff(1400,800);
        for iEvent = 1:8
            for iCond = 1:4
                if iType == 1
                    data = squeeze(nanmean(MRLs(condUnits{iCond},iEvent,:)));
                elseif iType == 2
                    data = squeeze(sum(pvals(condUnits{iCond},iEvent,:) < pThresh)) ./ ...
                        numel(condUnits{iCond});
                else
                    data = squeeze(nanmean(mus(condUnits{iCond},iEvent,:)));
                end
                
                subplot(rows,cols,iEvent);
                plot(data,'lineWidth',lineWidths(iCond),'color',colors(iCond,:));
                hold on;
            end

            ylim(data_ylims{iType});
            yticks(ylim);
            ylabel(data_labels{iType});

            xticks(1:size(MRLs,3));
            xticklabels(compose('%2.1f',freqList));
            xtickangle(270);
            xlim([1 size(MRLs,3)]);
            xlabel('Freq (Hz)');

            title(eventFieldnames_wFake{iEvent});
            drawnow;
        end
        legend(condLabels_wCount,'location','northwest');
        legend boxoff;
        set(gcf,'color','w');
        addNote(h,data_labels{iType},25);
        if doSave
            saveas(h,fullfile(savePath,['entrainmentLines_xFreq_tAfter0_',data_labels{iType},'.png']));
            close(h);
        end
    end
end