function savePDF(h,leventhalPaths,subFolder,docName)
% set(h,'PaperOrientation','landscape');
% set(h,'PaperUnits','normalized');
% set(h,'PaperPosition', [.05 .05 .9 .9]);

newDir = fullfile(leventhalPaths.analysis,subFolder);
if ~exist(newDir,'dir')
    mkdir(newDir);
end
% use transparency for overlaying later
% pdftk f2.pdf background f1.pdf output text.pdf
export_fig(h,fullfile(leventhalPaths.analysis,subFolder,docName),'-pdf','-transparent','-nocrop');
% !/usr/local/bin/pdftk f1.pdf background bkgd.pdf output text.pdf
close(h);