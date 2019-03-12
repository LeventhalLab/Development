% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
doSetup = true;
doSave = false;

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/RTMTCorr/bySession';

% corrFiles = {'201903_RTMTcorr_R0182_nSessions01.mat',...
% '201903_RTMTcorr_R0154_nSessions05.mat',...
% '201903_RTMTcorr_R0142_nSessions13.mat',...
% '201903_RTMTcorr_R0117_nSessions07.mat',...
% '201903_RTMTcorr_R0088_nSessions04.mat'};

% corrFiles = {'201903_RTMTcorr_R0142_nSessions13.mat','201903_RTMTcorr_R0142_nSessions13.mat'};
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
climVals = [-0.5 0.5;0 0.5];
cmap = jupiter;
cmaps = {cmap(1:size(cmap,1),:);cmap(round(size(cmap,1)/2):size(cmap,1),:)};
h = ff(1400,800);
rows = 4;
cols = 7;
use_rhos = {all_pow_rho;all_pha_rho};
iSubplot = 0;
for iPP = 1:2
    for iTiming = 1:2
        for iEvent = 1:7
            iSubplot = iSubplot + 1;
            subplot(rows,cols,iSubplot);
            data = squeeze(mean(use_rhos{iPP}(:,iTiming,iEvent,:,:)));
            imagesc(data');
            colormap(gca,cmaps{iPP});
            set(gca,'ydir','normal');
            caxis(climVals(iPP,:));
            xticks([]);
            yticks([]);
            title({eventFieldnames{iEvent},[timingFields{iTiming},' - ',powerLabel{iPP}]});
            if iEvent == 1
                ylabel('Freq (Hz)');
            end
            if iEvent == 7
                cbAside(gca,'r','k');
            end
        end
    end
end
addNote(gcf,'per-subject average (n = 5)');
set(gcf,'color','w');
if doSave
    saveas(h,fullfile(savePath,'RTMTcorr_perSubject_average_n5.png'));
    close(h);
end