close all
h = ff(800,300);
rows = 1;
cols = 2;
nShow = 200;
x = [];
for iSurr = 1:nShow+1
   subplot(rows,cols,1);
   data =  squeeze(entrain_rs(iSurr,1,dirUnits{iDir},6));
   x(iSurr) = nanmean(data);
   plot(data);
   hold on;
end
subplot(rows,cols,2);
bar(x);