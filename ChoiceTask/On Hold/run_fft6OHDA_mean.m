r153path = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0153_20170214_openField-1';
r154pathNORM = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0154_20170214_openField-2';
r154pathNNC = '';
r117path = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0117/R0117-rawdata/R0117_20160503b/R0117_20160503b';

r153files = dir(fullfile(r153path,'*.sev'));
r153files = natsort({r153files.name});

r154files = dir(fullfile(r154pathNORM,'*.sev'));
r154files = natsort({r154files.name});

r117files = dir(fullfile(r117path,'*.sev'));
r117files = natsort({r117files.name});

% chs = [1:2:16 33:2:48];
r15xchs = [49 51 53 55 57 60 61 63]; %STR 50um

params.fpass = [0 80];
params.pad = 0;
params.tapers = [3 5];

r153S = [];
for iCh = 1:numel(r15xchs)
    disp(iCh);
    [r153sev,header] = read_tdt_sev(fullfile(r153path,r153files{r15xchs(iCh)}));
    params.Fs = round(header.Fs);
    [S,f] = mtspectrumc(r153sev',params);
    r153S(:,iCh) = S;
    
    [r154sev,~] = read_tdt_sev(fullfile(r154pathNORM,r154files{chs(iCh)}));
    [S,f] = mtspectrumc(r154sev',params);
    r154S(:,iCh) = S;

    [r117sev,header] = read_tdt_sev(fullfile(r117path,r117files{r15xchs(iCh)}));
end

markBeta = [16 24];
xTickVals = [0 markBeta 40 80];

nSmooth = 500;
% [ ] Use shaded error!
h = figure('position',[0 0 500 900]);
h1 = subplot(211);
H1 = shadedErrorBar(f,smooth(mean(r153S,2),nSmooth),smooth(std(r153S,0,2),nSmooth),{'color',[218/255 83/255 25/255]});
hold on;
H2 = shadedErrorBar(f,smooth(mean(r154S,2),nSmooth),smooth(std(r154S,0,2),nSmooth),{'color',[0 114/255 190/255]});
ylim([0 40]);
xlim([1 80]);
legend([H1.mainLine,H2.mainLine],{'R153 6-OHDA','R154 Normal'},'Location','northeast');
ylabel('10*log10(X)');
title('STR 50um chs[49 51 53 55 57 60 61 63], 2 minutes no behavior');
xlabel('Freq (Hz)');
xticks(xTickVals);
line([markBeta(1) markBeta(1)],get(h1,'YLim'),'Color','k','LineStyle','--','linewidth',2);
line([markBeta(2) markBeta(2)],get(h1,'YLim'),'Color','k','LineStyle','--','linewidth',2);
yticks([0 40]);
axes(h1);
% line([20 20],get(h1,'YLim'),'Color','k','LineStyle','--');


% run_analysis.m to eventAnalysis(); with linear freqList and stop...
h2 = subplot(212);
imagesc(freqList,t,squeeze(eventScalograms(3,:,:))');
ylim([-1 1]);
colormap(jet);
caxis([0 350]);
xlim([1 80]);
xlabel('Freq (Hz)');
ylabel('Time (s)');
title('R0117 20160504a ch108 - Center Out');
xticks(xTickVals);
line([markBeta(1) markBeta(1)],[-1 1],'Color','k','LineStyle','--','linewidth',2);
line([markBeta(2) markBeta(2)],[-1 1],'Color','k','LineStyle','--','linewidth',2);
yticks([-1 0 1]);

tightfig;
set(gcf,'color','w');