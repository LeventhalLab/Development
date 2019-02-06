savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/perievent/temp';
close all;
tWindow = 0.5;
t = linspace(-tWindow,tWindow,1000);
rows = 3;
cols = 8;

loadedFile = [];
for iNeuron = 1:366
    h = ff(1400,700);
    
    tsFile = fullfile(dataPath,['tsPeths_u',num2str(iNeuron,'%03d')]);
    load(tsFile,'tsPeths');
    LFPfile = fullfile(dataPath,['Wz_phase_s',num2str(LFP_lookup(iNeuron),'%03d')]);
    if isempty(loadedFile) || ~strcmp(loadedFile,LFPfile)
        fprintf('--> loading LFP...\n');
        load(LFPfile,'Wz_phase');
        loadedFile = LFPfile;
    end
        
    SDE = [];
    for iTrial = 1:size(tsPeths,1)
        for iEvent = 1:size(tsPeths,2)
            ts = tsPeths{iTrial,iEvent};
            SDE(iTrial,iEvent,:) = spikeDensityEstimate_periEvent(ts,tWindow);
        end
    end
    zMean = mean(mean(SDE(:,1,:)));
    zStd = mean(std(SDE(:,1,:),[],3));
    zSDE = (SDE - zMean) ./ zStd;
    
    mean_zSDE = squeeze(mean(zSDE));

    for iEvent = 1:8
        subplot(rows,cols,prc(cols,[1 iEvent]));
        rasterData = tsPeths(:,iEvent);
        rasterData = rasterData(~cellfun('isempty',rasterData)); % remove empty rows (no spikes)
        rasterData = makeRasterReadable(rasterData,100); % limit to 100 data points
        plotSpikeRaster(rasterData,'PlotType','scatter','AutoLabel',false);
        ylabel('trials by RT');
        xticks([-tWindow,0,tWindow]);
        ylim([1,size(tsPeths,1)]);
        yticks(ylim);
        title({eventFieldnames_wFake{iEvent},'raster'});
    
        subplot(rows,cols,prc(cols,[2 iEvent]));
        plot(t,mean_zSDE(iEvent,:),'lineWidth',2);
        ylim([-2 2]);
        yticks(sort([ylim 0]));
        xticks([-tWindow,0,tWindow]);
        ylabel('Z');
        grid on;
        title('zSDE');
        
        phaseMat = [];
        for iFreq = 1:size(Wz_phase,4)
            data = circ_mean(squeeze(Wz_phase(iEvent,:,:,iFreq)),[],2);
            phaseMat(iFreq,:) = data;
        end
        subplot(rows,cols,prc(cols,[3 iEvent]));
        imagesc(t,1:30,phaseMat);
        set(gca,'ydir','normal');
        cmap = cmocean('phase');
        colormap(cmap);
        title('phase');
        xlabel('time (s)');
        ylabel('freq');
    end
    uid = ['u',num2str(iNeuron,'%03d')];
    addNote(h,{analysisConf.sessionNames{iNeuron},uid});
    set(gcf,'color','w');
    saveas(h,fullfile(savePath,[uid,'.png']));
    close(h);
end