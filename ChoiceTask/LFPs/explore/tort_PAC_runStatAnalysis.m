% compile with: tort_PAC_compileSurrogates.m & Tort_PACmethod.m
doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/tortMethod';
nSurr = size(all_MImatrix_surr,2);
freqLabels = num2str(freqList(:),'%2.1f');

if false
    % random time-shifted surrogates
    rows = 2;
    cols = 7;
    all_surrArr_pval = [];
    for iSession = 1:30
        h = figuree(1400,400);
        for iEvent = 1:7
            sessionMat = all_MImatrix{iSession};
            curMat = squeeze(nanmean(sessionMat(iEvent,:,:,:)));
            surrMats = squeeze(all_MImatrix_surr(iSession,:,:,:));
% %             surrMats = squeeze(sessionMat(1,:,:,:));
            curMatZ = (curMat - squeeze(nanmean(surrMats))) ./ squeeze(nanstd(surrMats));
            
            ff(900,300);
            subplot(131);
            imagesc(curMat');
            title('curMat');
            subplot(132);
            imagesc(squeeze(nanmean(surrMats))');
            title('mean(surrMat)');
            subplot(133);
            imagesc(curMatZ');
            title('curMatZ');
            colormap(jet);

            subplot(rows,cols,prc(cols,[1 iEvent]));
            imagesc(curMatZ');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis([-2 2]);
            xticks(1:numel(freqList));
            xticklabels(freqLabels);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList));
            yticklabels(freqLabels);
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            if iEvent == 1
                title({num2str(iSession,'%02d'),eventFieldnames{iEvent}});
            else
                title({'',eventFieldnames{iEvent}});
            end
            if iEvent == 7
                cbAside(gca,'Z-MI','k');
            end

            surrArr = [];
            for iSurr = 1:nSurr
                curSurr = squeeze(surrMats(iSurr,:,:));
                curSurrZ = (curSurr - squeeze(nanmean(surrMats))) ./ squeeze(nanstd(surrMats));
                if isempty(surrArr)
                    surrArr = (curMatZ > curSurrZ);
                else
                    surrArr = surrArr + (curMatZ > curSurrZ);
                end
            end
            subplot(rows,cols,prc(cols,[2 iEvent]));
            surrArr_pval = 1 - (surrArr ./ nSurr);
            all_surrArr_pval(iSession,iEvent,:,:) = surrArr_pval;
            imagesc(surrArr_pval');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis([0 0.05]);
            xticks(1:numel(freqList));
            xticklabels(freqLabels);
            xlabel('phase (Hz)');
            yticks(1:numel(freqList));
            yticklabels(freqLabels);
            ylabel('amp (Hz)');
            set(gca,'fontsize',6);
            title({eventFieldnames{iEvent}});
            if iEvent == 7
                cbAside(gca,'pval','k');
            end
        end

        set(gcf,'color','w');
        if doSave
            saveFile = ['surr_',num2str(iSession,'%02d'),'_timeShifted.png'];
            saveas(h,fullfile(savePath,saveFile));
            close(h);
        end
    end
end

if false
    % All Session, random time-shifted surrogates
    session_matZ = [];
    for iSession = 1:30
        for iEvent = 1:7
            sessionMat = all_MImatrix{iSession};
            curMat = squeeze(nanmean(sessionMat(iEvent,:,:,:)));
            surrMats = squeeze(all_MImatrix_surr(iSession,:,:,:));
%             surrMats = squeeze(sessionMat(1,:,:,:));
            curMatZ = (curMat - squeeze(nanmean(surrMats))) ./ squeeze(nanstd(surrMats));
            session_matZ(iSession,iEvent,:,:) = curMatZ;
        end
    end
    
    rows = 2;
    cols = 7;
    h = figuree(1400,400);
    for iEvent = 1:7
        curMatZ = squeeze(nanmean(session_matZ(:,iEvent,:,:)));
        subplot(rows,cols,prc(cols,[1 iEvent]));
        imagesc(curMatZ');
        colormap(gca,jet);
        set(gca,'ydir','normal');
        caxis([-1 1]);
        xticks(1:numel(freqList));
        xticklabels(freqLabels);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList));
        yticklabels(freqLabels);
        ylabel('amp (Hz)');
        set(gca,'fontsize',6);
        if iEvent == 1
            title({'All Sessions',eventFieldnames{iEvent}});
        else
            title({'',eventFieldnames{iEvent}});
        end
        if iEvent == 7
            cbAside(gca,'Z-MI','k');
        end
        
        surrArr_pval = squeeze(mean(all_surrArr_pval(:,iEvent,:,:)));
        subplot(rows,cols,prc(cols,[2 iEvent]));
        imagesc(surrArr_pval');
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
            cbAside(gca,'mean p-val','k');
        end
    end
    set(gcf,'color','w');
    if doSave
        saveFile = 'surr_AllSessions_timeShifted.png';
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end

if true
    % shuffled trials
    rows = 2;
    cols = 7;
    for iSession = 1:30
        surrMats = squeeze(all_MImatrix_surrEvents(iSession,:,:,:,:));
        sessionMat = all_MImatrix{iSession};
        h = figuree(1400,400);
        for iEvent = 1:7
            surrArr = [];
            for iTrial = 1:size(sessionMat,2)
                curMat = squeeze(sessionMat(iEvent,iTrial,:,:));
                for iSurr = 1:nSurr
                    curSurr = squeeze(surrMats(iEvent,iSurr,:,:));
                    if isempty(surrArr)
                        surrArr = (curMat > curSurr);
                    else
                        surrArr = surrArr + (curMat > curSurr);
                    end
                end
            end

            for iRow = 1:2
                if iRow == 1
                    caxisVals = [0 1];
                else
                    caxisVals = [0.9 1];
                end
                subplot(rows,cols,prc(cols,[iRow iEvent]));
                surrArr = 1 - (surrArr ./ (nSurr * size(sessionMat,2)));
                imagesc(surrArr');
                colormap(gca,jet);
                set(gca,'ydir','normal');
                caxis(caxisVals);
                xticks(1:numel(freqList));
                xticklabels(freqLabels);
                xlabel('phase (Hz)');
                yticks(1:numel(freqList));
                yticklabels(freqLabels);
                ylabel('amp (Hz)');
                set(gca,'fontsize',6);
                title({eventFieldnames{iEvent}});
                if iEvent == 7
                    cbAside(gca,'pval','k');
                end
            end
        end
        set(gcf,'color','w');
        if doSave
            saveFile = ['surr',num2str(iSession,'%02d'),'_shuffledTrials.png'];
            saveas(h,fullfile(savePath,saveFile));
            close(h);
        end
    end
end