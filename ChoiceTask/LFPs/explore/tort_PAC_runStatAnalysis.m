% compile with: tort_PAC_compileSurrogates.m & Tort_PACmethod.m
doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/tortMethod';
nSurr = size(all_MImatrix_surr,2);
freqLabels = num2str(freqList(:),'%2.1f');
useCueSurr = false;
if useCueSurr
    saveLabel = 'ZCUE';
else
    saveLabel = '';
end

if true
    % random time-shifted surrogates
    rows = 2;
    cols = 7;
    all_surrArr_pval = [];
    for iSession = 1:30
        h = figuree(1400,400);
        for iEvent = 1:7
            sessionMat = all_MImatrix{iSession};
            curMat = squeeze(nanmean(sessionMat(iEvent,:,:,:)));
            if useCueSurr
                surrMats = squeeze(sessionMat(1,:,:,:)); % cue
            else
                surrMats = squeeze(all_MImatrix_surr(iSession,:,:,:));
            end
            curMatZ = (curMat - squeeze(nanmean(surrMats))) ./ squeeze(nanstd(surrMats));
            
            if iEvent == 4
                h1 = ff(1200,200);
                rows_h1 = 1;
                cols_h1 = 5;
                
                subplot(rows_h1,cols_h1,1);
                imagesc(curMat');
                set(gca,'ydir','normal');
                caxis([0 0.03]);
                cbAside(gca,'MI','k');
                title({'Nose Out','curMat'});
                xticks(1:numel(freqList));
                xticklabels(freqLabels);
                xlabel('phase (Hz)');
                yticks(1:numel(freqList));
                yticklabels(freqLabels);
                ylabel('amp (Hz)');
                set(gca,'fontsize',6);
                
                subplot(rows_h1,cols_h1,2);
                imagesc(squeeze(nanmean(surrMats))');
                set(gca,'ydir','normal');
                caxis([0 0.03]);
                cbAside(gca,'MI','k');
                title({'Nose Out','mean(surrMat)'});
                xticks(1:numel(freqList));
                xticklabels(freqLabels);
                xlabel('phase (Hz)');
                yticks(1:numel(freqList));
                yticklabels(freqLabels);
                set(gca,'fontsize',6);
                
                subplot(rows_h1,cols_h1,3);
                imagesc(curMat' - squeeze(nanmean(surrMats))');
                set(gca,'ydir','normal');
                caxis([0 0.03]);
                cbAside(gca,'MI','k');
                title({'Nose Out','curMat - mean(surrMat)'});
                xticks(1:numel(freqList));
                xticklabels(freqLabels);
                xlabel('phase (Hz)');
                yticks(1:numel(freqList));
                yticklabels(freqLabels);
                set(gca,'fontsize',6);
                
                subplot(rows_h1,cols_h1,4);
                imagesc(squeeze(nanstd(surrMats))');
                set(gca,'ydir','normal');
                caxis([0 0.015]);
                cbAside(gca,'MI','k');
                title({'Nose Out','std(surrMat)'});
                xticks(1:numel(freqList));
                xticklabels(freqLabels);
                xlabel('phase (Hz)');
                yticks(1:numel(freqList));
                yticklabels(freqLabels);
                set(gca,'fontsize',6);
                
                subplot(rows_h1,cols_h1,5);
                imagesc(curMatZ');
                set(gca,'ydir','normal');
                caxis([-2 2]);
                cbAside(gca,'Z-MI','k');
                title({'Nose Out','curMatZ'});
                colormap(jet);
                xticks(1:numel(freqList));
                xticklabels(freqLabels);
                xlabel('phase (Hz)');
                yticks(1:numel(freqList));
                yticklabels(freqLabels);
                set(gca,'fontsize',6);
                
                set(gcf,'color','w');
                if doSave
                    saveFile = ['surr',saveLabel,'_',num2str(iSession,'%02d'),'_timeShifted_NoseOut.png'];
                    saveas(h1,fullfile(savePath,saveFile));
                    close(h1);
                end
                    
                figure(h);
            end
            
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
            for iSurr = 1:size(surrMats,1)
                curSurr = squeeze(surrMats(iSurr,:,:));
                curSurrZ = (curSurr - squeeze(nanmean(surrMats))) ./ squeeze(nanstd(surrMats));
                if isempty(surrArr)
                    surrArr = (curMatZ > curSurrZ);
                else
                    surrArr = surrArr + (curMatZ > curSurrZ);
                end
            end
            subplot(rows,cols,prc(cols,[2 iEvent]));
            surrArr_pval = 1 - (surrArr ./ size(surrMats,1));
            all_surrArr_pval(iSession,iEvent,:,:) = surrArr_pval;
            imagesc(surrArr_pval');
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis([0 0.2]);
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
            saveFile = ['surr',saveLabel,'_',num2str(iSession,'%02d'),'_timeShifted.png'];
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
            if useCueSurr
                surrMats = squeeze(sessionMat(1,:,:,:)); % cue
            else
                surrMats = squeeze(all_MImatrix_surr(iSession,:,:,:));
            end
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
        saveFile = ['surr',saveLabel,'_AllSessions_timeShifted.png'];
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end

% !! add mean surrogate, chanes to 3 rows, 7 cols so side-by-side?
if false
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

            subplot(rows,cols,prc(cols,[iRow iEvent]));
            surrArr = 1 - (surrArr ./ (nSurr * size(sessionMat,2)));
            imagesc(surrArr');
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
            title({eventFieldnames{iEvent}});
            if iEvent == 7
                cbAside(gca,'pval','k');
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