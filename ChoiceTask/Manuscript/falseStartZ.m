lns = [];
colors = lines(3);
figuree(800,800);

falseEvents = [2,4];
for iEvent = 1:2
    curEvent = falseEvents(iEvent);
    
    subplot(2,2,iEvent);
    plot(squeeze(all_zscores_falseStart(toneNeurons,iEvent,:))','-','LineWidth',0.5,'color',[colors(3,:) 0.5]); hold on;
    plot(squeeze(all_zscores_falseStart(centerOutNeurons,iEvent,:))','-','LineWidth',0.5,'color',[colors(1,:) 0.5]);
    ylim([-20 40]);
    title([eventFieldnames{curEvent},' FS']);
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    grid on;
    
    subplot(2,2,iEvent+2);
    plot(squeeze(all_zscores_CICO(toneNeurons,iEvent,:))','-','LineWidth',0.5,'color',[colors(3,:) 0.5]); hold on;
    plot(squeeze(all_zscores_CICO(centerOutNeurons,iEvent,:))','-','LineWidth',0.5,'color',[colors(1,:) 0.5]);
    ylim([-20 40]);
    title([eventFieldnames{curEvent},' corr']);
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    grid on;
end
% legend(lns,'FS tone','Corr tone','FS centerOut','Corr centerOut');


if false
    binMs = 50;
    tWindow = 1;
    [unitEvents_falseStart,all_zscores_falseStart] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,{eventFieldnames{[2,4]}}',tWindow,binMs,{'falseStart'},[2,4]);
    [unitEvents_CICO,all_zscores_CICO] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,{eventFieldnames{[2,4]}}',tWindow,binMs,{'correctContra','correctIpsi'},[2,4]);
end

fs_toneNeurons = [];
fs_notoneNeurons = [];
for iNeuron = 1:numel(unitEvents_falseStart)
    if ~isempty(unitEvents_falseStart{iNeuron}.class) && ~isempty(unitEvents_CICO{iNeuron}.class)
        unitEvents_falseStart{iNeuron}.maxz(2)
        if unitEvents_falseStart{iNeuron}.class(1) == 2 && unitEvents_CICO{iNeuron}.maxz(2) > 5 && unitEvents_falseStart{iNeuron}.maxz(2) < 10
            fs_toneNeurons = [fs_toneNeurons iNeuron];
        else
            fs_notoneNeurons = [fs_notoneNeurons iNeuron];
        end
    end
end

lns = [];
colors = lines(3);
figuree(800,800);

falseEvents = [2,4];
for iEvent = 1:2
    subplot(1,2,iEvent);
    curEvent = falseEvents(iEvent);
  
    lns(1) = plot(smooth(mean(squeeze(all_zscores_falseStart(fs_toneNeurons,iEvent,:))),3),'--','LineWidth',2,'color',colors(3,:)); hold on;
    lns(2) = plot(smooth(mean(squeeze(all_zscores_CICO(fs_toneNeurons,iEvent,:))),3),'-','LineWidth',1,'color',[colors(3,:) 1]);
    lns(3) = plot(smooth(mean(squeeze(all_zscores_falseStart(dirSelNeurons,iEvent,:))),3),'--','LineWidth',2,'color',colors(1,:));
    lns(4) = plot(smooth(mean(squeeze(all_zscores_CICO(dirSelNeurons,iEvent,:))),3),'-','LineWidth',1,'color',[colors(1,:) 1]);
    
    ylim([-5 15]);
    title(eventFieldnames{curEvent});
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    grid on;
end
legend(lns,'FS tone','Corr tone','FS notone','Corr notone');

lns = [];
colors = lines(3);
figuree(800,800);

falseEvents = [2,4];
for iEvent = 1:2
    subplot(2,2,iEvent);
    curEvent = falseEvents(iEvent);
  
    lns(1) = plot(smooth(mean(squeeze(all_zscores_falseStart(toneNeurons,iEvent,:))),3),'--','LineWidth',2,'color',colors(3,:)); hold on;
    lns(2) = plot(smooth(mean(squeeze(all_zscores_CICO(toneNeurons,iEvent,:))),3),'-','LineWidth',1,'color',[colors(3,:) 1]);
    lns(3) = plot(smooth(mean(squeeze(all_zscores_falseStart(centerOutNeurons,iEvent,:))),3),'--','LineWidth',2,'color',colors(1,:));
    lns(4) = plot(smooth(mean(squeeze(all_zscores_CICO(centerOutNeurons,iEvent,:))),3),'-','LineWidth',1,'color',[colors(1,:) 1]);
    
    ylim([-5 15]);
    title(eventFieldnames{curEvent});
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    grid on;
end
legend(lns,'FS tone','Corr tone','FS centerOut','Corr centerOut');

toneSurr = zeros(size(dirSelNeurons));
toneSurr(toneNeurons) = true(numel(toneNeurons),1);

falseEvents = [2,4];
for iEvent = 1:2
    subplot(2,2,iEvent+2);
    curEvent = falseEvents(iEvent);
    
    lns(1) = plot(smooth(mean(squeeze(all_zscores_falseStart(dirSelNeurons,iEvent,:))),3),'--','LineWidth',2,'color',colors(1,:)); hold on;
    lns(2) = plot(smooth(mean(squeeze(all_zscores_CICO(dirSelNeurons,iEvent,:))),3),'-','LineWidth',1,'color',[colors(1,:) 1]);
    lns(3) = plot(smooth(mean(squeeze(all_zscores_falseStart(toneSurr & ~dirSelNeurons,iEvent,:))),3),'--','LineWidth',2,'color',colors(3,:));
    lns(4) = plot(smooth(mean(squeeze(all_zscores_CICO(toneSurr & ~dirSelNeurons,iEvent,:))),3),'-','LineWidth',1,'color',[colors(3,:) 1]);
    
    ylim([-5 15]);
    title(eventFieldnames{curEvent});
    xlim([1 40]);
    xticks([1 20 40]);
    xticklabels({'-1','0','1'});
    grid on;
end
legend(lns,'FS dirSel','Corr dirSel','FS tone&~dirSel','Corr tone&~dirSel');