figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';

h = ff(800,800);
for ii = 1:4
    subplot(2,2,ii);
    plot(rand(10));
    grid on;
end

tightfig;
setFig('','',[1.5,1.5]);
print(gcf,'-painters','-depsc',fullfile(figPath,['TEST.eps']));