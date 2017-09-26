% run plotPermutations.m with:
% % events = [2];
% % unitTypes = {'tone_centerOut'};
% % timingFields = {'RT'};
% % movementDirs = {'all'};
pval = .01;
zSmooth = 3;

useVars_noseInRT = {all_z_raw.evNoseIn_unTone_n49_movDirall_byRT_binIncMs20_binMs50,...
    all_z_raw.evNoseIn_unNoseOut_n76_movDirall_byRT_binIncMs20_binMs50};

useVars_noseInMT = {all_z_raw.evNoseIn_unTone_n49_movDirall_byMT_binIncMs20_binMs50,...
    all_z_raw.evNoseIn_unNoseOut_n76_movDirall_byMT_binIncMs20_binMs50};

useVars_noseOutRT = {all_z_raw.evNoseOut_unTone_n49_movDirall_byRT_binIncMs20_binMs50,...
    all_z_raw.evNoseOut_unNoseOut_n76_movDirall_byRT_binIncMs20_binMs50};

useVars_noseOutMT = {all_z_raw.evNoseOut_unTone_n49_movDirall_byMT_binIncMs20_binMs50,...
    all_z_raw.evNoseOut_unNoseOut_n76_movDirall_byMT_binIncMs20_binMs50};

all_vars = {useVars_noseInRT,useVars_noseOutRT,useVars_noseInMT,useVars_noseOutMT};
all_eventLabels = {eventFieldlabels{3},eventFieldlabels{4}};
all_sortedBy = {'RT','RT','MT','MT'};
    
colors = lines(3);
figuree(1100,800);
iSubplot = 1;
for iSubplot = 1:4
    subplot(2,2,iSubplot);
    useVars = all_vars{iSubplot};
    lns = [];
    for iUnit = 1:2
        cur_z = useVars{iUnit};
        for ii = 1:size(cur_z)
            cur_z(ii,:) = smooth(cur_z(ii,:),zSmooth);
        end

        all_RHO = [];
        all_PVAL = [];
        for ii_timeSeg = 1:size(cur_z,2)
            [RHO,PVAL] = corr(cur_z(:,ii_timeSeg),meanBinsSeconds(2:end)');
            all_RHO(ii_timeSeg) = RHO;
            all_PVAL(ii_timeSeg) = PVAL;
        end

        yyaxis left;
        lns(iUnit) = plot(tMean,all_RHO,'-','color',colors(iUnit,:),'lineWidth',3);
        hold on;
        plot(tMean(all_PVAL < pval),all_RHO(all_PVAL < pval),'*','color',colors(iUnit,:),'markerSize',15);
        ylabel('corr');
        ylim([-1 1]);
        set(gca,'YColor','k');

        yyaxis right;
        plot(tMean,all_PVAL,'-.','color',colors(iUnit,:),'lineWidth',0.5);
        ylabel('p');
        ylim([0 0.05]);
        xlabel('time (s)');
        set(gca,'YColor','k');

        titleText = {all_eventLabels{iUnit},all_sortedBy{iSubplot}};
    end
    legendText = {[all_eventLabels{1},' units'],[all_eventLabels{2},' units']};
    grid on;
%     title(titleText);
    legend(lns,legendText);
end
set(gcf,'color','w');

% yyaxis right;
% lns(2) = plot(tMean,all_PVAL,'color',[1 0 0 0.3],'lineWidth',0.5);
% ylabel('p');
% ylim([0 0.01]);
% set(gca,'YColor','r');

