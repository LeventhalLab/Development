ts = ts_c;

SEVfilename = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch33.sev';
[meanWaveform, upperStd, lowerStd, ch, windowSize] = aveWaveform(ts, SEVfilename);
plotAveWaveform(meanWaveform, upperStd, lowerStd, ch, windowSize);

SEVfilename = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch35.sev';
[meanWaveform, upperStd, lowerStd, ch, windowSize] = aveWaveform(ts, SEVfilename);
plotAveWaveform(meanWaveform, upperStd, lowerStd, ch, windowSize);

SEVfilename = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch37.sev';
[meanWaveform, upperStd, lowerStd, ch, windowSize] = aveWaveform(ts, SEVfilename);
plotAveWaveform(meanWaveform, upperStd, lowerStd, ch, windowSize);

SEVfilename = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0088/R0088-rawdata/R0088_20151102a/R0088_20151102a/R0088_20151102_R0088_20151102-1_data_ch39.sev';
[meanWaveform, upperStd, lowerStd, ch, windowSize] = aveWaveform(ts, SEVfilename);
plotAveWaveform(meanWaveform, upperStd, lowerStd, ch, windowSize);