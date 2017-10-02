validIdx = allTrial_useTime > .05;
rt = allTrial_useTime(validIdx)'; % RT
mt = allTrial_useTime2(validIdx)'; % MT
% z = abs(allTrial_z(validIdx,:));
z = allTrial_z(validIdx,:);

doplot1 = true;

zcumsum = NaN(numel(rt),size(z,2));
nColors = 100;
rtmt_idx = linspace(min(rt+mt),1,nColors);
% rtmt_idx = linspace(min(mt)-.01,max(mt)+.01,nColors);
colors = jet(nColors);
last_zcumsum = [];
all_rtmt = [];
if doplot1
    figuree(800,800);
end
for iTrial = 1:numel(rt)
    rtmt = rt(iTrial) + mt(iTrial);
    all_rtmt(iTrial) = rtmt; % this is just rt + mt, doesn't need loop
    rtBin = round(rt(iTrial) / binS);
    rtmtBins = round(rtmt / binS);
    cur_zcumsum = cumsum(z(iTrial,(size(z,2)/2):(size(z,2)/2)+rtmtBins))-z(iTrial,(size(z,2)/2));
    zcumsum(iTrial,1:numel(cur_zcumsum)) = cur_zcumsum;
    last_zcumsum(iTrial) = cur_zcumsum(end);
    color_idx = find(rtmt_idx > rtmt,1);
    if doplot1
        plot(zcumsum(iTrial,:),'color',[colors(color_idx,:),0.25],'lineWidth',0.25);
        hold on;
        plot([rtBin],[zcumsum(iTrial,rtBin)],'.','color',[colors(color_idx,:),0.25],'markerSize',5);
    end
end
if doplot1
    colorbar;
    colormap jet;
    title('colored by mt only mtbins');
end

figure;
subplot(311);
% [v,k] = sort(all_rtmt);
% last_zcumsum_sorted = last_zcumsum(k);
plot(all_rtmt,last_zcumsum,'.');

subplot(312);
plot(rt,last_zcumsum,'.');

subplot(313);
plot(mt,last_zcumsum,'.');