function [sevDespiked,header] = despikeLFP(sevFile,ts,waveformBounds)
doDebug = false;
[sev,header] = read_tdt_sev(sevFile);
ts_samples = round(ts*header.Fs);

f = waitbar(0,'setting up inerpolation...');
sevNaN = double(sev);
for iSpike = 1:numel(ts)
    waitbar(iSpike/numel(ts),f);
    nanRange = ts_samples(iSpike)+waveformBounds(1):ts_samples(iSpike)+waveformBounds(2)-1;
    if nanRange(1) > 0 && nanRange(end) < numel(sevNaN)
        sevNaN(nanRange) = NaN;
    end
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