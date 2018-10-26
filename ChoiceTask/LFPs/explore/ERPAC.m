doSetup = true;
doSave = true;
% % savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/ERPAC/3D';
zThresh = 2;
tWindow = 1;
freqList = logFreqList([2 200],11);

% freqIdx = floor(linspace(1,numel(freqList),5));
% freqLabels = freqList(freqIdx);
% freqLabels = num2str(freqLabels(:),'%2.1f');
freqLabels = num2str(freqList(:),'%2.1f');
views = [0 0;45 15; 80 15];
pvalThresh = 0.01;
Wlength = 200;

iSession = 0;
all_M = [];
all_ERPAC_rho = [];
all_ERPAC_pval = [];
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    if doSetup
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
% %         [Wz_power,keepTrials] = removeWzTrials(Wz_power,zThresh);
% %         Wz_phase = Wz_phase(:,:,keepTrials,:);
    
        ERPAC_rho = NaN(size(Wz_power,1),size(Wz_power,2),size(Wz_power,4),size(Wz_power,4));
        ERPAC_pval = NaN(size(Wz_power,1),size(Wz_power,2),size(Wz_power,4),size(Wz_power,4));
        for iEvent = 1:size(Wz_power,1)
            for iBin = 1:size(Wz_power,2)
                for ifp = 1:numel(freqList)
                    for ifA = ifp:numel(freqList)
                        alpha = squeeze(Wz_phase(iEvent,iBin,:,ifp));
                        x = squeeze(Wz_power(iEvent,iBin,:,ifA));
                        [rho,pval] = circ_corrcl(alpha,x);
                        ERPAC_rho(iEvent,iBin,ifp,ifA) = rho;
                        ERPAC_pval(iEvent,iBin,ifp,ifA) = pval;
                    end
                end
            end
        end
    end
    
    all_ERPAC_rho(iSession,:,:,:,:) = ERPAC_rho;
    all_ERPAC_pval(iSession,:,:,:,:) = ERPAC_pval;
    
    if doSave
        savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/ERPAC/deltaPhase';
        h = ff(1400,400);
        ifp = 2;
        rows = 2;
        cols = 7;
        nSmooth = 1;
        for iEvent = 1:7
            subplot(rows,cols,prc(cols,[1 iEvent]));
            rhoMat = [];
            for ifA = 1:size(ERPAC_rho,3)
                rhoMat(ifA,:) = smooth(squeeze(ERPAC_rho(iEvent,:,ifp,ifA)),nSmooth);
            end
            imagesc(rhoMat);
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis([-0.5 0.5]);
            xticks([1 size(rhoMat,2)/2 size(rhoMat,2)]);
            xticklabels({'-1','0','1'});
            xlabel('time (s)');
            yticks(1:numel(freqList));
            yticklabels(num2str(freqList(:),'%2.1f'));
            title('corrcl \delta phase');
            if iEvent == 1
                ylabel('amplitude (Hz)');
            end
            if iEvent == 7
                cbAside(gca,'rho','k');
            end

            subplot(rows,cols,prc(cols,[2 iEvent]));
            pvalMat = [];
            for ifA = 1:size(ERPAC_pval,3)
                pvalMat(ifA,:) = smooth(squeeze(ERPAC_pval(iEvent,:,ifp,ifA)),nSmooth);
            end
            imagesc(rhoMat);
            colormap(gca,jet);
            set(gca,'ydir','normal');
            caxis([0 0.05]);
            xticks([1 size(pvalMat,2)/2 size(pvalMat,2)]);
            xticklabels({'-1','0','1'});
            xlabel('time (s)');
            yticks(1:numel(freqList));
            yticklabels(num2str(freqList(:),'%2.1f'));
            if iEvent == 1
                ylabel('amplitude (Hz)');
            end
            if iEvent == 7
                cbAside(gca,'pval','k');
            end
        end
        set(gcf,'color','w');
        saveFile = [subjectName,'_s',num2str(iSession,'%02d'),'_deltaPhase_ERPAC'];
        saveas(h,fullfile(savePath,[saveFile,'.png']));
        close(h);
    end
