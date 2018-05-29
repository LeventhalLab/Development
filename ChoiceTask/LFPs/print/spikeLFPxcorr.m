% function spikeLFPxcorr(LFPfiles,all_trials,all_SDEs_zscore,eventFieldnames)
% sevFile = '';
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/xcorrTrials';
tWindow = 1;
tWindow_vis = 1;
cols = 7;
pxHeight = 150;
bandLabels = {'delta','theta','beta','gamma'};
bandIds = {};
bandIds{1} = 1:10;
bandIds{2} = 15:17;
bandIds{3} = 18:23;
bandIds{4} = 25:27;
band_tWindow_vis = [1,.25,.1,.05];
            
rows = numel(bandLabels)+3;

tickIds = [1 10 17 23 26 30]; % !! HARDCODED FOR NOW

for iNeuron = dirSelUnitIds%1:numel(LFPfiles)
    saveFolder = fullfile(savePath,['u',num2str(iNeuron,'%03d')]);
    if ~exist(saveFolder)
        mkdir(saveFolder)
    end
    % only unique sev files
    if ~strcmp(sevFile,LFPfiles{iNeuron})
        sevFile = LFPfiles{iNeuron};
        [~,name,~] = fileparts(sevFile);
        subjectName = name(1:5);
        curTrials = all_trials{iNeuron};
        [W,freqList,allTimes] = getW(sevFile,curTrials,eventFieldnames);
    end
    curSDEs = all_SDEs_zscore{iNeuron};
    for iTrial = 1:size(W,3)
        h = figuree(1300,pxHeight*rows);
        ax = [];
        caxisArr = [];
        for iEvent = 1:cols
            curSDE = curSDEs{iTrial,iEvent};
            
            ax(iEvent) = subplot(rows,cols,prc(cols,[1 iEvent]));
            scaloData = squeeze(abs(W(iEvent,:,iTrial,:)));
            phaseData = squeeze(angle(W(iEvent,:,iTrial,:)));
            disp_scalo(scaloData,freqList,tWindow);
            % format
            xticks([-tWindow_vis 0 tWindow_vis]);
            xlim([-tWindow_vis tWindow_vis]);
            titleText = eventFieldnames{iEvent};
            ylabelText = {['#',num2str(iTrial)],['RT ',num2str(allTimes(iTrial),'%0.3f'), 's'],'Freq (Hz)'};
            if iEvent == 1
                ylabel(ylabelText);
                title({['unit ',num2str(iNeuron,'%03d')],eventFieldnames{iEvent}});
            else
                title({'',eventFieldnames{iEvent}});
            end
            yticks(tickIds);
            ytickLabels = round(freqList(tickIds));
            yticklabels(ytickLabels);
            
            caxisArr(iEvent,:) = caxis;
            
            % SDE
            sampleSDE = round(linspace(1,size(scaloData,1),numel(curSDE)));
            t_SDE = linspace(-tWindow,tWindow,numel(sampleSDE));
            
            subplot(rows,cols,prc(cols,[2 iEvent]));
            plot(t_SDE,curSDE,'k','linewidth',2);
            ylabel('SDE (Z)');
            ylim([-2 4]);
            yticks(sort([0 ylim]));
            grid on;
            
            for iBand = 1:numel(bandLabels)
                subplot(rows,cols,prc(cols,[iBand+2 iEvent]));
                yyaxis left;
                plot(t_SDE,circ_mean(phaseData(sampleSDE,bandIds{iBand}),[],2),'linewidth',2);
                ylabel('phase');
                ylim([-pi pi]);
                yticks(sort([0 ylim]));
                yticklabels({'-pi','0','pi'});

                yyaxis right;
                plot(t_SDE,mean(scaloData(sampleSDE,bandIds{iBand}),2),'linewidth',2); % beta
                ylabel('power');
                ylim([0 100]);
                yticks(ylim);
                
                
                xticks([-band_tWindow_vis(iBand) 0 band_tWindow_vis(iBand)]);
                xlim([-band_tWindow_vis(iBand) band_tWindow_vis(iBand)]);
                grid on;
                title(bandLabels{iBand});
            end
            
            scaloData_xcorr = [];
            for iBand = 1:size(scaloData,2)
                [r,lags] = xcorr(scaloData(sampleSDE,iBand)',curSDE);
                scaloData_xcorr(:,iBand) = r;
            end
            subplot(rows,cols,prc(cols,[numel(bandLabels)+3 iEvent]));
            disp_scalo(scaloData_xcorr,freqList,tWindow*2);
            xticks([-tWindow_vis*2 0 tWindow_vis*2]);
            xlim([-tWindow_vis*2 tWindow_vis*2]);
            yticks(tickIds);
            yticklabels(ytickLabels);
            if iEvent == 1
                ylabel('Freq (Hz)');
            end
            caxis(1e4*[-6 6]);
            title('xcorr');
            xlabel('Time (s)');
        end
        
        for iEvent = 1:cols
            subplot(ax(iEvent));
            caxis([mean(caxisArr(:,1)) mean(caxisArr(:,2))])
        end
        
        set(gcf,'color','w');
        saveFile = ['unit',num2str(iNeuron,'%03d'),'_trial',num2str(iTrial,'%03d'),'.png'];
        saveas(h,fullfile(saveFolder,saveFile));
        close(h);
    end
end
                
% end % end function

function disp_scalo(scaloData,freqList,tWindow)
t = linspace(-tWindow,tWindow,size(scaloData,1));
imagesc(t,1:numel(freqList),scaloData');
set(gca,'YDir','normal');
colormap(jet);
% set(gca,'ColorScale','log');
grid on;
end