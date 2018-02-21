% % highZIds = find(maxHistValues_max > 0.5);
x = linspace(-tWindow,tWindow,size(zCounts,3));
nSmooth = 3;
colors = jet(numel(eventFieldnames));

useMovements = [1,2];
figure('position',[0 0 1600 400*numel(useMovements)]);
iSubplot = 1;
rows = numel(useMovements);
cols = numel(eventFieldnames);
eventFieldnamesLegend = {'Light On','Nose In','Cue/Go','Nose Out','Side In','Side Out','Food Cup'};
for iMovement = useMovements
    for iPlotEvent = 1:numel(eventFieldnames)
        subplot(rows,cols,iSubplot);
        for iEvent = 1:numel(eventFieldnames) % classifier
            neurons = find(eventIds_by_maxHistValues == iEvent);
% %             neurons = neurons(ismember(neurons,highZIds));
            if iMovement == 1
                cur_all_tidx_correct = (squeeze(all_tidx_contra_correct_sub(neurons,iPlotEvent,:,:)));
                cur_all_tidx_correct = [(squeeze(all_tidx_contra_correct_sub(neurons,iPlotEvent,:,:)));...
                    (squeeze(all_tidx_ipsi_correct_sub(neurons,iPlotEvent,:,:)))];
            else
                cur_all_tidx_correct = (squeeze(all_tidx_ipsi_correct_sub(neurons,iPlotEvent,:,:)));
            end
            
            hold on; grid on;
            plot(x,smooth(nanmean(cur_all_tidx_correct,1),nSmooth),'linewidth',2,'color',colors(iEvent,:));
            ylim([-0.5 1]);
            xlim([-1 1]);
            if iEvent == iPlotEvent
                title([eventFieldnames{iPlotEvent},' (',num2str(size(cur_all_tidx_correct,1)),')'],...
                    'color',colors(iPlotEvent,:));
% %                 title(eventFieldnamesLegend{iPlotEvent},...
% %                     'color',colors(iPlotEvent,:));
            end
            if iMovement == 1 && iPlotEvent == 1
                ylabel('z-contra');
            elseif iMovement == 2 && iPlotEvent == 1
                ylabel('z-ipsi');
            end
        end
        iSubplot = iSubplot + 1;
    end
end

% !!!
% % return;

figure('position',[0 0 1600 900]);
iSubplot = 1;
rows = numel(eventFieldnames);
cols = numel(eventFieldnames);

for iEvent = 1:numel(eventFieldnames) % classifier
    for iPlotEvent = 1:numel(eventFieldnames)
        subplot(rows,cols,iSubplot);
        neurons = find(eventIds_by_maxHistValues == iEvent);
% %         neurons = neurons(ismember(neurons,highZIds));
        cur_all_tidx_contra_correct = (squeeze(all_tidx_contra_correct(neurons,iPlotEvent,:,:)));
        cur_all_tidx_ipsi_correct = (squeeze(all_tidx_ipsi_correct(neurons,iPlotEvent,:,:)));
        
        hold on; grid on;
        plot(x,smooth(nanmean(cur_all_tidx_contra_correct,1),nSmooth),'linewidth',1,'color',colors(iEvent,:));
        loopStyle = '--.';
        for ii = 1:2
            if ii == 2
                loopStyle = '-';
            end
            plot(x,smooth(nanmean(cur_all_tidx_ipsi_correct,1),nSmooth),loopStyle,'linewidth',1,'color',[colors(iEvent,:) .5]);
        end
        ylim([-0.5 1]);
        xlim([-1 1]);
        title(eventFieldnames{iPlotEvent},'color',colors(iPlotEvent,:));
        if iPlotEvent == 1
            ylabel('z-score');
            lgd = legend(['contra (',num2str(size(cur_all_tidx_contra_correct,1)),')'],...
                ['ipsi (',num2str(size(cur_all_tidx_ipsi_correct,1)),')'],...
                'location','northwest');
            lgd.FontSize = 6;
            legend('boxoff');
        end
        iSubplot = iSubplot + 1;
    end
end
% lgd = legend(eventFieldnames,'location','south');
% lgd.FontSize = 10;
% set(lgd,'position',[0 0.85 .1 .1]);