% used to generate all_M_phase
doSetup = true;
doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/ERPPC';
zThresh = 2;
tWindow = 1;
freqList = logFreqList([3.5 200],30);

freqIdx = floor(linspace(1,numel(freqList),5));
freqLabels = freqList(freqIdx);
freqLabels = num2str(freqLabels(:),'%2.1f');
views = [0 0;45 15; 80 15];
pvalThresh = 0.01;
Wlength = 200;

iSession = 0;
all_M_phase = [];
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;
    if doSetup
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
        W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
        [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
        [Wz_power,keepTrials] = removeWzTrials(Wz_power,zThresh);
        Wz_phase = Wz_phase(:,:,keepTrials,:);
    
        ERPPC_rho = NaN(size(Wz_power,1),size(Wz_power,2),size(Wz_power,4),size(Wz_power,4));
        ERPPC_pval = NaN(size(Wz_power,1),size(Wz_power,2),size(Wz_power,4),size(Wz_power,4));
        for iEvent = 1:size(Wz_power,1)
            for iBin = 1:size(Wz_power,2)
                for iFreq = 1:numel(freqList)
                    for jFreq = iFreq:numel(freqList)
                        alpha1 = squeeze(Wz_phase(iEvent,iBin,:,iFreq));
                        alpha2 = squeeze(Wz_power(iEvent,iBin,:,jFreq));
                        [rho,pval] = circ_corrcc(alpha1,alpha2);
                        ERPPC_rho(iEvent,iBin,iFreq,jFreq) = rho;
                        ERPPC_pval(iEvent,iBin,iFreq,jFreq) = pval;
                    end
                end
            end
        end
    end
    
    t = linspace(-1,1,size(ERPPC_rho,2));
    M = [];
    for iBin = 1:size(ERPPC_rho,2)
        for iEvent = 1:7
            ERPPC_matrix = squeeze(ERPPC_rho(iEvent,iBin,:,:));
            ERPPC_matrix_pval = squeeze(ERPPC_pval(iEvent,iBin,:,:)) < pvalThresh;
%             im = (ERPAC_matrix_pval.*ERPAC_matrix)';
            im = ERPPC_matrix;
            im(im == 0) = NaN;
            M(iEvent,iBin,:,:) = im;
        end
    end
    all_M_phase(iSession,:,:,:,:) = M;
end

h = figuree(1500,700);
rows = 4;
cols = 7;
mean_M = squeeze(nanmean(all_M_phase));
for iEvent = 1:cols
    for iRow = 1:3
        subplot(rows,cols,prc(cols,[iRow,iEvent]));
        hm = slice(squeeze(mean_M(iEvent,:,:,:)),[],1:size(ERPPC_rho,2),[]);
% %             [xs,ys,zs] = ndgrid( 1:25 , 1:50 , 1:4 ) ;
        shading interp;
        colormap(jet);
        caxis([-0.15 0.15]);
        set(hm,'FaceAlpha',0.1);
        view(views(iRow,:));
        xlabel('phase (Hz)');
        zlabel('phase (Hz)');
        ylabel('time (s)');
        xticks(freqIdx);
        xticklabels(freqLabels);
        zticks(freqIdx);
        zticklabels(freqLabels);
        yticks([1 round(size(ERPPC_rho,2)/2) size(ERPPC_rho,2)]);
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
    saveFile = ['allSessions_ERPPC'];
    saveas(h,fullfile(savePath,[saveFile,'.png']));
    close(h);
end