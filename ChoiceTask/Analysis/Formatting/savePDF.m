function savePDF(h,leventhalPaths,subFolder,docName)
set(h,'PaperOrientation','landscape');
set(h,'PaperUnits','normalized');
set(h,'PaperPosition', [0 0 1 1]);

mkdir(leventhalPaths.analysis,subFolder);
saveas(h,fullfile(leventhalPaths.analysis,subFolder,[docName,'.pdf']));
close(h);