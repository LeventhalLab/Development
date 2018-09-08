function [sevDespiked,header] = despikeLFP(sev,header,ts)
doDebug = true;
ts_samples = round(ts*header.Fs);

testWindow = 0.005;
nSamples = round(testWindow * header.Fs);
nSpikes = 10000;
randSamples = ts_samples(1:nSpikes);
spikeArr = [];
for iSpike = 1:nSpikes
    spikeArr(:,iSpike) = sev(randSamples(iSpike) - nSamples:randSamples(iSpike) + nSamples - 1);
    spikeArr(:,iSpike) = spikeArr(:,iSpike) - mean(spikeArr(:,iSpike));
end
mspike = mean(spikeArr,2);
mspike_ad = smooth(abs(mspike),5);
spikeids = find(mspike_ad > mean(mspike_ad(1:round(nSamples/4))) * 5);
xs = [];
xs(1) = spikeids(1);
xs(2) = spikeids(end);
xs = xs - nSamples;

if doDebug
    x = (1:nSamples*2)-nSamples-1;
    figure;
    plot(x,mspike,'linewidth',2); hold on;
    plot(x,mspike_ad,'k');
    plot([xs(1) xs(1)],ylim,'r');
    plot([xs(2) xs(2)],ylim,'r');
    xlim([x(1) x(end)]);
    legend('spike','abs(spike)');
end

% % h = figure;
% % yyaxis left;
% % plot(x,spikeArr,'-','color',repmat(0.7,[1,4]),'linewidth',0.5);
% % yyaxis right;
% % plot(x,mean(spikeArr,2),'k-','lineWidth',2);
% % xlim([min(x),max(x)]);
% % xlabel('samples');
% % title([num2str(showSamples),' spikes +/- ',num2str(testWindow*1000),'ms']);
% % disp('Select the start and end of the spike...');
% % [xs,~] = ginput(2);
% % xs = round(xs);
% % close(h);

f = waitbar(0,'setting up inerpolation...');
sevNaN = double(sev);
for iSpike = 1:5000%numel(ts)
    sevNaN(ts_samples(iSpike)+xs(1):ts_samples(iSpike)+xs(2)) = NaN;
    waitbar(iSpike/numel(ts),f);
end
waitbar(1,f,'interpolating...');
v = 1:numel(sevNaN);
xq = v;
v = v(~isnan(sevNaN));
sevNaN = sevNaN(~isnan(sevNaN));
sevDespiked = interp1(v,sevNaN,xq,'linear');
close(f);

if doDebug
    showSec = 0.5;
    sevSnip = double(sev(1:round(header.Fs*showSec)));
    sevNaN_interpSnip = double(sevDespiked(1:round(header.Fs*showSec)));

    figuree(1000,300);
    plot(sevSnip);
    hold on;
    plot(sevNaN_interpSnip,'-k');

    tsSnip = ts(ts < showSec);
    tsSnip_samp = round(tsSnip * header.Fs);
    plot(tsSnip_samp,sevSnip(tsSnip_samp),'rx');
    xlim([1 numel(sevSnip)]);
    title([num2str(showSec),'s snip of data']);
    legend('original','despiked');
end
