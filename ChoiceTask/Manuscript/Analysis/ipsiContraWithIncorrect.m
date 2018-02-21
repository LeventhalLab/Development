doSetup = false;
colors = lines(2);
colors(3,:) = colors(1,:) * .5;
colors(4,:) = colors(2,:) * .5;
lineWidths = [2 2 1 1];

savePath = 'C:\Users\Administrator\Documents\Data\ChoiceTask\ipsiContraWithIncorrect';

if false
    tWindow = 1;
    binMs = 20;
    useEvents = 1:7;
    useTiming = {};
    % moved contra on contra tone
    trialTypes = {'correctContra'};
    [~,all_zscores_correctContra,~] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);
    % moved ipsi on ipsi tone
    trialTypes = {'correctIpsi'};
    [~,all_zscores_correctIpsi,~] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);
    % moved contra on ipsi tone
    trialTypes = {'incorrectContra'};
    [~,all_zscores_incorrectContra,~] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);
    % moved ipsi on contra tone
    trialTypes = {'incorrectIpsi'};
    [~,all_zscores_incorrectIpsi,~] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);
    
% %     minZ = 1;
% %     [primSec,fractions] = primSecClass(unitEvents,minZ);
end

zscores_types = {all_zscores_correctContra all_zscores_correctIpsi all_zscores_incorrectContra all_zscores_incorrectIpsi};
nSmooth = 5;

lns = [];
for iNeuron = 1:numel(analysisConf.neurons)
    h = figuree(1500,400);
    for iEvent = 1:numel(eventFieldnames)
        subplot(1,7,iEvent);
        for ii_zscores = 1:numel(zscores_types)
            cur_all_zscores = zscores_types{ii_zscores};
            lns(ii_zscores) = plot(smooth(squeeze(cur_all_zscores(iNeuron,iEvent,:)),nSmooth),'LineWidth',lineWidths(ii_zscores),'Color',colors(ii_zscores,:));
            xlim([1 size(all_zscores_incorrectIpsi,3)]);
            xticks([1 round(size(all_zscores_incorrectIpsi,3)/2) size(all_zscores_incorrectIpsi,3)]);
            xticklabels({'-1','0','1'});
            ylim([-1 3]);
            grid on;
            title([eventFieldlabels{iEvent}]);
            hold on;
        end
    end
    legend(lns,{'+contra','+ipsi','-contra','-ipsi'});
    addNote(h,['unit: ',num2str(iNeuron)]);
    saveas(h,fullfile(savePath,['unit_',num2str(iNeuron,'%03d'),'.png']));
    close(h);
end