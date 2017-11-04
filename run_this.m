sessionConf = exportSessionConfv2('R0140_20161022a','nasPath',nasPath);
nexData = TDTtoNex(sessionConf);

sessionConf = exportSessionConfv2('R0140_20161024a','nasPath',nasPath);
nexData = TDTtoNex(sessionConf);

sessionConf = exportSessionConfv2('R0140_20161025a','nasPath',nasPath);
nexData = TDTtoNex(sessionConf);

sessionConf = exportSessionConfv2('R0140_20161026a','nasPath',nasPath);
nexData = TDTtoNex(sessionConf);

sessionConf = exportSessionConfv2('R0140_20161028a','nasPath',nasPath);
nexData = TDTtoNex(sessionConf);

sessionConf = exportSessionConfv2('R0140_20161029a','nasPath',nasPath);
nexData = TDTtoNex(sessionConf);

sessionConf = exportSessionConfv2('R0140_20161030a','nasPath',nasPath);
nexData = TDTtoNex(sessionConf);

sessionConf = exportSessionConfv2('R0140_20161031a','nasPath',nasPath);
nexData = TDTtoNex(sessionConf);


processedPath = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0140/R0140-processed';
combineSessionNex_wf(processedPath);