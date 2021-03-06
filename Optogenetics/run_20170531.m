% nexFiles = {'/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-1/R0181_20170525c_cylinder_R0181_20170525c_cylinder-1_data_ch49.nex',...
%     '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-1/R0181_20170525c_cylinder_R0181_20170525c_cylinder-1_data_ch53.nex'};
% useUnits = {[2],[1]};

% ch49 from Offline Sorter
spikeWaveform = [0.853487191	1.605702596	1.800573878	1.87625502	1.988851402	2.118986199	2.262357536	2.474828513	2.602205698	2.733480308	4.185479712	8.699838416	15.04354822	16.95659591	7.157254506	-14.47587224	-37.27705009	-46.8586014	-37.39916943	-16.56147294	1.862944944	9.56555715	8.319214357	4.904456694	3.497375733	3.642597735	3.628454247	3.17353398	2.817618129	2.637049663	2.410778367	2.180989583];

nexFileDir = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-1';
% nexFiles = dir(fullfile(nexFileDir,'*[1  3  5  7].nex'));
nexFiles = dir(fullfile(nexFileDir,'*49.nex'));
useUnits = [2];

% nexFiles = dir(fullfile(nexFileDir,'*.nex'));
% useUnits = [];

saveDir = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-1/Analysis3';
dosave = false;

% setup
if false
    laserFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-1/R0181_20170525c_cylinder_R0181_20170525c_cylinder-1_data_ch65.sev';
    [laserData,header] = read_tdt_sev(laserFile);
    h1 = figure('position',[0 0 1100 500]);
    plot(laserData);
    xlabel('time (s)');
    disp('Click once at start, once at end...');
    [startStop,~] = ginput(2);
    close(h1);
    % remove data outside startStop
    laserData(1:round(startStop(1))) = 0;
    laserData(round(startStop(2)):end) = 0;
    [pulse_binary,pulse_ts] = extractLaserProtocol(laserData,header.Fs,0);
end

if true
    for iNex = 1:numel(nexFiles)
        nexFile = fullfile(nexFileDir,nexFiles(iNex).name);
        [nvar, names, types, freq] = nex_info(nexFile);
        for iUnit = 1:size(names,1)
            if ~isempty(useUnits) && ~ismember(iUnit,useUnits)
                continue;
            end
            unitName = deblank(names(iUnit,:))
            [~,fileName,~] = fileparts(nexFile);
            [n, ts] = nex_ts(nexFile, unitName);
            
            if false % Analysis 1
                nextSpikeDiff = [];
                nextSpikeDiffSurr = [];
                pulseCount = 1;
                a = pulse_ts(1);
                b = pulse_ts(end);
                for iPulse = 1:numel(pulse_ts)
                    % add up to 20 ms to each pulse_ts
                    pulseSurr = (b-a).*rand(1,1) + a;
                    nextSpikeSurr = ts(find(ts > pulseSurr,1));
                    pulse = pulse_ts(iPulse);
                    nextSpike = ts(find(ts > pulse,1));
                    if ~isempty(nextSpikeSurr) && ~isempty(nextSpike)
                        nextSpikeDiffSurr(pulseCount) = nextSpikeSurr - pulseSurr;
                        nextSpikeDiff(pulseCount) = nextSpike - pulse;
                        pulseCount = pulseCount + 1;
                    end
                end
                maxHistVal = .1; % seconds
                h1 = figure('position',[0 0 900 400]);
                ylimVals = [];
                for ii = 1:2
                    subplot(1,2,ii);
                    useData = nextSpikeDiff;
                    addTitle = '';
                    if ii == 2
                        useData = nextSpikeDiffSurr;
                        addTitle = ' SURROGATE';
                    end
                    [counts,centers] = hist(useData(useData <= maxHistVal),linspace(0,maxHistVal,20)); % 20 = 5ms, 50 = 2ms
                    bar(centers,counts,'k');
                    xlim([0 maxHistVal]);
                    xlabel('time (s)');
                    ylabel('spike count');
                    title({fileName,unitName,['Laser ON to next spike',addTitle],[num2str(numel(pulse_ts)),' pulses']},'interpreter','none');
                    grid on;
                    ylimAuto = ylim;
                    ylimVals(ii) = ylimAuto(2);
                    hold on;
                end
                for ii = 1:2
                    subplot(1,2,ii);
                    ylim([0 max(ylimVals)]);
                end
                if dosave
                    saveas(h1,fullfile(saveDir,[fileName,unitName,'_timeToNextSpike-5msBins.png']));
                    close(h1);
                end
            end
            
            if true % Analysis 2
                pethWindow = .05; % seconds
                pethBinWidth = 5; % ms
                pethBins = [-pethWindow-(pethBinWidth/1000):pethBinWidth/1000:pethWindow+(pethBinWidth/1000)] + (pethBinWidth/1000)/2;
                binEdge = mean(diff(pethBins)) / 2;
                all_tsPeth = {};
                all_tsPethSurr = {};
                a = pulse_ts(1);
                b = pulse_ts(end);
                for iPulse = 1:numel(pulse_ts)
                    pulse = pulse_ts(iPulse);
                    pulseSurr = (b-a).*rand(1,1) + a;
                    ts_shift = ts - pulse;
                    ts_shiftSurr = ts - pulseSurr;
                    ts_window = ts_shift(ts_shift >= -pethWindow - binEdge & ts_shift < pethWindow + binEdge);
                    ts_windowSurr = ts_shiftSurr(ts_shiftSurr >= -pethWindow - binEdge & ts_shiftSurr < pethWindow + binEdge);
                    all_tsPeth{iPulse} = ts_window;
                    all_tsPethSurr{iPulse} = ts_windowSurr;
                end
                
                h1 = figure('position',[0 0 900 400]);
                for ii = 1:2
                    subplot(1,2,ii);
                    useData = all_tsPeth;
                    addTitle = '';
                    if ii == 2
                        useData = all_tsPethSurr;
                        addTitle = ' SURROGATE';
                    end
                    [counts,centers] = hist([useData{:}],pethBins);
                    fr = ((1/(pethBinWidth/1000)) * counts) / numel(pulse_ts);
                    bar(centers,fr,'k');
                    xlim([-pethWindow pethWindow]);
                    xlabel('time (s), pulse = 0');
                    ylabel('spikes/sec');
                    title({fileName,unitName,['Peri-laser ON',addTitle],[num2str(numel(pulse_ts)),' pulses']},'interpreter','none');
                    grid on;
                    ylimAuto = ylim;
                    ylimVals(ii) = ylimAuto(2);
                    hold on;
                end
                for ii = 1:2
                    subplot(1,2,ii);
                    ylim([0 max(ylimVals)]);
                    xlim([-pethWindow pethWindow]);
