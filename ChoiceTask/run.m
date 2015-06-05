filename = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0075/R0075-processed/R0075_20150518a/R0075_20150518a_T05_WL48_PL16_DT24-03-hs.nex';
tsCell = leventhalNexTs(filename);
ts = tsCell{1,2};
[burstEpochs,burstFreqs] = findBursts(ts);
highBursts = burstEpochs(burstFreqs > 200,1);
