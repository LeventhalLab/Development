function savePDF(h,leventhalPaths,subFolder,docName,headerSpace)
newDir = fullfile(leventhalPaths.analysis,subFolder);
if ~exist(newDir,'dir')
    mkdir(newDir);
end
set(gca,'color','none');
% use transparency for overlaying later
if headerSpace
    % should probably not use pixels, but it works for now
    fp = fillPage(h,'margins',[0 0 2 0],'papersize',[11 9.5]);
    print(h,'-painters','-dpdf','-r600',fullfile(leventhalPaths.analysis,subFolder,docName));
else
    fp = fillPage(h,'margins',[0 0 0 0],'papersize',[11 11.5]);
    print(h,'-painters','-dpdf','-r600',fullfile(leventhalPaths.analysis,subFolder,docName));
end

close(h);