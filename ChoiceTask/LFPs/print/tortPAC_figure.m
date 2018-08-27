doSetup = true;
doSave = true;
savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/PAC/tortMethod/figures';
ifp = 1:3;
ifAs = [4,5,6,7,9];
colors = jet(numel(ifAs));

bandChars = {'\theta','\alpha','\beta','\gamma_L','\gamma_H'};
bandLabels = {['\delta \otimes ',bandChars{1}],...
    ['\delta \otimes ',bandChars{2}]...
    ['\delta \otimes ',bandChars{3}]...
    ['\delta \otimes ',bandChars{4}]...
    ['\delta \otimes ',bandChars{5}]};

if doSetup
    MI_bands = [];

    h = figuree(1400,185);
    rows = 1;
    cols = 7;
    freqLabels = num2str(freqList(:),'%2.0f');
    for iEvent = 1:size(all_MImatrix,2)
        zMean = squeeze(nanmean(all_MImatrix_surr(:,iEvent,:,:)));
        zStd = squeeze(nanstd(all_MImatrix_surr(:,iEvent,:,:)));

        subplot(rows,cols,prc(cols,[1 iEvent]));
        normMat = (squeeze(nanmean(all_MImatrix(:,iEvent,:,:))) - zMean)';
    %     Zmat = (Zmat - zMean) ./ zStd;
        imagesc(normMat);

        for ifA = 1:numel(ifAs)
            MI_bands(ifA,iEvent) = nanmean(normMat(ifAs(ifA),ifp));
        end

        colormap(gca,hot);
        set(gca,'ydir','normal');
        caxis([0 0.05]);
        xticks(1:numel(freqList));
        xticklabels(freqLabels);
        xtickangle(270);
        xlabel('phase (Hz)');
        yticks(1:numel(freqList));
        yticklabels(freqLabels);
        if iEvent == 1
            ylabel('amp (Hz)');
        end
        if iEvent == 7
            cb = cbAside(gca,'Norm. MI','k');
        end
        set(gca,'FontSize',12);
        title(eventFieldnames{iEvent},'FontSize',12);
        
        if iEvent == 1
            txy = 0.3;
            hold on;
            rectangle('Position',[1 1 numel(ifp)-1 size(normMat,1)-1],'EdgeColor','w','lineWidth',2);
            text(numel(ifp)+txy,1+txy,'\delta','color','w');
            for ifA = 1:numel(ifAs)
                plot(1:size(normMat,1)-1,repmat(ifAs(ifA),[1,size(normMat,1)-1]),'color',colors(ifA,:),'lineWidth',2);
                text(size(normMat,1)-1+txy,ifAs(ifA),bandChars{ifA},'color',colors(ifA,:));
            end
        end
    end
    set(gcf,'color','w');
    if doSave
        saveFile = 'allEvents_mi_matrix.png';
        saveas(h,fullfile(savePath,saveFile));
        close(h);
    end
end

h = figuree(700,200);
for ifA = 1:numel(ifAs)
    subplot(1,numel(ifAs),ifA);
    bar(MI_bands(ifA,:),'FaceColor',colors(ifA,:));
    set(gca,'FontSize',12);
    xticklabels(eventFieldnames);
    xtickangle(270);
    xa = get(gca,'XAxis');
    xa.FontSize = 8;
    ylim([-0.005 0.03]);
    yticks(sort([ylim 0]));
    if ifA == 1
        yticklabels(sort([ylim 0]));
        ylabel('Norm. MI');
    else
        yticklabels({});
    end
    title(bandLabels{ifA});
end
set(gcf,'color','w');
if doSave
    saveFile = 'allBands_mi_x_event.png';
    saveas(h,fullfile(savePath,saveFile));
    close(h);
end