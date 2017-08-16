logPaths = {'/Volumes/RecordingsLeventhal2/ChoiceTask/R0088',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/R0117',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/R0142',...
    '/Volumes/RecordingsLeventhal2/ChoiceTask/R0154'};

if false
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
                    if (numel(corrIdx) / numel(logData.outcome)) > 0.5
                        RTs = logData.RT(corrIdx);
                        MTs = logData.MT(corrIdx);
                        validIdxs = find(RTs > 0 & RTs < 1 & MTs > 0 & MTs < 1);
                        if ~isempty(validIdxs)
                            allLog_RT{iSession} = RTs(validIdxs);
                            allLog_MT{iSession} = MTs(validIdxs);
                            all_RT = [all_RT;RTs(validIdxs)];
                            all_MT = [all_MT;MTs(validIdxs)];
                            iSession = iSession + 1;
                        end
                    end
                end
            end
        end
    end
end

if true
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
end

% if you fix MT
tickLabels = {};
blockInterval = 0.1;
fRTs = 0:blockInterval:1;
fMTs = 0:blockInterval:1;
nSurr = 100;
probMatrix = [];
figure;
for iRT = 1:numel(fRTs)
    fRT = fRTs(iRT);
    tickLabels{iRT} = [num2str(fRT),' - ',num2str(fRT + blockInterval)];
    RTIdx = find(all_RT >= fRT & all_RT < fRT + blockInterval);
    MTsinRTbin = all_MT(RTIdx);
    for iMT = 1:numel(fMTs)
        fMT = fMTs(iMT);
        rtMtIdx = find(MTsinRTbin >= fMT & MTsinRTbin < fMT + blockInterval);
        surrArr = [];
        for iSurr = 1:nSurr
%             randIdx = randperm(numel(MTsinRTbin));
%             all_MT_shuff = MTsinRTbin(randIdx);
%             rtMtShuffIdx = find(all_MT_shuff >= fMT & all_MT_shuff < fMT + blockInterval);
%             surrArr(iSurr) = numel(rtMtShuffIdx);
            randsample(MTsinRTbin,numel(rtMtIdx));
        end
        
        probMatrix(iMT,iRT) = numel(find(numel(rtMtIdx) > surrArr)) / numel(surrArr);
        imagesc(probMatrix); drawnow; set(gca,'ydir','normal');
    end
end
set(gca,'ydir','normal');
xlabel('RT');
ylabel('MT');
xticklabels(tickLabels);
xtickangle(90);
yticklabels(tickLabels);
colorbar;
caxis([0 1]);
colormap(jet);