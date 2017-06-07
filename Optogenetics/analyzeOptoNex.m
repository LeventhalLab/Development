function [pulse_binary,pulse_ts] = analyzeOptoNex(ephysData,laserData,nexFile,Fs,dosteps,protocol,useUnits)

% % dosteps = [1,2];
% % protocol = 1; % 1 = long, 2 = short, 3 = custom
% % useUnits = [2];

if protocol == 1
    pethWindow = 5; % seconds
    pethBinWidth = 250; % ms
    minResetTime = 1; % seconds
elseif protocol == 2
    pethWindow = .01; % seconds
    pethBinWidth = .5; % ms
    minResetTime = 0; % seconds
else
    % custom
end

% reference; for use in protocol 2
pulseBreaks = 251:251:2510;

if ismember(1,dosteps)
    h1 = figure('position',[0 0 1100 500]);
    plot(laserData);
    xlabel('time (s)');
    disp('Click once at start, once at end...');
    [startStop,~] = ginput(2);
    close(h1);
    % remove data outside startStop
    laserData(1:round(startStop(1))) = 0;
    laserData(round(startStop(2)):end) = 0;

    [pulse_binary,pulse_ts] = extractLaserProtocol(laserData,Fs,minResetTime);
end

if ismember(2,dosteps)
    [nvar, names, types, freq] = nex_info(nexFile);

    pethBins = -pethWindow:pethBinWidth/1000:pethWindow;
    binEdge = mean(diff(pethBins)) / 2;
    for iUnit = 1:size(names,1)
        if ~isempty(useUnits)
            if ~ismember(iUnit,useUnits)
                continue;
            end
        end
        unitName = deblank(names(iUnit,:));
        [~,fileName,~] = fileparts(nexFile);
        [n, ts] = nex_ts(nexFile, unitName);
        if numel(ts) < 10
            disp(['Only ',num2str(numel(ts)),' units; skipping...']);
            continue;
        end

        figure('position',[100 100 1100 500]);
        ephysData_norm = normalize(ephysData);
        plot(linspace(0,numel(ephysData)/Fs,numel(ephysData)),ephysData_norm);
        hold on;
        plot(linspace(0,numel(laserData)/Fs,numel(laserData)),normalize(laserData));
        plot(ts,ephysData_norm(round(ts*Fs)),'kx');
        legend('raw data','laser','spike');
        xlabel('time (s)');
        ylabel('normalized units');
        title({fileName,unitName,[num2str(numel(pulse_ts)),' pulses']},'interpreter','none');

        figure;
        [counts,centers] = hist(ts,[0:1:round(numel(ephysData)/Fs)]);
        bar(centers,counts);
        title({fileName,unitName,'Session FR'},'interpreter','none');
        xlabel('time (s)');
        ylabel('spikes/sec');
        xlim([0 max(ts)]);

        % surrogate timestamps (i.e. random)
        sur_ts = [];
        for ii = 1:numel(ts)
            sur_ts(ii) = ts(ii) + rand(1)*10;
        end
        
        all_tsPeth = {};
%         sortArr = []; % not used right now
        for iPulse = 1:numel(pulse_ts)
%             ts_shift = sur_ts - pulse_ts(iPulse);
            ts_shift = ts - pulse_ts(iPulse);
            ts_window = ts_shift(ts_shift >= -pethWindow - binEdge & ts_shift < pethWindow + binEdge);
            all_tsPeth{iPulse} = ts_window;
%             sortArr(iPulse) = std(diff(ts_window));
        end
%         [v,k] = sort(sortArr);
        figure;
        plotSpikeRaster(all_tsPeth,'PlotType','scatter');
        xlim([-pethWindow pethWindow]);
        xlabel('time (s)');
        ylabel('pulse');
        title({fileName,unitName,[num2str(numel(pulse_ts)),' pulses']},'interpreter','none');
        hold on;
        for ii = 1:numel(pulseBreaks)
            plot([-pethWindow pethWindow],[pulseBreaks(ii) pulseBreaks(ii)],'--r');
        end
        
        figure('position',[0 0 600 600]);
        [counts,centers] = hist([all_tsPeth{:}],pethBins);
        fr = ((1/(pethBinWidth/1000)) * counts) / numel(pulse_ts);
        maxy = max(fr)+3;
        x = [0 pethWindow pethWindow 0];
        y = [0 0 maxy maxy];
        patch(x,y,[82/255 148/255 247/255],'EdgeColor','none','FaceAlpha',1);
        y = [0 0 maxy-1 maxy-1];
        patch(x,y,[170/255 203/255 251/255],'EdgeColor','none','FaceAlpha',1);
        hold on;
        bar(centers,fr,'k');
        xlim([-pethWindow pethWindow]);
        xlabel('Time (s)');
        ylabel('Spikes/Sec');
        title({fileName,unitName,[num2str(numel(pulse_ts)),' pulses']},'interpreter','none');
    end
end