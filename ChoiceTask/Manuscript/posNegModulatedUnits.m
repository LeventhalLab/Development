if false
    tWindow = 1;
    binMs = 20;
    useEvents = 1:7;
    useTiming = {};
    % moved contra on contra tone
    trialTypes = {'correct'};
    [unitEvents,all_zscores,unitClass] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);
    
    minZ = 1;
    [primSec,fractions] = primSecClass(unitEvents,minZ);
end

posMod = zeros(2,7);
negMod = zeros(2,7);
for iNeuron = 1:numel(analysisConf.neurons)
    for ii_primSec = 1:2
        curClass = primSec(iNeuron,ii_primSec);
        if curClass > 0
            if unitEvents{iNeuron}.maxz(curClass) > 0
                posMod(ii_primSec,curClass) = posMod(ii_primSec,curClass) + 1;
            else
                negMod(ii_primSec,curClass) = negMod(ii_primSec,curClass) + 1;
            end
        end
    end
end

figuree(900,800);
subplot(3,7,[1:7]);
bar(posMod','stacked');
legend('Primary','Secondary');
ylabel('(neg) <-- Modulation Coding --> (pos)');
title('Are Z scores pos/neg modulated for units of a class?')
xticklabels(eventFieldlabels);
hold on;
bar(negMod'*-1,'stacked');

iSubplot = 8;
for ii_primSec = 1:2
    for iEvent = 1:7
        subplot(3,7,iSubplot);
        totalUnits = posMod(ii_primSec,iEvent) + negMod(ii_primSec,iEvent);
        pie([posMod(ii_primSec,iEvent)/totalUnits negMod(ii_primSec,iEvent)/totalUnits]);
        title({eventFieldlabels{iEvent},[' (',num2str(posMod(ii_primSec,iEvent)),'/',num2str(totalUnits),')']});
        iSubplot = iSubplot + 1;
    end
end