% %                     xticks([-pethWindow:.01:pethWindow]);
                end
                if dosave
                    saveas(h1,fullfile(saveDir,[fileName,unitName,'_50msWin2msBin.png']));
                    close(h1);
                end
                
                if true % grant figure
                    fontSize = 10;
                    fontName = 'Arial';
                    figure('position',[0 0 700 500]);
                    useData = all_tsPeth;
                    [counts,centers] = hist([useData{:}],pethBins);
                    fr = ((1/(pethBinWidth/1000)) * counts) / numel(pulse_ts);
                    maxy = max(fr) + 2;
                    hold on;
                    for ii = [-pethWindow - .01:.02:pethWindow + .01]
                        x = [ii ii+.01 ii+.01 ii];
                        y = [0 0 maxy maxy];
                        patch(x,y,[82/255 148/255 247/255],'EdgeColor','none','FaceAlpha',1);
                    end
                    for ii = [-pethWindow - .01:.02:pethWindow + .01]
                        x = [ii ii+.01 ii+.01 ii];
                        y = [0 0 maxy-1 maxy-1];
                        patch(x,y,[170/255 203/255 251/255],'EdgeColor','none','FaceAlpha',1);
                    end
                    bar(centers,fr,'k');
                    xlim([-pethWindow pethWindow]);
                    xlabel('Time (s)');
                    ylabel('Spikes/Sec');
                    xlim([-pethWindow pethWindow]);
                    ylim([25 maxy]);
                    xticks([-pethWindow:.05:pethWindow]);
                    yticks([0:1:33]);
                    set(gcf,'color','w');
                    set(gca,'fontSize',fontSize);
                    set(gca,'fontName',fontName);
                    title(fileName(end-13:end),'interpreter','none');
                    if true
                        axes('Position',[.78 .78 .12 .15]);
                        plot(smooth(spikeWaveform,3),'LineWidth',2,'Color','red');
                        xlim([0 numel(spikeWaveform)]);
                        axis off;
                        box off;
                    end
                end
            end
        end
    end
end