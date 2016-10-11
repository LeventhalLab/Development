function savePDF(h,leventhalPaths,subFolder,docName)
set(h,'PaperOrientation','landscape');
set(h,'PaperUnits','normalized');
set(h,'PaperPosition', [0 0 1 1]);

newDir = fullfile(leventhalPaths.analysis,subFolder);
if ~exist(newDir,'dir')
    mkdir(newDir);
end
saveas(h,fullfile(leventhalPaths.analysis,subFolder,[docName,'.pdf']));
close(h);