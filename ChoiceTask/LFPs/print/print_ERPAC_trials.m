doSetup = true;
doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/ERPAC/trials';
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
for iNeuron = selectedLFPFiles'
    iSession = iSession + 1;

    sevFile = LFPfiles_local{iNeuron};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    curTrials = all_trials{iNeuron};
    [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
    [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile);
    W = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    [Wz_power,Wz_phase] = zScoreW(W,Wlength); % power Z-score
%     [Wz_power,keepTrials] = removeWzTrials(Wz_power,zThresh);
%     Wz_phase = Wz_phase(:,:,keepTrials,:);
%     allTimes = allTimes(keepTrials);

    for iTrial = 1:size(Wz_phase,3)
        ERPAC_rho = NaN(size(Wz_power,1),size(Wz_power,2),size(Wz_power,4),size(Wz_power,4));
        ERPAC_pval = NaN(size(Wz_power,1),size(Wz_power,2),size(Wz_power,4),size(Wz_power,4));
        for iEvent = 1:size(Wz_power,1)
            for iBin = 1:size(Wz_power,2)
                for iFreq = 1:numel(freqList)
                    for jFreq = iFreq:numel(freqList)
                        alpha = squeeze(Wz_phase(iEvent,iBin,iTrial,iFreq));
                        x = squeeze(Wz_power(iEvent,iBin,iTrial,jFreq));
                        [rho,pval] = circ_corrcl(alpha,x);
                        ERPAC_rho(iEvent,iBin,iFreq,jFreq) = rho;
                        ERPAC_pval(iEvent,iBin,iFreq,jFreq) = pval;
                    end
                end
            end
        end


        t = linspace(-1,1,size(ERPAC_rho,2));
        M = [];
        for iBin = 1:size(ERPAC_rho,2)
            for iEvent = 1:7
                ERPAC_matrix = squeeze(ERPAC_rho(iEvent,iBin,:,:));
                ERPAC_matrix_pval = squeeze(ERPAC_pval(iEvent,iBin,:,:)) < pvalThresh;
                im = (ERPAC_matrix_pval.*ERPAC_matrix)';
    % %             im = ERPAC_matrix;
                im(im == 0) = NaN;
                M(iEvent,iBin,:,:) = im;
            end
        end


        h = figuree(1500,550);
        rows = 3;
        cols = 7;
        for iRow = 1:rows
            for iEvent = 1:cols
                subplot(rows,cols,prc(cols,[iRow,iEvent]));
                hm = slice(squeeze(M(iEvent,:,:,:)),[],1:size(ERPAC_rho,2),[]);
    % %             [xs,ys,zs] = ndgrid( 1:25 , 1:50 , 1:4 ) ;
                shading interp;
                colormap(jet);
                caxis([0 0.5]);
                set(hm,'FaceAlpha',0.1);
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
        end
        set(gcf,'color','w');

        saveFile = [subjectName,'_s',num2str(iSession,'%02d'),'_t',num2str(iTrial,'%03f'),'_ERPAC'];
        saveas(h,fullfile(savePath,[saveFile,'.png']));
        close(h);
    end
end