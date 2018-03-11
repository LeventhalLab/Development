function rescale_y(rows,cols,subplot_ps,all_ylims)
yVals = [min(all_ylims(:)) max(all_ylims(:))];

for iSubplot = 1:numel(subplot_ps)
    p = subplot_ps(iSubplot);
    subplot(rows,cols,p);
    yyaxis left;
    ylim(yVals);
    yticks(unique(sort([yVals 0])));
end