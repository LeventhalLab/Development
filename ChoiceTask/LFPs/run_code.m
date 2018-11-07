% load('deltaRTcorr_norm.mat');
% load('deltaRTcorr_aftert0Eliminated.mat');
% load('deltaRTcorr_beforet0Eliminated.mat');

phaseMap = cmocean('phase');
ff(1400,900);
rows = 2;
cols = 7;
rowLabels = {'power','phase'};
for iEvent = 1:7
    phaseCorr = phaseCorrs_delta{iEvent};
    rawData = rawData_log{iEvent};
    rowData = {rawData,phaseCorr};
    for iRow = 1:2
        subplot(rows,cols,prc(cols,[iRow,iEvent]));
        useData = rowData{iRow};
        [v,k] = sort(all_Times);
        imagesc(timeCenters,1:size(useData,1),useData(k,:));
    %     colormap(gca,phaseMap);
        if iRow == 1
            colormap(gca,jet);
            caxis([-100 100]);
        else
            colormap(gca,parula);
            caxis([-pi pi]);
        end
        xlabel('time (s)');
        if iEvent == 1
            ylabel('RT');
            ytickVals = v(yticks);
            ytickVals = num2str(ytickVals(:),'%1.3f');
            yticklabels(ytickVals);
        else
            ylabel('');
            yticks('');
        end
        title({eventFieldnames{iEvent},rowLabels{iRow}});
    end
end

ff(300,900);
for iEvent = 1:7
    subplot(7,1,iEvent);
    rawData = rawData_log{iEvent};
    plot(timeCenters,smooth(median(rawData),5),'k-','lineWidth',1.5);
    xlim([-1 1]);
    xticks(sort([0 xlim]));
    ylim([-20 20]);
    yticks(sort([0 ylim]));
    if iEvent == 1
        title({'median raw data',eventFieldnames{iEvent}});
    else
         title(eventFieldnames{iEvent});
    end
    grid on;
end
set(gcf,'color','w');

% % iEvent = 3;
% % ff(800,300);
% % phaseMap = cmocean('phase');
% %             
% % subplot(231);
% % data1 = angle(squeeze(W(3,:,:)))';
% % imagesc(data1);
% % colormap(gca,phaseMap);
% % caxis([-pi pi]);
% % title('orig');
% % 
% % subplot(232);
% % data2 = angle(squeeze(W_before(3,:,:)))';
% % imagesc(data1);
% % colormap(gca,phaseMap);
% % caxis([-pi pi]);
% % title('0 before');
% % 
% % subplot(233);
% % data3 = angle(squeeze(W_after(3,:,:)))';
% % imagesc(data3);
% % colormap(gca,phaseMap);
% % caxis([-pi pi]);
% % title('0 after');
% % cbAside(gca,'phase','k')
% % 
% % subplot(234);
% % imagesc(data1-data1);
% % colormap(gca,phaseMap);
% % caxis([-pi pi]);
% % title('orig - orig');
% % 
% % subplot(235);
% % imagesc(data1-data2);
% % colormap(gca,phaseMap);
% % caxis([-pi pi]);
% % title('orig - before');
% % 
% % subplot(236);
% % imagesc(data1-data3);
% % colormap(gca,phaseMap);
% % caxis([-pi pi]);
% % title('orig - after');
% % cbAside(gca,'phase','k')