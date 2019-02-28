load('20190227_RTMTcorr.mat');
load('session_20180919_NakamuraMRL.mat', 'eventFieldnames');

timingFields = {'RT','MT'};
tWindow = 1;
freqList = logFreqList([1 200],30);

cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/corr_colormap.jpg';
cmap = mycmap(cmapPath);

iFreq = 17;
h = ff(1400,800);
rows = 4;
cols = 7;
caxisVals = [-0.3 0.3];
for iTiming = 1:2
    for iEvent = 1:7
        subplot(rows,cols,prc(cols,[iTiming*2-1,iEvent]));
        data = squeeze(all_powerCorrs(iTiming,iEvent,:,:));
        imagesc(data');
        set(gca,'ydir','normal');
        colormap(gca,jupiter);
        caxis(caxisVals);
        title([eventFieldnames{iEvent},' power ' ,timingFields{iTiming}]);
    end
    
    for iEvent = 1:7
        subplot(rows,cols,prc(cols,[iTiming*2,iEvent]));
        data = squeeze(all_phaseCorrs(iTiming,iEvent,:,:));
        imagesc(data');
        set(gca,'ydir','normal');
        colormap(gca,jupiter);
        caxis(caxisVals);
        title([eventFieldnames{iEvent},' phase ' ,timingFields{iTiming}]);
    end
end