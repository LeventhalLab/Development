% [sev,header] = ezSEV();
% sevDec = decimate(double(sev),10);

movingwin = [0.5 0.05];
params.tapers=[5 9];
params.Fs = header.Fs/10;
params.fpass = [10 45];
params.trialave = 1;
params.err = 0;

[S1,t,f] = mtspecgramc(sevDec(1:1e5),movingwin,params);

figure;
plot_matrix(S1,t,f);
colorbar;
colormap(jet);

% hold on;
% for ii=1:length(combinedNex.events{7,1}.timestamps)
%     x = combinedNex.events{7,1}.timestamps(ii);
%     line([x x],[0 100],'color','k','lineStyle','--','lineWidth',1);
% end
%load combinedNex

