if ~exist('eventFieldnames')
    load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
end
doSetup = true;
doSave = false;

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/RTMTCorr/bySession';

dirFiles = dir(fullfile(savePath,'*.mat'));
corrFiles = {dirFiles.name};

if doSetup
    all_pow_rho = [];
    all_pow_pval = [];
    all_pha_rho = [];
    all_pha_pval = [];
    for iFile = 1:numel(corrFiles)
        disp(['loading ',num2str(iFile)]);
        load(fullfile(savePath,corrFiles{iFile}));
        all_pow_rho(iFile,:,:,:,:) = all_powerCorrs;
        all_pow_pval(iFile,:,:,:,:) = all_powerPvals;
        all_pha_rho(iFile,:,:,:,:) = all_phaseCorrs;
        all_pha_pval(iFile,:,:,:,:) = all_phasePvals;
    end
end

timingFields = {'RT','MT'};
powerLabel = {'power','phase'};
climVals = [-0.5 0.5;0.15 0.5];
cmap = jupiter;
cmaps = {cmap(1:size(cmap,1),:);cmap(round(size(cmap,1)/2):size(cmap,1),:)};
rows = 4;
cols = 7;
use_rhos = {all_pow_rho;all_pha_rho};
use_pvals = {all_pow_pval;all_pha_pval};
lookatFreqs = [17,6];
freqLabels = {'\beta','\delta'};
pThresh = 0.05;
t = linspace(-1,1,size(all_pha_pval,4));
for iPower = 1:2
    h = ff(1400,800);
    for iTiming = 1:2
        for iEvent = 1:7
            subplot(rows,cols,prc(cols,[iTiming*2-1 iEvent]));
            data = squeeze(mean(use_rhos{iPower}(:,iTiming,iEvent,:,:)));
            imagesc(t,1:numel(freqList),data');
            colormap(gca,cmaps{iPower});
            set(gca,'ydir','normal');
            caxis(climVals(iPower,:));
            xticks([]);
            yticks([]);
            title({eventFieldnames{iEvent},[timingFields{iTiming},' - ',powerLabel{iPower}]});
            if iEvent == 1
                ylabel('Freq (Hz)');
            end
            if iEvent == 7
                cbAside(gca,'r','k');
            end
            
            subplot(rows,cols,prc(cols,[iTiming*2 iEvent]));
            data = squeeze(use_pvals{iPower}(:,iTiming,iEvent,:,lookatFreqs(iPower)));
            pArr = sum(data < pThresh);
            plot(t,pArr,'k-','linewidth',2);
            ylim([0 30]);
            title([freqLabels{iPower},' p < ',num2str(pThresh,'%1.3f')]);
            xlabel('time (s)');
            ylabel('# sessions');
            grid on;
        end
    end
    set(gcf,'color','w');
     if doSave
        saveas(h,fullfile(savePath,['RTMTcorr_fracSessions_',powerLabel{iPower},'.png']));
        close(h);
    end
end