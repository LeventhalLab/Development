plotRange = [-1,1];
tscalo = linspace(-tWindow,tWindow,size(eventScalograms,3));
tscaloIdx = find(tscalo >= plotRange(1) & tscalo <= plotRange(2));
tzIdx =  find(t >= plotRange(1) & t <= plotRange(2));

doplot = false;

for iEvent = 6%1:numel(eventFieldnames)
    scaloData = log(squeeze(eventScalograms(iEvent,:,:)));
    zscoreData = zscore(iEvent,tzIdx);
    interpFactor = ceil(numel(tscaloIdx) / numel(tzIdx));
    zscoreDataInterp = interp(zscoreData,interpFactor);
    zscoreDataInterp = zscoreDataInterp(1:numel(tscaloIdx)); % not zero-center adjusted, but close enough
    
    all_lag = [];
    all_acor = [];
    all_lagDiff = [];
    all_acorMax = [];
    lns = [];
    for iFreq = 1:numel(freqList)
        freqRow = scaloData(iFreq,tscaloIdx);
        [acor,lag] = xcorr(freqRow,zscoreDataInterp);
        [~,I] = max(abs(acor));
        lagDiff = lag(I);
        all_lag(iFreq,:) = lag;
        all_acor(iFreq,:) = acor;
        all_lagDiff(iFreq) = lagDiff;
        all_acorMax(iFreq) = max(acor);
        
        if doplot
            figure;
            lns(1) = plot(normalize(freqRow),'color','r','lineWidth',3);
            hold on;
            lns(2) = plot(zscoreDataInterp,'color','k','lineWidth',3);
            title([num2str(freqList(iFreq)),' Hz']);
            legend(lns,{'lfp','zsore'});

            figure;
            plot(lag,acor);
            a3 = gca;
            a3.XTick = sort([-3000:1000:3000 lagDiff]);
        end
    end
end

figuree(1100,800);
subplotIdxs = {[1:6],7,8,9};
subplotAz = [-30,0,0,90];
subplotEl = [30,0,90,0];
for iSubplot = 1:4
    subplot(3,3,subplotIdxs{iSubplot});
    mesh(lag,freqList,normalize(all_acor));
    xlabel('LFP Lag (s)');
    xticks([lag(1) 0 lag(end)]);
    xlim([lag(1) lag(end)]);
    xticklabels({num2str(plotRange(1)),'0',num2str(plotRange(2))});
    
    ylabel('Frequency (Hz)');
    ylim([freqList(1) freqList(end)]);
    
    zlabel('Acor (a.u.)');
    colormap(jet);
    if iSubplot == 1
        title(eventFieldnames{iEvent});
    end
    view(subplotAz(iSubplot),subplotEl(iSubplot));
end
set(gcf,'color','w');