nasPath = '/Volumes/RecordingsLeventhal2/ChoiceTask';
analysis_storage_dir = '/Volumes/Tbolt_02/VM thal analysis';

sessions_to_analyze = {'R0088_20151030a','R0088_20151031a','R0088_20151101a','R0088_20151102a',...
                       'R0117_20160503a','R0117_20160503b','R0117_20160504a','R0117_20160505a','R0117_20160506a','R0117_20160508a','R0117_20160510a'};

lfpWire = [44,39,40,39,93,120,100,93,120,93,120];
plot_t_limits = [-1,1];

analysisConf = exportAnalysisConfv2('R0088',nasPath);
numSurrogate_xcorrs = 100;
fpass = [16 25];

% compiles all waveforms by averaging all waveforms
% compileOFSWaveforms(waveformDir);
% compares some of the unit properties in a scatter plot
% compareOFSWaveforms(csvWaveformFiles);
tWindow = 2.5; % for scalograms, xlim is set to -1/+1 in formatting
xcorrWindow = 2;  % use this to pull out just +/- 1 second around each event
plotEventIds = [1 2 4 3 5 6 8]; % removed foodClick because it mirrors SideIn
sevFile = '';

plot_xlim = [-0.5,0.5];
num_cols = 3;
num_rows = 4;
plots_per_page = num_cols * num_rows;

numPlots = 0;
numPages = 0;
for iNeuron=1:size(analysisConf.neurons,1)
    
    neuronName = analysisConf.neurons{iNeuron};
    ratID = neuronName(1:5);
    sessionName = analysisConf.sessionNames{iNeuron};
    sessionIdx = find(strcmp(sessionName,sessions_to_analyze));
    cur_lfpWire = lfpWire(sessionIdx);
    
    disp(['Working on ',neuronName]);
    [tetrodeName,tetrodeId,tetrodeChs] = getTetrodeInfo(neuronName);
    
    % filenames to store the analyzed scalogram data
    xcorr_name = [neuronName '_spike_beta_xcorr_trialsOnly_bursts.mat'];
    xcorr_subject_dir = fullfile(analysis_storage_dir, [analysisConf.subjects__name '_spike_beta_xcorr']);
    xcorr_session_dir = fullfile(xcorr_subject_dir, analysisConf.sessionNames{iNeuron});

    xcorr_name = fullfile(xcorr_session_dir, xcorr_name);
    
    if exist(xcorr_name,'file') ~= 2
        keyboard;
        continue;
    end
    numPlots = numPlots + 1;
    load(xcorr_name);
    t = xcorrMetadata.t;
    
    plotIdx = rem(numPlots,plots_per_page);
    if plotIdx == 0
        plotIdx = plots_per_page;
    end
    if plotIdx == 1
        h_fig = figure;
    end
    
    subplot(num_rows,num_cols,plotIdx);
%     plot(t,mean_all_xcorr,'color','k');
    hold on;
    plot(t,mean_ISI_xcorr,'color','b');
    plot(t,mean_LTS_xcorr,'color','r');
    plot(t,mean_Poisson_xcorr,'color','g');
    set(gca,'xlim',plot_xlim)
    title(neuronName);
    

    if plotIdx == plots_per_page || iNeuron == size(analysisConf.neurons,1)
        numPages = numPages + 1;
        pdfName = sprintf('%s_spike_beta_xcov_%02d',ratID,numPages);
        pdfName = fullfile(xcorr_subject_dir, pdfName);
        fp = fillPage(h_fig,'margins',[0 0 1 0],'papersize',[11 8.5]);
        
        print(h_fig,'-opengl','-dpdf','-r200',pdfName);
        close(h_fig);
    end
%     tsPrctlScalos_DKL(); % format
    
    % high beta power centered analysis using ts raster
%     fpass = [13 30];
% %     tWindow = 1; % [] need to standardize time windows somehow
%     fieldname = 'centerOut';
%     [rasterTs,rasterEvents,allTs,allEvents] = lfpRaster(trials,trialIds,fieldname,ts,sev,header.Fs,fpass,scaloWindow);
%     lfpRasters(); % format

% % run_RTraster()
end

addUnitHeader(analysisConf,{'eventAnalysis'});