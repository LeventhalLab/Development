function [primSec,fractions] = primSecClass(unitEvents,minZ)
% returns the primary and secondary class for each unit
% returns NaN if Z fails to meet minZ for each class

doPlot = true;

primSec = NaN(numel(unitEvents),2);

for iNeuron = 1:numel(unitEvents)
    if ~isempty(unitEvents{iNeuron}.class)
        if unitEvents{iNeuron}.maxz(unitEvents{iNeuron}.class(1)) > minZ
            primSec(iNeuron,1) = unitEvents{iNeuron}.class(1);
            if (unitEvents{iNeuron}.maxz(unitEvents{iNeuron}.class(2)) > unitEvents{iNeuron}.maxz(unitEvents{iNeuron}.class(1)) / 2) || unitEvents{iNeuron}.maxz(unitEvents{iNeuron}.class(2)) > minZ
                primSec(iNeuron,2) = unitEvents{iNeuron}.class(2);
            end
        end
    end
end

eventFieldlabels = {'Cue','Nose In','Tone','Nose Out','Side In','Side Out','Reward'};
primCounts = histcounts(primSec(:,1),linspace(0.5,7.5,8));
secCounts = histcounts(primSec(:,2),linspace(0.5,7.5,8));
allCounts = histcounts(primSec(:),linspace(0.5,7.5,8));
h = figuree(700,700);
subplot(2,2,[1,2]);
barVals = [primCounts;secCounts;allCounts];
bar(barVals');
xticklabels(eventFieldlabels);
ylabel('units');
ylim([0 210]);
legend({'primary','secondary','together'},'location','southoutside');
%  Not sure if these fractions should only be for non NaNs, or include all
%  units, depends on the question?
fractions = barVals ./ [numel(unitEvents);numel(unitEvents);numel(primSec)];
% % fractions = barVals ./ [sum(~isnan(primSec(:,1)));sum(~isnan(primSec(:,2)));sum(~isnan(primSec(:)))];
strfmt = '%1.3f';

% % p_compare = [primSec(~isnan(primSec(:,1)),1);primSec(~isnan(primSec(:,2)),2)];
% % groups = [zeros(sum(~isnan(primSec(:,1))),1);ones(sum(~isnan(primSec(:,2))),1)];
for iEvent = 1:7
    tstr = [num2str(barVals(1,iEvent)),', ',num2str(barVals(2,iEvent)),', ',num2str(barVals(3,iEvent))];
    text(iEvent,195,tstr,'HorizontalAlignment','center','fontSize',7);
    tstr = [num2str(fractions(1,iEvent),strfmt),', ',num2str(fractions(2,iEvent),strfmt),', ',num2str(fractions(3,iEvent),strfmt)];
    text(iEvent,185,tstr,'HorizontalAlignment','center','fontSize',7);
end
title('Unit classes');


subplot(2,2,3);
pie([sum(~isnan(primSec(:,1))) sum(isnan(primSec(:,1)))]);
legend({'classified','NaN class'},'location','southoutside')
title('Primary NaN classes');

subplot(2,2,4);
pie([sum(~isnan(primSec(:,2))) sum(isnan(primSec(:,2)))]);
legend({'classified','NaN class'},'location','southoutside')
title('Secondary NaN classes');
set(gcf,'color','w');

% seondary fate
% % figuree(1100,300);
% % for iEvent = 1:7
% %     subplot(1,7,iEvent);
% %     primIdx = primSec(:,1) == iEvent;
% %     secCounts = histcounts(primSec(primIdx,2),linspace(0.5,7.5,8));
% %     bar(secCounts,'k');
% %     xticklabels(eventFieldlabels);
% %     ylabel('units');
% %     ylim([0 40]);
% %     xtickangle(90);
% %     if iEvent == 4
% %         title({'Fate of primary classes (i.e. what is the secondary for each primary?)',eventFieldlabels{iEvent}});
% %     else
% %         title(eventFieldlabels{iEvent});
% %     end
% % end
% % set(gcf,'color','w');