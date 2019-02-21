% /Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/Manuscript/rtMtDist.m
% load('RTMT_rawData.mat')

% anova1(all_mt,all_rt > median(all_rt));
close all;
doSave
p = anova1(all_mt,(all_rt > 0.2));
drawnow;
xticklabels({'fast RT','slow RT'});
ylim([.1 .5]);
ylabel('MT');
title({'Does RT (fast/slow) affect MT?',['Anova1 p = ',num2str(p,2)]});
grid on;
if doSave
    saveas(gcf,[mfilename,'.png']);
    close all;
end