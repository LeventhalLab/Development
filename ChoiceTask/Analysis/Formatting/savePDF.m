function savePDF(h,leventhalPaths,subFolder,docName,headerSpace)
newDir = fullfile(leventhalPaths.analysis,subFolder);
if ~exist(newDir,'dir')
    mkdir(newDir);
end
% use transparency for overlaying later
if headerSpace
    % should probably not use pixels, but it works for now
    set(h,'position',[0 0 1100 800]); % maybe problematic for certain figure types
    export_fig(h,fullfile(leventhalPaths.analysis,subFolder,docName),'-pdf','-transparent','-p.3','-c[0 200 200 200]');
else
    export_fig(h,fullfile(leventhalPaths.analysis,subFolder,docName),'-pdf','-transparent','-nocrop');
end

close(h);