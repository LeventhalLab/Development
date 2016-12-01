function savePDF(h,leventhalPaths,subFolder,docName)
% set(h,'PaperOrientation','landscape');
% set(h,'PaperUnits','normalized');
% set(h,'PaperPosition', [.05 .05 .9 .9]);

newDir = fullfile(leventhalPaths.analysis,subFolder);
if ~exist(newDir,'dir')
    mkdir(newDir);
end
% use transparency for overlaying later
export_fig(h,fullfile(leventhalPaths.analysis,subFolder,docName),'-pdf','-transparent','-nocrop');
close(h);