% %     t = linspace(-1,1,size(ERPAC_rho,2));
% %     M = [];
% %     for iBin = 1:size(ERPAC_rho,2)
% %         for iEvent = 1:7
% %             ERPAC_matrix = squeeze(ERPAC_rho(iEvent,iBin,:,:));
% %             ERPAC_matrix_pval = squeeze(ERPAC_pval(iEvent,iBin,:,:)) < pvalThresh;
% % %             im = (ERPAC_matrix_pval.*ERPAC_matrix)';
% %             im = ERPAC_matrix;
% %             im(im == 0) = NaN;
% %             M(iEvent,iBin,:,:) = im;
% %         end
% %     end
% %     all_M(iSession,:,:,:,:) = M;
% %     
% %     if doSave
% %         h = figuree(1500,550);
% %         rows = 3;
% %         cols = 7;
% %         for iRow = 1:rows
% %             for iEvent = 1:cols
% %                 subplot(rows,cols,prc(cols,[iRow,iEvent]));
% %                 hm = slice(squeeze(M(iEvent,:,:,:)),[],1:size(ERPAC_rho,2),[]);
% %     % %             [xs,ys,zs] = ndgrid( 1:25 , 1:50 , 1:4 ) ;
% %                 shading interp;
% %                 colormap(jet);
% %                 caxis([0 0.5]);
% %                 set(hm,'FaceAlpha',0.1);
% %                 view(views(iRow,:));
% %                 zlabel('amp (Hz)');
% %                 xlabel('phase (Hz)');
% %                 ylabel('time (s)');
% %                 xticks(1:numel(freqList));
% %                 xticklabels(freqLabels);
% %                 zticks(1:numel(freqList));
% %                 zticklabels(freqLabels);
% %                 yticks([1 round(size(ERPAC_rho,2)/2) size(ERPAC_rho,2)]);
% %                 yticklabels([-tWindow,0,tWindow]);
% %                 set(gca,'fontsize',7);
% %                 if iRow == 1
% %                     title(eventFieldnames{iEvent});
% %                 end
% %                 if iEvent == 7
% %                     cb = cbAside(gca,['corr, p <',num2str(pvalThresh,'%1.2f')],'k');
% %                 end
% %             end
% %         end
% %         set(gcf,'color','w');
% % 
% %         saveFile = [subjectName,'_s',num2str(iSession,'%02d'),'_ERPAC'];
% % %         saveas(h,fullfile(savePath,[saveFile,'.fig']));
% %         saveas(h,fullfile(savePath,[saveFile,'.png']));
% %         close(h);
% %     end
end

h = figuree(1500,700);
rows = 4;
cols = 7;
mean_M = squeeze(nanmean(all_M));
for iEvent = 1:cols
    for iRow = 1:3
        subplot(rows,cols,prc(cols,[iRow,iEvent]));
        hm = slice(squeeze(mean_M(iEvent,:,:,:)),[],1:size(ERPAC_rho,2),[]);
% %             [xs,ys,zs] = ndgrid( 1:25 , 1:50 , 1:4 ) ;
        shading interp;
        colormap(jet);
        caxis([0.25 0.5]);
        set(hm,'FaceAlpha',0.3);
        view(views(iRow,:));
        xlabel('amp (Hz)');
        zlabel('phase (Hz)');
        ylabel('time (s)');
        xticks(freqIdx);
        xticklabels(freqLabels);
        zticks(freqIdx);
        zticklabels(freqLabels);
        yticks([1 round(size(ERPAC_rho,2)/2) size(ERPAC_rho,2)]);
        yticklabels([-tWindow,0,tWindow]);
        set(gca,'fontsize',7);
        if iRow == 1
            title(eventFieldnames{iEvent});
        end
        if iEvent == 7
            cb = cbAside(gca,['corr, p <',num2str(pvalThresh,'%1.2f')],'k');
        end
    end
    subplot(rows,cols,prc(cols,[4,iEvent]));
    plot(t,squeeze(nansum(squeeze(nansum(squeeze(mean_M(iEvent,:,:,:)),2)),2)),'k-','lineWidth',2);
    xlim([-1 1]);
    xticks(sort([xlim,0]));
    ylim([0 200]);
%     yticks(sort([ylim,0.5]));
    if iEvent == 1
        ylabel('nansum, all freq');
    end
    grid on;
end
set(gcf,'color','w');
if doSave
    saveFile = ['allSessions_ERPAC'];
    saveas(h,fullfile(savePath,[saveFile,'.fig']));
    saveas(h,fullfile(savePath,[saveFile,'.png']));
    close(h);
end