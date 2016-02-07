t = linspace(-1,1,length(488:488*3));
betaIdx = (freqList >= 13 & freqList <= 30);
allBetaPower = [];
figure;
for ii=1:size(W,2)
    realW = squeeze(mean(abs(W(:,ii,:)).^2,2))';
    betaPower = mean(realW(betaIdx,488:488*3),1);
    if mean(betaPower) < 1e4
        allBetaPower(ii,:) = betaPower;
        hold on;
        plot(t,betaPower);
    end
end

hold on;
plot(t,mean(allBetaPower,1),'LineWidth',5);
ylim([0 2*max(mean(allBetaPower,1))]);