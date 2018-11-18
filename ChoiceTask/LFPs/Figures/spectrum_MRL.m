% load('fig__spectrum_MRL_20181108');
% raw data was compiled with LFP_byX.m (doSetup = true)
% freqList = logFreqList([1 200],30);
doSave = false;
figPath = '/Users/mattgaidica/Box Sync/Leventhal Lab/Manuscripts/Mthal LFPs/Figures';
subplotMargins = [.05 .02];

eventfields = {'Cue','Nose In','Tone','Nose Out','Side In','Side Out','Reward'};
h = ff(1200,450);
rows = 2;
cols = 7;
caxisVals = [-0.5 1];
scaloPower = squeeze(median(session_Wz_power(:,:,:,:)));
scaloPhase = squeeze(median(session_Wz_phase(:,:,:,:)));
scaloRayleigh = squeeze(median(session_Wz_rayleigh_pval(:,:,:,:)));

for iEvent = 1:7
    subplot_tight(rows,cols,prc(cols,[1,iEvent]),subplotMargins);
    imagesc(linspace(-1,1,size(scaloPower,2)),1:numel(freqList),squeeze(scaloPower(iEvent,:,:))');
    colormap(gca,jet);
    caxis(caxisVals);
    xlim([-1 1]);
    xticks(0);
    xticklabels([]);
    yticks([]);
    set(gca,'YDir','normal');
    box off;
    grid on;
    
    subplot_tight(rows,cols,prc(cols,[2,iEvent]),subplotMargins);
    imagesc(linspace(-1,1,size(scaloPhase,2)),1:numel(freqList),squeeze(scaloPhase(iEvent,:,:))');
    colormap(gca,hot);
    caxis([0 1]);
    xlim([-1 1]);
    xticks(0);
    xticklabels([]);
    yticks([]);
    set(gca,'YDir','normal');
    box off;
    grid on;
end
tightfig;
setFig('','',[2,4]);
if doSave
    print(gcf,'-painters','-depsc',fullfile(figPath,'spectrum_MRL.eps'));
    close(h);
end

if doSave
    h = ff(1200,450);
    subplot_tight(rows,cols,7,subplotMargins);
    colormap(gca,jet);
    cb = colorbar;
    cb.Ticks = [];

    subplot_tight(rows,cols,14,subplotMargins);
    colormap(gca,hot);
    cb = colorbar;
    cb.Ticks = [];
    if doSave
        print(gcf,'-painters','-depsc',fullfile(figPath,'spectrum_MRL_colorbars.eps'));
        close(h);
    end
end