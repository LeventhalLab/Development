function burstEventAnalysis_plot(sessionConf)

burstFiles = rdir(fullfile(sessionConf.nasPath,sessionConf.ratID,[sessionConf.ratID,'-graphs'],'*','burstEventAnalysis','*burstEvents.mat'));

for ii=1:length(burstFiles)
    load(burstFiles(ii).name);
    if mod(ii,7) == 1
        h = formatSheet();
    end
    
    for iEvent=[1 2 3 4 5 6 8];
        subplot(7,7,ii*mod(ii,7));
    end
end