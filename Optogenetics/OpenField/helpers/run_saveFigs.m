function run_saveFigs(figPath,saveFile,exts,doSave)

if doSave
    for iExt = 1:numel(exts)
        saveas(gcf,fullfile(figPath,[saveFile,'.',exts{iExt}]));
    end
    close(gcf);
end