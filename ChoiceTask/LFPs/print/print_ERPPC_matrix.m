savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/ERPPC/matrix';
tWindow = 1;
freqList = logFreqList([3.5 200],30);

freqIdx = floor(linspace(1,numel(freqList),5));
freqLabels = freqList(freqIdx);
freqLabels = num2str(freqLabels(:),'%2.0f');
Wlength = 200;
t = linspace(-tWindow,tWindow,Wlength);

cols = 7;
rows = 9;
rowWindow = 0.25;
rowTimes = linspace(-rowWindow,rowWindow,rows);
for iSession = 1:size(all_M_phase,1)
    sevFile = LFPfiles_local{selectedLFPFiles(iSession)};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    
    M = squeeze(all_M_phase(iSession,:,:,:,:));
    h = figuree(800,900);
    for iRow = 1:rows
        for iEvent = 1:7
            subplot(rows,cols,prc(cols,[iRow iEvent]));
            M_slice = squeeze(M(iEvent,closest(t,rowTimes(iRow)),:,:));
            imagesc(M_slice);
            set(gca,'ydir','normal');
            colormap(jet);
            caxis([-0.5 0.5]);
            xticks(freqIdx);
            xticklabels(freqLabels);
            yticks(freqIdx);
            yticklabels(freqLabels);
            set(gca,'fontsize',6);
            grid on;
            if iRow == 1
                title({eventFieldnames{iEvent},['t = ',num2str(rowTimes(iRow),'%1.2f')]});
            else
                title(['t = ',num2str(rowTimes(iRow),'%1.3f')]);
            end
            if iRow == rows
                xlabel('amp (Hz)');
            end
            if iEvent == 1
                ylabel('phase (Hz)');
            end
            if iEvent == 7
                cb = cbAside(gca,['corr, all p-vals'],'k');
            end
        end
    end
    set(gcf,'color','w');
    saveFile = ['s',num2str(iSession,'%02d'),'_',subjectName,'_ERPPCmatrix'];
    saveas(h,fullfile(savePath,[saveFile,'.png']));
    close(h);
end