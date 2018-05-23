function print_LFPs(LFPfiles,all_trials,eventFieldnames)
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/LFP';
sevFile = '';
tWindow = 1;
doPhase = true;

for iNeuron = 1:numel(LFPfiles)
    % only unique sev files
    if strcmp(sevFile,LFPfiles{iNeuron})
        continue;
    end
    sevFile = LFPfiles{iNeuron};
    curTrials = all_trials{iNeuron};
    [W,freqList,allTimes] = getW(sevFile,curTrials,eventFieldnames);
    tickIds = [1 10 17 23 26 30]; % !! HARDCODED FOR NOW
    
    % all trials (single sheet or many?)
    cols = size(W,1);
    rows = size(W,3) + 1;
    pxHeight = 150;
    
    for iType = 1:2
        allFrames = [];
        switch iType
            case 1
                doPhase = false;
                typeLabel = 'AMPLI';
            case 2
                doPhase = true;
                typeLabel = 'PHASE';
        end
        for iRow = 1:rows
            h = figuree(1300,pxHeight);
            iTrial = iRow - 1;
            for iEvent = 1:cols
                subplot(1,cols,iEvent);
                if iRow == 1
                    W_event = squeeze(W(iEvent,:,:,:));
                    if doPhase
                        caxisVals = [-pi pi];
                        scaloData = squeeze(circ_mean(W_event,[],2));
                    else
                        caxisVals = [0 75];
                        scaloData = squeeze(mean(abs(W_event),2));
                    end
                    ylabelText = 'all trials';
                    titleText = eventFieldnames{iEvent};
                else
                    if doPhase
                        caxisVals = [-pi pi];
                        scaloData = squeeze(angle(W(iEvent,:,iTrial,:)));
                    else
                        caxisVals = [0 125];
                        scaloData = squeeze(abs(W(iEvent,:,iTrial,:)));
                    end
                    ylabelText = {['#',num2str(iTrial)],['RT ',num2str(allTimes(iTrial),'%0.3f'), 's']};
                    titleText = '';
                end
                disp_scalo(scaloData,freqList,tWindow);
                if doPhase
                    cmocean('phase');
                    set(gca,'ColorScale','linear');
                    caxis(caxisVals);
                else
                    colormap(jet);
                    set(gca,'ColorScale','log');
                    caxis(caxisVals);
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
                title(titleText);
            end
            set(h,'color','w');
            hFrame = getframe(h);
            allFrames = [allFrames;hFrame.cdata];
            close(h);
        end
        saveFile = ['unit_',num2str(iNeuron,'%03d'),'_',typeLabel,'.png'];
        imwrite(allFrames,fullfile(savePath,saveFile));
    end
end
end % end function

function disp_scalo(scaloData,freqList,tWindow)
t = linspace(-tWindow,tWindow,size(scaloData,1));
imagesc(t,1:numel(freqList),scaloData');
xlim([-tWindow tWindow]);
xticks([-tWindow 0 tWindow]);
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
