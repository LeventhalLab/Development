if ~exist('eventFieldnames')
    load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
end
freqList = logFreqList([1 200],30);
doLabels = false;
doSave = true;
close all

figPath = '/Users/matt/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
savePath = '/Users/matt/Documents/Data/ChoiceTask/LFPs/perievent/RTMTCorr/bySession';
subplotMargins = [.03 .02;];

dirFiles = dir(fullfile(savePath,'*.mat'));
corrFiles = {dirFiles.name};

if ~exist('all_pow_rho')
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
useEvents = [2:4;4:6];
% cmap = jupiter;
cmap = jet; % resubmission
cmaps = {cmap(1:size(cmap,1),:);cmap(round(size(cmap,1)/2):size(cmap,1),:)}
rows = 2;
cols = size(useEvents,2);
use_rhos = {all_pow_rho;all_pha_rho};
use_pvals = {all_pow_pval;all_pha_pval};
lookatFreqs = [17,6];
freqLabels = {'\beta','\delta'};
pThresh = 0.05;
t = linspace(-1,1,size(all_pha_pval,4));
iRow = 0;

xmarks = round(logFreqList([1 200],6),0);
usexticks = [];
for ii = 1:numel(xmarks)
    usexticks(ii) = closest(freqList,xmarks(ii));
end
for iTiming = 1:2
    h = ff(850,450);
    for iPower = 1:2
        iRow = iRow + 1;
        for iEvent = 1:size(useEvents,2)
            subplot_tight(rows,cols,prc(cols,[iRow iEvent]),subplotMargins);
            % % % %             subplot_tight(rows,cols,prc(cols,[iTiming+iPower iEvent]),subplotMargins);
            data = squeeze(mean(use_rhos{iPower}(:,iTiming,useEvents(iTiming,iEvent),:,:)));
            imagesc(t,1:numel(freqList),data');
            hold on;
            colormap(gca,cmaps{iPower});
            set(gca,'ydir','normal');
            caxis(climVals(iPower,:));
            plot([0,0],ylim,':','color',repmat(0.5,[1 3])); % center line
            xlim([min(t),max(t)]);
            xticks(sort([xlim,0]));
            box on;
            
            % % % %             subplot(rows,cols,prc(cols,[iTiming+1 iEvent]));
            data = squeeze(use_pvals{iPower}(:,iTiming,useEvents(iTiming,iEvent),:,lookatFreqs(iPower)));
            pArr = sum(data < pThresh);
            plot(t,pArr,'k-','linewidth',0.40);
            % % % %             ylim([0 30]);
            
            ylim([1 size(data,1)]);
            yticks(usexticks);
            yticklabels([]);
% % % %             set(gca,'XColor','w');
% % % %             set(gca,'YColor','w');
            
            if doLabels
                ylabel('Freq (Hz)');
                cbAside(gca,'r','k');
                title({eventFieldnames{useEvents(iTiming,iEvent)},[timingFields{iTiming},' - ',powerLabel{iPower}]});
                % % % %                 title([freqLabels{iPower},' p < ',num2str(pThresh,'%1.3f')]);
                xlabel('time (s)');
                grid on;
            else
                xticklabels([]);
                yticklabels([]);
            end
        end
    end
    tightfig;
    set(gcf,'color','w');
    if doSave
        setFig('','',[1.5,2.4]);
        print(gcf,'-painters','-depsc',fullfile(figPath,['RTMTCORR_sessionLines',timingFields{iTiming},'.eps']));
        % % % %     saveas(h,fullfile(savePath,['SUASESSTRIAL.png']));
        close(h);
    end
end