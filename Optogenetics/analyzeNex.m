dosteps = [2];

if ismember(1,dosteps)
    sev_laserFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-acute/R0181_20170525_cylinder/R0181_20170525c_cylinder-2/R0181_20170525c_cylinder_R0181_20170525c_cylinder-2_data_ch65.sev';
    sev_laserFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-acute/R0181_20170525_cylinder/R0181_20170525c_cylinder-1/R0181_20170525c_cylinder_R0181_20170525c_cylinder-1_data_ch65.sev';
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

    minResetTime = 0; % seconds
    [pulse_binary,pulse_ts] = extractLaserProtocol(sev_laser,header,minResetTime);

    figure('position',[0 0 1100 500]);
    plot(normalize(sev_laser));
    hold on;
    plot(pulse_binary);
end

if ismember(2,dosteps)
    % start NEX analysis
    dodebug = true;
    if dodebug
        sevFile_data = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-acute/R0181_20170525_cylinder/R0181_20170525c_cylinder-2/R0181_20170525c_cylinder_R0181_20170525c_cylinder-2_data_ch49.sev';
        sevFile_data = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-acute/R0181_20170525_cylinder/R0181_20170525c_cylinder-1/R0181_20170525c_cylinder_R0181_20170525c_cylinder-1_data_ch49.sev';
        [sev_data,header] = read_tdt_sev(sevFile_data);
    end
    nexFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-acute/R0181_20170525_cylinder/R0181_20170525c_cylinder_R0181_20170525c_cylinder-2_data_ch49-quick.nex';
    nexFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-acute/R0181_20170525_cylinder/R0181_20170525c_cylinder_R0181_20170525c_cylinder-1_data_ch49.nex';
    
%     nexFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-acute/R0181_20170524_cylinder/R0181_20170524_cylinder-5/R0181_20170524_cylinder_R0181_20170524_cylinder-5_data_ch3.nex';
    [nvar, names, types, freq] = nex_info(nexFile);

    pethWindow = .05; % seconds
    pethBinWidth = 2; % ms
    pethBins = -pethWindow:pethBinWidth/1000:pethWindow;
    binEdge = mean(diff(pethBins)) / 2;
    for iUnit = 1:size(names)
        unitName = deblank(names(iUnit,:));
        [n, ts] = nex_ts(nexFile, unitName);
        % remove all ts out of range
%         ts = ts(ts >= startStop(1)*header.Fs & ts < startStop(2)*header.Fs);
        if dodebug
            figure('position',[100 100 1100 500]);
            plot(linspace(0,numel(sev_data)/header.Fs,numel(sev_data)),normalize(sev_data));
            hold on;
            sev_data_norm = normalize(sev_data);
            plot(linspace(0,numel(sev_data)/header.Fs,numel(sev_data)),sev_data_norm);
            plot(ts,sev_data_norm(round(ts*header.Fs)),'kx');
            
            figure;
            [counts,centers] = hist(ts,[0:1:max(ts)]);
            bar(centers,counts);
            title('Session FR');
            xlabel('time (s)');
            ylabel('spikes/sec');
            xlim([0 max(ts)]);
        end

        all_tsPeth = [];
        for iPulse = 1:numel(pulse_ts)
            ts_shift = ts - pulse_ts(iPulse);
            ts_window = ts_shift(ts_shift >= -pethWindow - binEdge & ts_shift < pethWindow + binEdge);
            all_tsPeth = [all_tsPeth ts_window];
        end
        figure('position',[0 0 600 600]);
        [counts,centers] = hist(all_tsPeth,pethBins);
        fr = ((1/(pethBinWidth/1000)) * counts) / numel(pulse_ts);
        bar(centers,fr,'k');
        xlim([-pethWindow pethWindow]);
        xlabel('time (s), pulse = 0');
        ylabel('spikes/sec');
        title({unitName,[num2str(numel(pulse_ts)),' pulses']});
    end
end