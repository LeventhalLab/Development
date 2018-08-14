doSetup = false;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/wholeSession';
tWindow = 1;
freqList = logFreqList([3.5 200],30);
freqLabels = num2str(freqList(:),'%2.1f');
pvalThresh = 0.01;
Wlength = 200;

if doSetup
    iSession = 0;
    ERPAC_rho = NaN(numel(selectedLFPFiles),numel(freqList),numel(freqList));
    ERPAC_pval = NaN(numel(selectedLFPFiles),numel(freqList),numel(freqList));
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        sevFile = LFPfiles_local{iNeuron};
        disp(sevFile);
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
        W = calculateComplexScalograms_EnMasse(sevFilt','Fs',Fs,'freqList',freqList);

        for iFreq = 1:numel(freqList)
            disp(['working on ',num2str(freqList(iFreq)),'Hz']);
            for jFreq = iFreq:numel(freqList)
                alpha = abs(squeeze(W(:,:,iFreq))).^2;
                x = angle(squeeze(W(:,:,jFreq)));
                [rho,pval] = circ_corrcl(alpha,x);
                ERPAC_rho(iSession,iFreq,jFreq) = rho;
                ERPAC_pval(iSession,iFreq,jFreq) = pval;
            end
        end
    end
end

rows = 1;
cols = 2;
for iSession = 1:size(ERPAC_rho,1)
    h = figuree(800,350);
    these_rho = squeeze(ERPAC_rho(iSession,:,:));
    these_pval = squeeze(ERPAC_pval(iSession,:,:));
    
    subplot(rows,cols,prc(cols,[1 1]));
    imagesc(these_rho');
    set(gca,'ydir','normal');
    colormap(gca,jet);
    caxis([0 0.01]);
    xticks(1:numel(freqList));
    xticklabels(freqLabels);
    xtickangle(90);
    xlabel('amp (Hz)');
    yticks(1:numel(freqList));
    yticklabels(freqLabels);
    ylabel('phase (Hz)');
    set(gca,'fontsize',7);
    cb = cbAside(gca,['corr'],'k');
    
    subplot(rows,cols,prc(cols,[1 2]));
    imagesc(these_pval);
    set(gca,'ydir','normal');
    colormap(gca,hot);
    caxis([0 1]);
    xticks(1:numel(freqList));
    xticklabels(freqLabels);
    xlabel('amp (Hz)');
    xtickangle(90);
    yticks(1:numel(freqList));
    yticklabels(freqLabels);
    ylabel('phase (Hz)');
    set(gca,'fontsize',7);
    cb = cbAside(gca,['pval'],'k');
    
    set(gcf,'color','w');
    saveFile = [num2str(iSession,'%02d'),'_wholeSessionPAC'];
    saveas(h,fullfile(savePath,[saveFile,'.png']));
    close(h);
end