% % laserFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0244/R0244-terminal/R0244_terminalTests-6/R0244_terminalTests_R0244_terminalTests-6_data_ch65.sev';
% % f = 'R0244_terminalTests_R0244_terminalTests-6_data_ch37.sev';
% % p = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0244/R0244-terminal/R0244_terminalTests-6';
% % [b,a] = butter(4, [0.02 0.2]);
% % [sev,header] = read_tdt_sev(fullfile(p,f));
% % sev = filtfilt(b,a,double(sev));
% % sev = artifactThresh(sev,1,600);
% % ddt_write_v(fullfile(p,[f,'.ddt']),1,length(sev),header.Fs,sev/1000);

useSessions = [8];
showWindow = [0.25 0.05]; % seconds
savePath = '/Users/mattgaidica/Desktop/opto';
for iSession = 1:numel(useSessions)
    for iFile = 1:64
        sevFile = sprintf('/Volumes/RecordingsLeventhal2/ChoiceTask/R0244/R0244-terminal/R0244_terminalTests-%i/R0244_terminalTests_R0244_terminalTests-%i_data_ch%i.sev',...
            useSessions(iSession),useSessions(iSession),iFile);
        laserFile = sprintf('/Volumes/RecordingsLeventhal2/ChoiceTask/R0244/R0244-terminal/R0244_terminalTests-%i/R0244_terminalTests_R0244_terminalTests-%i_data_ch65.sev',...
            useSessions(iSession),useSessions(iSession));
        [sevFilt,header] = filterSev(sevFile);
        sev_t = linspace(0,numel(sevFilt)/header.Fs,numel(sevFilt));
        [sevLaser, ~] = read_tdt_sev(laserFile);
        firstPulse = find(sevLaser > 1e6,1,'first');
        firstOff = find(sevLaser(firstPulse:end) < 1e6,1,'first') + firstPulse;
        
        h = ff(1400,800);
        for iSubplot = 2:6
            if iSubplot == 2
                subplot(3,2,[1 2]);
            else
                subplot(3,2,iSubplot);
            end
            yyaxis left;
            plot(sev_t,sevFilt);
            ylabel('uV (ephys)');
            yyaxis right;
            plot(sev_t,sevLaser);
            ylabel('uV (laser)');
            
            switch iSubplot
                case 2
                    title(sprintf('Session %i, File %i',useSessions(iSession),iFile));
                    xlim([min(sev_t) max(sev_t)]);
                case 3
                    xlim([sev_t(firstPulse)-showWindow(1) sev_t(firstPulse)+showWindow(1)]);
                    title(['+/- ',num2str(showWindow(1),'%1.2f'),' s']);
                case 4
                    xlim([sev_t(firstOff)-showWindow(1) sev_t(firstOff)+showWindow(1)]);
                    title(['+/- ',num2str(showWindow(1),'%1.2f'),' s']);
                case 5
                    xlim([sev_t(firstPulse)-showWindow(2) sev_t(firstPulse)+showWindow(2)]);
                    title(['+/- ',num2str(showWindow(2),'%1.2f'),' s']);
                case 6
                    xlim([sev_t(firstOff)-showWindow(2) sev_t(firstOff)+showWindow(2)]);
                    title(['+/- ',num2str(showWindow(2),'%1.2f'),' s']);
            end
            xlabel('time (s)');
        end
        set(gcf,'color','w');
        saveFile = fullfile(savePath,['session',num2str(useSessions(iSession),'%02d'),'_file',num2str(iFile,'%02d'),'.png']);
        saveas(h,saveFile);
        close(h);
    end
end