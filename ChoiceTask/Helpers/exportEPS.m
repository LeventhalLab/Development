function exportEPS(h,savePath,figureName)
print(h,'-painters','-depsc',fullfile(savePath,[figureName,'.eps']));