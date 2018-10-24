if true
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/canoltyMethod/bySubject';
    subjects = {'R0088','R0117','R0142','R0142','R0154','R0182'};
    subjectSessions = [1 4;5 11;12 18;19 24;25 29;30 30];
    for iSubject = 1:numel(subjects)
        subjectName = subjects{iSubject};
        theseSessions = subjectSessions(iSubject,:);
        sessionRange = theseSessions(1):theseSessions(end);
        rows = diff(theseSessions)+2;
        cols = 7;
        h = ff(1500-((rows/4)*250),175*rows);
        
        for iEvent = 1:7
            subplot(rows,cols,prc(cols,[1 iEvent]));
            smean_MImatrix_noMix = squeeze(mean(mean_MImatrix_noMix(sessionRange,iEvent,:,:)));
            imagesc(smean_MImatrix_noMix');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis([-2 2]);
            xticks(1:numel(freqList));
            xticklabels(freqLabels);
            xtickangle(270);
            yticks(1:numel(freqList));
            yticklabels(freqLabels);
            set(gca,'fontsize',8);
            if iEvent == 1
                ylabel('amp (Hz)');
            end
            title({subjectName,eventFieldnames{iEvent},'mean'});
            if iEvent == 7
                cbAside(gca,'Z-MI','k');
            end
        end
        sessionCount = 0;
        for iSession = sessionRange
            sessionCount = sessionCount + 1;
            for iEvent = 1:7
                subplot(rows,cols,prc(cols,[sessionCount+1 iEvent]));
                smean_MImatrix_noMix = squeeze(mean_MImatrix_noMix(iSession,iEvent,:,:));
                imagesc(smean_MImatrix_noMix');
                colormap(gca,jet);
                set(gca,'ydir','normal');
                caxis([-2 2]);
                xticks(1:numel(freqList));
                xticklabels(freqLabels);
                xtickangle(270);
                yticks(1:numel(freqList));
                yticklabels(freqLabels);
                set(gca,'fontsize',8);
                if iEvent == 1
                    ylabel('amp (Hz)');
                end
                title(['session ',num2str(iSession)]);
                if iEvent == 7
                    cbAside(gca,'Z-MI','k');
                end
                if iSession == sessionRange(end)
                    xlabel('phase (Hz)');
                end
            end
        end
        set(gcf,'color','w');
        saveFile = [subjectName,'_sess',num2str(theseSessions(1),'%02d'),'_canoltyPAC.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end


if false % prints single sheet for each session
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/tortMethod/debug';
    for iSession = 1:30
        sessMat = all_MImatrix{iSession};
        rows = ceil(sqrt(size(sessMat,2)));
        cols = rows;
        h = figuree(900,900);
        for iTrial = 1:size(sessMat,2)
            iEvent = 4;
            curMat = squeeze(sessMat(iEvent,iTrial,:,:));
            
            subplot(rows,cols,iTrial);
            imagesc(curMat');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis([-4 4]);
            xticks(xlim);
            xticklabels('');
            yticks(ylim);
            yticklabels('');
            title(num2str(iTrial));
            set(gca,'fontsize',6);
        end
        set(gcf,'color','w');
        saveFile = ['s',num2str(iSession,'%03d'),'_allTrials_',eventFieldnames{iEvent},'.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end

if false % prints each trial
    savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/tortMethod/debug';
    rows = 2;
    cols = 7;
    for iSession = 1:30
        sessMat = all_MImatrix{iSession};
        for iTrial = 1:size(sessMat,2)
            h = figuree(1400,400);
            for iEvent = 1:7
                curMat = squeeze(sessMat(iEvent,iTrial,:,:));

                subplot(rows,cols,prc(cols,[1 iEvent]));
                imagesc(curMat');
                colormap(gca,jet);
                set(gca,'ydir','normal');
                caxis([-4 4]);
                xticks(1:numel(freqList));
                xticklabels(freqLabels);
                xlabel('phase (Hz)');
                yticks(1:numel(freqList));
                yticklabels(freqLabels);
                ylabel('amp (Hz)');
                set(gca,'fontsize',6);
                if iEvent == 1
                    title({['s',num2str(iSession),', t',num2str(iTrial)],eventFieldnames{iEvent}});
                else
                    title({'',eventFieldnames{iEvent}});
                end
                if iEvent == 7
                    cbAside(gca,'Z-MI','k');
                end

                % note: z = norminv(alpha/N); N = # of index values
                pMat = normcdf(curMat,'upper')*numel(freqList).^2;
                subplot(rows,cols,prc(cols,[2 iEvent]));
                imagesc(pMat');
                colormap(gca,jet);
                set(gca,'ydir','normal');
                caxis([0 1]);
                xticks(1:numel(freqList));
                xticklabels(freqLabels);
                xlabel('phase (Hz)');
                yticks(1:numel(freqList));
                yticklabels(freqLabels);
                ylabel('amp (Hz)');
                set(gca,'fontsize',6);

                if iEvent == 7
                    cbAside(gca,'p-value','k');
                end
            end

            set(gcf,'color','w');
            saveFile = ['s',num2str(iSession,'%03d'),'_','t',num2str(iTrial,'%03d'),'_allEvent.png'];
            saveas(h,fullfile(savePath,saveFile));
            close(h);
        end
    end
end

