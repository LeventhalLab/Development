% you have to run ipsiContraShuffle.m then set these, annoying
% dirSelNeuronsNO_type_correct
% dirSelNeuronsNO_type_incorrect
doSave = false;

corr_contra_ids = find(dirSelNeuronsNO_type_correct == 1);
corr_ipsi_ids = find(dirSelNeuronsNO_type_correct == 2);
corr_contra_fate = dirSelNeuronsNO_type_incorrect(corr_contra_ids);
corr_ipsi_fate = dirSelNeuronsNO_type_incorrect(corr_ipsi_ids);

corr_contra_fateIds = find(dirSelNeuronsNO_type_correct == 1 & dirSelNeuronsNO_type_incorrect == 1)
incorr_contra_fateIds = find(dirSelNeuronsNO_type_correct == 1 & dirSelNeuronsNO_type_incorrect == 2)
corr_ipsi_fateIds = find(dirSelNeuronsNO_type_correct == 2 & dirSelNeuronsNO_type_incorrect == 2)
incorr_ipsi_fateIds = find(dirSelNeuronsNO_type_correct == 2 & dirSelNeuronsNO_type_incorrect == 1)

% archive: as of 20171219
% % corr_contra_fateIds =
% %     67
% %    102
% %    103
% %    338
% %    340
% % incorr_contra_fateIds =
% %     60
% %    318
% %    319
% %    332
% % corr_ipsi_fateIds =
% %     71
% %    107
% %    110
% %    261
% %    264
% %    311
% %    326
% %    328
% %    334
% % incorr_ipsi_fateIds =
% %     63
% %    310
% %    313

if false
    contra_fate_counts = histcounts(corr_contra_fate,[-.5:2.5])
    ipsi_fate_counts = histcounts(corr_ipsi_fate,[-.5:2.5])

    colors = [0 0 0;0 1 0;.5 .5 .5;];
    legendText = {'Not Enough Trials','Coded Same Direction','Coded Different Direction'};
    h = figuree(800,400);
    subplot(121);
    pie(contra_fate_counts); % *different order than below for colormap
    title('Correct Contra Fate');
    legend(legendText,'location','southoutside');

    subplot(122);
    pie([ipsi_fate_counts(1) ipsi_fate_counts(3) ipsi_fate_counts(2)]);
    title('Correct Ipsi Fate');
    legend(legendText,'location','southoutside');

    colormap(colors);
    tightfig;
    setFig('','',[1,0.5]);
end
% just hard coding this figure
h = figuree(400,300);
subplot(121);
pie([5,4]);
subplot(122);
pie([9,3]);
tightfig;
setFig('','',[1,0.5]);

if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'dirSelToneMoveCorrFate.eps'));
    close(h);
else
    addNote(h,{'When the tone is opposite','is the directional selectivity','the SAME or DIFF?'});
end