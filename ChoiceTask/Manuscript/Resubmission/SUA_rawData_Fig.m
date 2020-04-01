doSave = true;
figPath = '/Users/matt/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.03 .01];

if ~exist('nexStruct','var')
    load('~/Downloads/R0088_20151030a.nex.mat');
end
folders = {'/Users/matt/Downloads/R0088_20151030a-selected',...
    '/Users/matt/Downloads/R0088_20151030a-selected 3'};
plotSec = 3;
[b,a] = butter(4, [0.016 0.16]); % 200Hz-2kHz

close all;
h = ff(600,300);
for iTet = 1:2
    filelist = dir(fullfile(folders{iTet},'*.sev'));
    subplot_tight(2,1,iTet,subplotMargins);
    for iFile = 1:numel(filelist)
        [sev,header] = read_tdt_sev(fullfile(filelist(iFile).folder,filelist(iFile).name));
        plot_s = round(header.Fs * plotSec);
        t = linspace(0,plotSec,plot_s);
        plot(t,filtfilt(b,a,double(sev(1:plot_s))),'linewidth',1.5);
        hold on;
    end
    if ~doSave
        for iUnit = 1:5
            ts = nexStruct.neurons{iUnit,1}.timestamps;
            ii = 1;
            while(ts(ii) < plotSec)
                plot(ts(ii),iUnit*-100,'rx','markerSize',15);
                ii = ii + 1;
            end
        end
    end
    xl1 = 2.8851;
    xl2 = 2.9662;
    xlimvals = [xl2, xl2 + 0.01];
    xlim(xlimvals);
    ylim([-400 200]);
    yticks(sort([0,ylim]));
    xticks(xlimvals);
    xticklabels([]);
    yticklabels([]);
    box off;
end

tightfig;
setFig('','',[1,1.5]);
if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'SUA_rawData.eps'));
    close(h);
end