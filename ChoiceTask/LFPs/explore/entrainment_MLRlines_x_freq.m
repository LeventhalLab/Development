% use /explore/entrainmentHighRes_allEvents.m
doSetup = false;

doPlot_MRLdist = true;
doPlot_MRL_conds = false;
doPlot_MRL_pval = false;

doSave = true;
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

if doPlot_MRLdist
    iFreq = 6;
    data_labels = {'MRL','p-value','mean angle'};
    data_ylims = {[0 0.5],[0 0.05],[-pi pi]};
    pThresh = 0.05;
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

if doPlot_MRL_conds
    data_labels = {'MRL','p-value','mean angle'};
    data_ylims = {[0 0.25],[0 1],[-pi pi]};
    pThresh = 0.05;
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

if doPlot_MRL_pval
    h = ff(1400,800);
    left_color = [0 0 0];
    right_color = [1 0 0];
    set(h,'defaultAxesColorOrder',[left_color; right_color]);

    rows = 2;
    cols = 4;
    ylim_MRLs = [0 0.2];
    ylim_pvals = [0 1];
    pThresh = 0.05;
    for iEvent = 1:8
        data = squeeze(mean(MRLs(:,iEvent,:)));
        subplot(rows,cols,iEvent);
        yyaxis left;
        plot(data,'lineWidth',3);
        ylim(ylim_MRLs);
        yticks(ylim);
        ylabel('MRL');

        data = squeeze(sum(pvals(:,iEvent,:) < pThresh)) ./ size(unitAngles,2);
        yyaxis right;
        plot(data,'lineWidth',3);
        ylim(ylim_pvals);
        yticks(ylim);
        ylabel(sprintf('frac. p < %1.2f',pThresh));

        title(eventFieldnames_wFake{iEvent});
        xticks(1:size(MRLs,3));
        xticklabels(compose('%2.1f',freqList));
        xtickangle(270);
        xlim([1 size(MRLs,3)]);
        xlabel('Freq (Hz)');
        drawnow;
    end
    set(gcf,'color','w');
end