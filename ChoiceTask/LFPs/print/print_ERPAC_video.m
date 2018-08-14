savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/ERPAC/video';
tWindow = 1;
freqList = logFreqList([3.5 200],30);

freqIdx = floor(linspace(1,numel(freqList),5));
freqLabels = freqList(freqIdx);
freqLabels = num2str(freqLabels(:),'%2.1f');
Wlength = 200;
rows = 2;
cols = 5;

hs_map = [1 2 3 4 NaN NaN 5 NaN 6 7];
hs = [];

for iSession = 1:size(all_M,1)
    sevFile = LFPfiles_local{selectedLFPFiles(iSession)};
    disp(sevFile);
    [~,name,~] = fileparts(sevFile);
    subjectName = name(1:5);
    
    M = squeeze(all_M(iSession,:,:,:,:));
    h = figuree(1500,600);
    iSubplot = 0;
    for iEvent = hs_map
        iSubplot = iSubplot + 1;
        if isnan(iEvent)
            continue;
        end
        hs(iEvent) = subplot(rows,cols,iSubplot);
        hm = slice(squeeze(M(iEvent,:,:,:)),[],1:Wlength,[]);
        shading interp;
        colormap(jet);
        caxis([0 0.5]);
        set(hm,'FaceAlpha',0.05);
        xlabel('amp (Hz)');
        zlabel('phase (Hz)');
        ylabel('time (s)');
        xticks(freqIdx);
        xticklabels(freqLabels);
        zticks(freqIdx);
        zticklabels(freqLabels);
        yticks([1 round(Wlength/2) Wlength]);
        yticklabels([-tWindow,0,tWindow]);
        set(gca,'fontsize',7);
        title(eventFieldnames{iEvent});
        if iEvent == 7
            cb = cbAside(gca,['corr, all p-vals'],'k');
        end
    end
    set(gcf,'color','w');

    nFrames = 200; % make divisible by 2 for els
    azs = linspace(0,180,nFrames);
    els = linspace(0,18,nFrames/2);
    els = [els fliplr(els)];

    newVideo = VideoWriter(fullfile(savePath,['s',num2str(iSession,'%02d'),'_',subjectName,'_ERPACvideo']),'MPEG-4');
    newVideo.Quality = 90;
    open(newVideo);c
    for iFrame = 1:nFrames
        for iEvent = 1:7
            view(hs(iEvent),[azs(iFrame),els(iFrame)]);
        end
        drawnow;
        F = getframe(h);
        writeVideo(newVideo,F);
    end
    close(newVideo);
    close(h);
end