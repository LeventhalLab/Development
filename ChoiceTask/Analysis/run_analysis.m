% analysisConf = exportAnalysisConf('R0117',nasPath);
% analysisConf = 
%            ratID: 'R0117'
%          nasPath: '/Volumes/RecordingsLeventhal2/ChoiceTask'
%          neurons: {'R0117_20160503a_T23_a'}
%     sessionNames: {'R0117_20160503a'}

% create R0XXX-analysis

[burstEventData,lfpEventData,t,freqList,eventFieldnames,correctTrialCount,scalogramWindow] = ...
    eventTriggeredAnalysis(analysisConf);