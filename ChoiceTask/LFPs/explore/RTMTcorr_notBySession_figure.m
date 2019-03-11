% load('session_20180919_NakamuraMRL.mat', 'selectedLFPFiles')
% load('session_20180919_NakamuraMRL.mat', 'LFPfiles_local')
% load('session_20180919_NakamuraMRL.mat', 'eventFieldnames')
% load('201903_RTMTcorr_iSession30_nSessions30.mat')

% close all;
doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/RTMTCorr';
baseName = 'RTMTcorr_R0182_wPvalLines_actualTiming';

tWindow = 1;
freqList = logFreqList([1 200],30);

timingFields = {'RT','MT'};

rows = 4;
cols = 1;
pets = repmat(0.5,[2,7]);
pets(1,3) = 1;
pets(2,5) = 1;
rInt = 10;
titleLabels = {'power','phase'};

ylimVals = [-0.5 0.5;0 0.5];
climVals = [-0.5 0.5];
cmap = jupiter;
nSmooth = 20;
lineWidth = 2;
showFreqs = [2,6,18.6,55,120];
colors = lines(numel(showFreqs));
pThresh = 0.001;
pMarks = linspace(0.4,0.5,numel(showFreqs));

% load('201903_RTMTcorr_iSession30_nSessions30.mat');

% % % % for iSession = 1:30
% % % %     load(fullfile(savePath,['201903_RTMTcorr_iSession',num2str(iSession,'%02d'),'_nSessions01.mat']));
% % % %     sevFile = LFPfiles_local{selectedLFPFiles(iSession)};
% % % %     [~,name,~] = fileparts(sevFile);
    
for iTiming = 1:2
    % pc = pval_adjust(data_pval,'bonferroni'); % same as multiplying by 30 and bounding to [0..1]
    timeCorrs_power_rho = squeeze((all_powerCorrs(iTiming,:,:,:)));
    timeCorrs_power_pval = squeeze((all_powerPvals(iTiming,:,:,:)))*30;
    timeCorrs_phase_rho = squeeze((all_phaseCorrs(iTiming,:,:,:)));
    timeCorrs_phase_pval = squeeze((all_phasePvals(iTiming,:,:,:)))*30;
    useCorrs_rho = {timeCorrs_power_rho,timeCorrs_phase_rho};
    useCorrs_pval = {timeCorrs_power_pval,timeCorrs_phase_pval};
    
    h = ff(1100,800);
    t = linspace(-tWindow,tWindow,size(timeCorrs_power_rho,2));

    % imagesc
    subIdxs = [1,3];
    for iPlot = 1:2
        subplot(rows,cols,prc(cols,[subIdxs(iPlot),1]));
        corrMat = [];
        rIdx = 1;
        for iEvent = 1:7
            data_rho = squeeze(useCorrs_rho{iPlot}(iEvent,:,:));
            startIdx = closest(t,-pets(iTiming,iEvent));
            endIdx = closest(t,pets(iTiming,iEvent));
            corrMat(rIdx:rIdx+(endIdx-startIdx),:) = data_rho(startIdx:endIdx,:);
            rIdx = rIdx + (endIdx-startIdx) + rInt;
        end
        imagesc(corrMat');
        colormap(gca,cmap);
        set(gca,'ydir','normal');
        caxis(climVals);
        xticks([]);
        yticks([]);
        ylabel('Freq (Hz)');
        title([timingFields{iTiming},' ',titleLabels{iPlot}]);
        box off;
        cbAside(gca,'r','k');
    end

    % line plot
    subIdxs = [2,4];
    for iPlot = 1:2
        subplot(rows,cols,prc(cols,[subIdxs(iPlot),1]));
        lns = [];

        for iFreq = 1:numel(showFreqs)
            rIdx = 1;
            for iEvent = 1:7
                data_rho = smooth(squeeze(useCorrs_rho{iPlot}(iEvent,:,closest(freqList,showFreqs(iFreq)))),nSmooth);
                data_pval = squeeze(useCorrs_pval{iPlot}(iEvent,:,closest(freqList,showFreqs(iFreq))))';
                data_pval_thresh = data_pval < pThresh;
                
                startIdx = closest(t,-pets(iTiming,iEvent));
                endIdx = closest(t,pets(iTiming,iEvent));
                data_pval_thresh_xr = data_pval_thresh(startIdx:endIdx);
                xr = rIdx:rIdx+(endIdx-startIdx);
                lns(iFreq) = plot(xr,data_rho(startIdx:endIdx),'linewidth',lineWidth,'color',colors(iFreq,:));
                hold on;
                xr_p = xr(find(data_pval_thresh_xr));
                if ~isempty(xr_p)
                    plot(xr_p,repmat(pMarks(iFreq),size(xr_p)),'linewidth',lineWidth,'color',colors(iFreq,:));
                end
                % lines/labels
                if iFreq == 1
                    centerIdx = rIdx + round((endIdx-startIdx)/2);
                    plot([centerIdx,centerIdx],ylimVals(iPlot,:),':','color',repmat(0.5,[1,3]));
                    text(centerIdx,min(ylimVals(iPlot,:))-diff(ylimVals(iPlot,:))*.1,eventFieldnames{iEvent},'horizontalAlignment','center');
                end
                rIdx = rIdx + (endIdx-startIdx) + rInt;
            end
        end
        text(20,mean(pMarks),sprintf('p < %1.3f',pThresh));
        if iPlot == 1
            ys = repmat(min(pMarks)-diff(ylimVals(iPlot,:))*.1,[1,2]);
            plot([3 97],ys,'k-','lineWidth',5);
            text(100,ys(1),'1s');
        end
        xlim([1 rIdx-rInt]);
        xticks([]);
        ylim(ylimVals(iPlot,:));
        yticks(sort(unique([0,ylim])));
        ylabel('r');
        box off;
        if iPlot == 2
% %             legend(lns,{'\delta','\theta','\beta','\gamma_L','\gamma_h'});
            legend(lns,{'\delta',...
                '\theta',...
                '\beta',...
                '\gamma_L',...
                '\gamma_h'});
        end
    end
    %     tightfig;
    set(gcf,'color','w');
% % % %     saveFile = ['RTMTcorr_',name(1:5),'_iSession',num2str(iSession,'%02d'),'_wPvalLines_',timingFields{iTiming}];
    saveFile = [baseName,timingFields{iTiming}];
    addNote(h,saveFile);
    if doSave
        saveas(h,fullfile(savePath,[saveFile,'.png']));
        close(h);
    end
end

% % % % end