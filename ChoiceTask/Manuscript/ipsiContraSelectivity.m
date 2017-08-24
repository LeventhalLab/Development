% This analysis shows the Fraction of (classified) units that exceeds a
% z-score associated with p-value (see link).
% https://people.wku.edu/david.neal/109/Unit4/ConfInt.pdf

% prob z
% 0.90 1.645
% 0.95 1.96
% 0.98 2.326
% 0.99 2.576

trialTypes = {'correctContra','correctIpsi'};
trialLabels = {'Contra','Ipsi'};
ps = [0.05 0.01];
psZ = [1.96 2.576];
barMult = [1 -1];
barAlpha = [0.2 1];
colors = lines(numel(trialTypes));
useEvents = 1:7;
binMs = 50;

psZ = [1.96];
barAlpha = [0.8 1];

figuree(1300,400);
barCount = 1;
lns = [];
legendLabels = {};
neuronCount = zeros(numel(trialTypes),numel(useEvents));
for iTrialType = 1:numel(trialTypes)
    disp(['--- iTrialType ',num2str(iTrialType)]);
%     [unitEvents,all_zscores] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,{trialTypes{iTrialType}},useEvents);
    for iProbs = 1:numel(psZ)
        legendLabels{barCount} = [trialLabels{iTrialType},' > ',num2str(ps(iProbs))];
        pMatrix = zeros(numel(useEvents),size(all_zscores,3));
        for iNeuron = 1:size(all_zscores,1)
            disp(['iNeuron ',num2str(iNeuron)]);
            for iEvent = useEvents
                if ~isempty(unitEvents{iNeuron}.class)% && iEvent == unitEvents{iNeuron}.class(1)
                    if iProbs == 1 % only count neurons once for each trial type
                        neuronCount(iTrialType,iEvent) = neuronCount(iTrialType,iEvent) + 1;
                    end
                    curZ = squeeze(all_zscores(iNeuron,iEvent,:));
                    % uses abs() on z-score, so it includes negative dips
                    pMatrix(iEvent,abs(curZ) > psZ(iProbs)) = pMatrix(iEvent,abs(curZ) > psZ(iProbs)) + 1;
                end
            end
        end

        eventCount = 1;
        for iEvent = useEvents
            subplot(1,numel(useEvents),iEvent);
            bar((pMatrix(iEvent,:)./size(all_zscores,1))*barMult(iTrialType),'FaceColor',colors(iTrialType,:),'EdgeColor','none','FaceAlpha',barAlpha(iProbs));
            if eventCount == 1
                barCount = barCount + 1;
            end
            hold on;
            xticks([1 20 40]);
            xticklabels({'-1','0','1'});
            xlim([1 40]);
            xlabel('time (s)');
            maxy = 0.8;
            ylim([-maxy maxy]);
            yticks([-maxy:0.2:maxy]);
            title([eventFieldnames{iEvent}]);
            text(2,.05*barMult(iTrialType),[num2str(neuronCount(iTrialType,iEvent)),' units']);
            grid on;
            if eventCount == 1
                ylabel('Fraction of units');
            end
            eventCount = eventCount + 1;
        end
    end
end

legend(legendLabels);