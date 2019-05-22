laserFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0244/R0244-terminal/R0244_terminalTests-6/R0244_terminalTests_R0244_terminalTests-6_data_ch65.sev';
f = 'R0244_terminalTests_R0244_terminalTests-6_data_ch37.sev';
p = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0244/R0244-terminal/R0244_terminalTests-6';
[b,a] = butter(4, [0.02 0.2]);
[sev,header] = read_tdt_sev(fullfile(p,f));
sev = filtfilt(b,a,double(sev));
sev = artifactThresh(sev,1,600);
ddt_write_v(fullfile(p,[f,'.ddt']),1,length(sev),header.Fs,sev/1000);

% % % % useSessions = [1,6,11];
% % % % savePath = '/Users/mattgaidica/Desktop/opto';
% % % % for iSession = 1:numel(useSessions)
% % % %     for iFile = 1:64
% % % %         sevFile = sprintf('/Volumes/RecordingsLeventhal2/ChoiceTask/R0244/R0244-terminal/R0244_terminalTests-%i/R0244_terminalTests_R0244_terminalTests-%i_data_ch%i.sev',...
% % % %             useSessions(iSession),useSessions(iSession),iFile);
% % % %         laserFile = sprintf('/Volumes/RecordingsLeventhal2/ChoiceTask/R0244/R0244-terminal/R0244_terminalTests-%i/R0244_terminalTests_R0244_terminalTests-%i_data_ch65.sev',...
% % % %             useSessions(iSession),useSessions(iSession));
% % % %         [sevFilt,header] = filterSev(sevFile);
% % % %         [sevLaser, ~] = read_tdt_sev(laserFile);
% % % %         h = ff(1200,400);
% % % %         yyaxis left;
% % % %         plot(sevFilt);
% % % %         ylabel('uV (ephys)');
% % % %         yyaxis right;
% % % %         plot(sevLaser);
% % % %         ylabel('uV (laser)');
% % % %         xlim([1 numel(sevLaser)]);
% % % %         set(gcf,'color','w');
% % % %         title(sprintf('Session %i, File %i',useSessions(iSession),iFile));
% % % %         saveFile = fullfile(savePath,['session',num2str(useSessions(iSession),'%02d'),'_file',num2str(iFile,'%02d'),'.png']);
% % % %         saveas(h,saveFile);
% % % %         close(h);
% % % %     end
% % % % end