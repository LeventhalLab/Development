logPaths = {'/Volumes/RecordingsLeventhal2/ChoiceTask/R0088',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/R0117',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/R0142',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/R0154'};

if true
    all_RT = [];
    all_MT = [];
    allLog_RT = {};
    allLog_MT = {};
    iSession = 1;
    for iPath = 1:numel(logPaths)
        disp(logPaths{iPath});
        d = dir2(logPaths{iPath},'-r','*.log');
        for iFile = 1:numel(d)
            if ~strcmp(d(iFile).name(end-6:end),'old.log')
                logFile = fullfile(logPaths{iPath},d(iFile).name);
                logData = readLogData(logFile);
                if isfield(logData,'outcome')
                    corrIdx = find(logData.outcome == 0);
                    if (numel(corrIdx) / numel(logData.outcome)) > 0.7
                        allLog_RT{iSession} = logData.RT(corrIdx);
                        allLog_MT{iSession} = logData.MT(corrIdx);
                        all_RT = [all_RT logData.RT(corrIdx)];
                        all_MT = [all_MT logData.MT(corrIdx)];
                        iSession = iSession + 1;
                    end
                end
            end
        end
    end
end



colors = lines(numel(allLog_RT));
figure;
for iSession = 1:numel(allLog_RT)
    plot(allLog_RT{iSession},allLog_MT{iSession},'.','MarkerSize',10,'color',colors(iSession,:));
    hold on;
end
xlabel('RT');
ylabel('MT');
xlim([0 1]);
ylim([0 1]);

figure;
for iSession = 1:numel(allLog_RT)
    plot(allLog_RT{iSession},allLog_RT{iSession}+allLog_MT{iSession},'k.','MarkerSize',10);
    hold on;
end

% % figure;
% % for iSession = 1:numel(allLog_RT)
% %     plot(allLog_RT{iSession}+allLog_MT{iSession},'k.','MarkerSize',10);
% %     hold on;
% % end
% % for iSession = 1:numel(allLog_RT)
% %     rndMT = allLog_MT{iSession};
% %     rndIdx = randperm(numel(allLog_MT{iSession}));
% %     rndMT = rndMT(rndIdx);
% %     plot(allLog_RT{iSession}+rndMT,'r.','MarkerSize',10);
% %     hold on;
% % end