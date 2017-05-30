% close all;

dosteps = [2];
pethWindow = .02; % seconds
pethBinWidth = 1; % ms
minResetTime = 0; % seconds
useUnits = [1,2];
pulseBreaks = 251:251:2510;

if ismember(1,dosteps)
%     sev_laserFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-2/R0181_20170525c_cylinder_R0181_20170525c_cylinder-2_data_ch65.sev';
    sev_laserFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-1/R0181_20170525c_cylinder_R0181_20170525c_cylinder-1_data_ch65.sev';
    [sev_laser,header] = read_tdt_sev(sev_laserFile);
    
    h1 = figure('position',[0 0 1100 500]);
    plot(sev_laser);
    xlabel('time (s)');
    disp('Click once at start, once at end...');
    [startStop,~] = ginput(2);
    close(h1);
    % remove data outside startStop
    sev_laser(1:round(startStop(1))) = 0;
    sev_laser(round(startStop(2)):end) = 0;

    [pulse_binary,pulse_ts] = extractLaserProtocol(sev_laser,header,minResetTime);
end

if ismember(2,dosteps)
    % start NEX analysis
    dodebug = true;
    if dodebug
%         sevFile_data = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-2/R0181_20170525c_cylinder_R0181_20170525c_cylinder-2_data_ch49.sev';
        sevFile_data = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-1/R0181_20170525c_cylinder_R0181_20170525c_cylinder-1_data_ch49.sev';
        [sev_data,header] = read_tdt_sev(sevFile_data);
    end
%     nexFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-2/R0181_20170525c_cylinder_R0181_20170525c_cylinder-2_data_ch49.nex';
    nexFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-1/R0181_20170525c_cylinder_R0181_20170525c_cylinder-1_data_ch49-01-mg.nex';
    
    [nvar, names, types, freq] = nex_info(nexFile);

    pethBins = -pethWindow:pethBinWidth/1000:pethWindow;
    binEdge = mean(diff(pethBins)) / 2;
    for iUnit = useUnits
        unitName = deblank(names(iUnit,:));
        [n, ts] = nex_ts(nexFile, unitName);
        % remove all ts out of range
%         ts = ts(ts >= startStop(1)*header.Fs & ts < startStop(2)*header.Fs);
        if dodebug
            figure('position',[100 100 1100 500]);
            sev_data_norm = normalize(sev_data);
            plot(linspace(0,numel(sev_data)/header.Fs,numel(sev_data)),sev_data_norm);
            hold on;
            plot(linspace(0,numel(sev_laser)/header.Fs,numel(sev_laser)),normalize(sev_laser));
            plot(ts,sev_data_norm(round(ts*header.Fs)),'kx');
            legend('raw data','laser','spike');
            xlabel('time (s)');
            ylabel('normalized units');
            title({unitName,[num2str(numel(pulse_ts)),' pulses']});
            
            figure;
            [counts,centers] = hist(ts,[0:1:round(numel(sev_data)/header.Fs)]);
            bar(centers,counts);
            title([unitName,' Session FR']);
            xlabel('time (s)');
            ylabel('spikes/sec');
            xlim([0 max(ts)]);
        end

        all_tsPeth = {};
        sortArr = [];
        for iPulse = 1:numel(pulse_ts)
            ts_shift = ts - pulse_ts(iPulse);
%             ts_window = ts(ts > pulse_ts(iPulse) - pethWindow - binEdge & ts < pulse_ts(iPulse) + pethWindow + binEdge) - pulse_ts(iPulse);
            ts_window = ts_shift(ts_shift >= -pethWindow - binEdge & ts_shift < pethWindow + binEdge);
            all_tsPeth{iPulse} = ts_window;
            sortArr(iPulse) = std(diff(ts_window));
        end
% %         [v,k] = sort(sortArr);
        figure;
        plotSpikeRaster(all_tsPeth,'PlotType','scatter');
        xlimVals = xlim;
        xlabel('time (s)');
        ylabel('pulse');
        title({unitName,[num2str(numel(pulse_ts)),' pulses']});
        hold on;
        for ii = 1:numel(pulseBreaks)
            plot(xlimVals,[pulseBreaks(ii) pulseBreaks(ii)],'--r');
        end
        
        figure('position',[0 0 600 600]);
        [counts,centers] = hist([all_tsPeth{:}],pethBins);
        fr = ((1/(pethBinWidth/1000)) * counts) / numel(pulse_ts);
        bar(centers,fr,'k');
        xlim([-pethWindow pethWindow]);
        xlabel('time (s), pulse = 0');
        ylabel('spikes/sec');
        title({unitName,[num2str(numel(pulse_ts)),' pulses']});
    end
end