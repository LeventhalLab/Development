% analysisConf = exportAnalysisConf('R0117',nasPath);

[burstEventData,lfpEventData,t,freqList,eventFieldnames,correctTrialCount,scalogramWindow] = ...
    lfpBurtsZEventAnalysis(analysisConf)