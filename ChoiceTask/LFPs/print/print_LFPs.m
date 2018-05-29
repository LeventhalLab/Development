function print_LFPs(LFPfiles,all_trials,eventFieldnames,tWindow_vis)
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP';
sevFile = '';
tWindow = 1;
pxHeight = 150;

allFrames = [];
for iNeuron = 1:numel(LFPfiles)
    % only unique sev files
    if strcmp(sevFile,LFPfiles{iNeuron})
        continue;
    end
    sevFile = LFPfiles{iNeuron};
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    curTrials = all_trials{iNeuron};
    [W,freqList,allTimes] = getW(sevFile,curTrials,eventFieldnames);
    tickIds = [1 10 17 23 26 30]; % !! HARDCODED FOR NOW
    
    % all trials (single sheet or many?)
    cols = size(W,1);
    rows = size(W,3) + 1;
    
    for iType = 1%1:2
        switch iType
            case 1
                doPhase = false;
                typeLabel = 'AMPLI';
            case 2
                doPhase = true;
                typeLabel = 'PHASE';
        end
        for iRow = 1%:rows
            h = figuree(1300,pxHeight);
            iTrial = iRow - 1;
            caxisArr = zeros(cols,2);
            ax = [];
            for iEvent = 1:cols
                ax(iEvent) = subplot(1,cols,iEvent);
                if iRow == 1
                    W_event = squeeze(W(iEvent,:,:,:));
                    if doPhase
                        scaloData = squeeze(circ_r(angle(W_event),[],[],2));
                    else
                        scaloData = squeeze(mean(abs(W_event),2));
                    end
                    ylabelText = 'all trials';
                    titleText = eventFieldnames{iEvent};
                else
                    if doPhase
                        scaloData = squeeze(angle(W(iEvent,:,iTrial,:)));
                    else
                        scaloData = squeeze(abs(W(iEvent,:,iTrial,:)));
                    end
                    ylabelText = {['#',num2str(iTrial)],['RT ',num2str(allTimes(iTrial),'%0.3f'), 's']};
                    titleText = '';
                end
                disp_scalo(scaloData,freqList,tWindow);
                hold on;
                xticks([-tWindow_vis 0 tWindow_vis]);
                xlim([-tWindow_vis tWindow_vis]);
                if doPhase && iRow > 1
                    caxisVals = [-pi pi];
                    cmocean('phase');
                    set(gca,'ColorScale','linear');
                else
                    if doPhase
                        caxisVals = [0 1];
                        caxis(caxisVals);
                        colormap(hot);
                    else
                        caxisArr(iEvent,:) = caxis;
                        colormap(jet);
                    end
                    set(gca,'ColorScale','log');
                end
                yticks(tickIds);
                if iEvent == 1
                    ylabel(ylabelText);
                    ytickLabels = round(freqList(tickIds));
                    yticklabels(ytickLabels);
                else
                    ylabel({});
                    yticklabels({});
                end
                title({[subjectName,' u',num2str(iNeuron,'%03d')],titleText});
            end
            if ~doPhase
                for iEvent = 1:cols
                    subplot(ax(iEvent));
                    caxis([mean(caxisArr(:,1)) mean(caxisArr(:,2))])
                end
            end
            set(h,'color','w');
            hFrame = getframe(h);
            allFrames = [allFrames;hFrame.cdata];
            close(h);
        end
    end
end
saveFile = ['unit_',num2str(iNeuron,'%03d'),'_',typeLabel,'_',num2str(tWindow_vis*1000),'ms.png'];
imwrite(allFrames,fullfile(savePath,saveFile));
end % end function

function disp_scalo(scaloData,freqList,tWindow)
t = linspace(-tWindow,tWindow,size(scaloData,1));
imagesc(t,1:numel(freqList),scaloData');
set(gca,'YDir','normal');
grid on;
end

% % function savePDF(pxHeight)
% % set(gcf,'color','w');
% % set(gcf, 'PaperUnits','centimeters');
% % pixelposition = getpixelposition(gcf);
% % curPaperSize = get(gcf,'PaperSize'); % this is always 8.5x11
% % figwidth = 17.6;
% % figheight = (figwidth / pixelposition(3)) * pxHeight;
% % set(gcf, 'PaperSize', [figwidth, figheight]);
% % set(gcf, 'PaperPositionMode', 'manual');
% % set(gcf, 'PaperPosition',[0 0 figwidth figheight]);
% % set(findall(gcf,'-property','FontSize'),'FontSize',8);
% % end
