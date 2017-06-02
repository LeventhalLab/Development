h = gcf;
hd = findall(gcf,'type', 'axes');
for ii = 1:numel(hd)
    set(hd(ii),'fontSize',10);
    set(hd(ii),'fontName','Arial');
end
[pathstr, name, ext] = fileparts(h.FileName);

fp = fillPage(h,'margins',[0 0 0 0],'papersize',[5 4]); % [w,h]
print(h,'-painters','-dpdf','-r200',fullfile(pathstr,[name,'.pdf']));