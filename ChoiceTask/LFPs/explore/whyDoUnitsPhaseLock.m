plunits = [5,30,37,40,45,46,49,53,55,99,135,139,144,147,165,195,219,283,329,335];

primUnits = primSec(plunits,1);
primUnits(isnan(primUnits)) = 8;
secUnits = primSec(plunits,2);
secUnits(isnan(secUnits)) = 8;

figuree(800,400);
subplot(121);
bar([histcounts(primUnits,0.5:1:8.5)' histcounts(secUnits,0.5:1:8.5)']);
ylim([0 max(ylim)+1]);
xticklabels({eventFieldnames{:} 'NaN'});
xtickangle(45);
legend({'primary','secondary'});
title({'Which units phase lock to the LFP?','by unit class'});

subplot(122);
bar([sum(ismember(plunits,dirSelUnitIds)) sum(~ismember(plunits,dirSelUnitIds))]);
ylim([0 max(ylim)+1]);
xticklabels({'dirSel','~dirSel'});
xtickangle(45);
title({'','by dirSel'});

% for iNeuron = plunits
%     
% end