iEvent = 3;
ff(800,300);
phaseMap = cmocean('phase');
            
subplot(231);
data1 = angle(squeeze(W(3,:,:)))';
imagesc(data1);
colormap(gca,phaseMap);
caxis([-pi pi]);
title('orig');

subplot(232);
data2 = angle(squeeze(W_before(3,:,:)))';
imagesc(data1);
colormap(gca,phaseMap);
caxis([-pi pi]);
title('0 before');

subplot(233);
data3 = angle(squeeze(W_after(3,:,:)))';
imagesc(data3);
colormap(gca,phaseMap);
caxis([-pi pi]);
title('0 after');
cbAside(gca,'phase','k')

subplot(234);
imagesc(data1-data1);
colormap(gca,phaseMap);
caxis([-pi pi]);
title('orig - orig');

subplot(235);
imagesc(data1-data2);
colormap(gca,phaseMap);
caxis([-pi pi]);
title('orig - before');

subplot(236);
imagesc(data1-data3);
colormap(gca,phaseMap);
caxis([-pi pi]);
title('orig - after');
cbAside(gca,'phase','k')