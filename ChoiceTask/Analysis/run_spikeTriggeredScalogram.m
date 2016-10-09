% length(ts) > ~1000?


[allW,allScaloData,allSpans,s,freqList] = spikeTriggeredScalogram(ts,sevFile);

set(gca,'YScale','log');
set(gca,'Ytick',round(exp(linspace(log(min(freqList)),log(max(freqList)),5))));
colormap(jet);
caxis([0 500]);
title(spanLabels{iSpan});