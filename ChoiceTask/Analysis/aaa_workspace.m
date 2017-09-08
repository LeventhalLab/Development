eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
tWindow = 1;
binMs = 20;
trialTypes = {'correct'};
useEvents = 1:7;
useTiming = {};

[unitEvents,all_zscores,unitClasses] = classifyUnitsToEvents(analysisConf,all_trials,all_ts,eventFieldnames,tWindow,binMs,trialTypes,useEvents,useTiming);