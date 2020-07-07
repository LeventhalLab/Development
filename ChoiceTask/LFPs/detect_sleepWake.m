% The optimal algorithm reached after analysis of the 17 records was:
% D = .025 x [(.15T(i - 4) + .15T(i - 3) + .15T(i - 2) + .08T(i - 1) + .21T(i) + .12T(i + 1) + .13T(i + 2)]
% where T(i) represents the maximal epoch value in minute i, etc. If D >= 1.0, the minute was scored wake;
% otherwise it was scored sleep.

odba = T.odba(1:86400*5);
odba_m = movmax(odba,60*2);
nR = 5:numel(odba)-2;

im = zeros(numel(nR),7);
im(:,1) = 0.15 * odba_m(nR-4);
im(:,2) = 0.15 * odba_m(nR-3);
im(:,3) = 0.15 * odba_m(nR-2);
im(:,4) = 0.08 * odba_m(nR-1);
im(:,5) = 0.21 * odba_m(nR);
im(:,6) = 0.21 * odba_m(nR+1);
im(:,7) = 0.21 * odba_m(nR+2);

W = 0.5 * sum(im,2);
Db = zeros(numel(nR),1);
Db(W >= 1) = 1;

close all

ff(1200,800);
showAmt = 3600*4;
xlims = [1,numel(odba);10000,10000+showAmt;50000,50000+showAmt];
titles = {'Several Days','Night Snippet','Day Snippet'};
colors = lines(3);
for ii = 1:4
    if ii == 1
        subplot(2,2,[1,2]);
        xlimVal = xlims(ii,:);
        useTitle = titles{1};
    elseif ii == 2
        continue;
    else
        subplot(2,2,ii);
        xlimVal = xlims(ii-1,:);
        useTitle = titles{ii-1};
    end
    plot(odba,'-','color',[0 0 0 0.1]);
    hold on;
    plot(odba_m,'k-');
    ylabel('ODBA');
    ylim([0 16]);
    yyaxis right;
    plot(W,'-','color',colors(3,:));
    hold on;
    plot(Db,'-','color','r');
    ylabel('Webster classifier (W)');
    xlim(xlimVal);
    ylim([0 10]);
    xlabel('time (s)');
    legend('odba','mov max','raw W','bin W');
    title(useTitle);
end