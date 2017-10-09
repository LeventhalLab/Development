% validIdx = allTrial_useTime;
useTime = allTrial_useTime'; % RT
% % mt = allTrial_useTime2(validIdx)'; % MT
% z = abs(allTrial_z(validIdx,:));
z = allTrial_z;

doplot1 = true;

zcumsum = NaN(numel(useTime),size(z,2));
nColors = numel(meanBinsSeconds);
% rtmt_idx = linspace(0,1,);
% rtmt_idx = linspace(min(mt)-.01,max(mt)+.01,nColors);
colors = jet(nColors);
last_zcumsum = [];
all_rtmt = [];
if doplot1
    figuree(800,800);
end
for iTrial = 1:numel(useTime)
    rtmt = useTime(iTrial);
    all_rtmt(iTrial) = rtmt; % this is just rt + mt, doesn't need loop
    useTime_bin = round(size(z,2) / 2) + (round(rtmt / binS) + 1);
% %     rtmtBins = round(rtmt / binS);
    mid_cumsum = cumsum(z(iTrial,1:round(size(z,2) / 2)));
    cur_zcumsum = cumsum(z(iTrial,:)) - mid_cumsum(end);
    zcumsum(iTrial,1:numel(cur_zcumsum)) = cur_zcumsum;
    last_zcumsum(iTrial) = cur_zcumsum(useTime_bin);
%     color_idx = find(rtmt_idx > rtmt,1);
    color_idx = closest(meanBinsSeconds,rtmt);
    if doplot1
        plot(zcumsum(iTrial,:),'color',[colors(color_idx,:),0.25],'lineWidth',0.25);
        hold on;
        plot([useTime_bin],[zcumsum(iTrial,useTime_bin)],'.','color',[colors(color_idx,:),0.2],'markerSize',10);
    end
end
if doplot1
    cb = colorbar('h');
    colormap jet;
    set(cb,'Ticks',linspace(0,1,numel(meanBinsSeconds)));
    set(cb,'TickLabels',cellstr(num2str(meanBinsSeconds(:),'%1.2f')));
    title('tone units at nose out by MT');
    ylim([-150 150]);
    xlim([1 size(z,2)]);
    xticks([1 round(size(z,2)/2) size(z,2)]);
    xticklabels({'-1','0','1'});
    xlabel('time (s)');
    ylabel('cumulative Z');
    set(gcf,'color','w')
end

figure;
subplot(211);
% [v,k] = sort(all_rtmt);
% last_zcumsum_sorted = last_zcumsum(k);
plot(all_rtmt,last_zcumsum,'.');

subplot(212);
plot(useTime,last_zcumsum,'.');

% subplot(313);
% plot(mt,last_zcumsum,'.');

figure;
colors = cool(size(mean_z,1));
for ii = 1:numel(mean_z)
    plot(cumsum(mean_z(ii,:)),'color',colors(ii,:));
    hold on;
end