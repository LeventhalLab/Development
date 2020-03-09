folders = {'/Users/matt/Downloads/R0088_20151030a-selected',...
    '/Users/matt/Downloads/R0088_20151030a-selected 3'};
plotSec = 3;
[b,a] = butter(4, [0.05 0.5]);
close all;
ff(600,600);
for iTet = 1:2
    filelist = dir(fullfile(folders{iTet},'*.sev'));
    subplot(2,1,iTet);
    for iFile = 1:numel(filelist)
        [sev,header] = read_tdt_sev(fullfile(filelist(iFile).folder,filelist(iFile).name));
        plot_s = round(header.Fs * plotSec);
        t = linspace(0,plotSec,plot_s);
        plot(t,filtfilt(b,a,double(sev(1:plot_s))),'linewidth',1.5);
        hold on;
    end

    for iUnit = 1:5
        ts = nexStruct.neurons{iUnit,1}.timestamps;
        ii = 1;
        while(ts(ii) < plotSec)
            plot(ts(ii),iUnit*-100,'rx','markerSize',15);
            ii = ii + 1;
        end
    end

    xlim([2.466 2.476]);
    ylim([-400 200]);
end