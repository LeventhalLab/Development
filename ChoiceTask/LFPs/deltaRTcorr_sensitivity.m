% load('session_20180925_entrainmentSurrogates.mat', 'LFPfiles_local')
% load('session_20180925_entrainmentSurrogates.mat', 'selectedLFPFiles')
% load('session_20180925_entrainmentSurrogates.mat', 'all_trials')
% load('session_20180925_entrainmentSurrogates.mat', 'eventFieldnames')

% change t>0 data removal in eventsLFPv2.m before running
doSetup = true;
doTiming = 'RT';

tWindow = 1;
freqList = logFreqList([1 6],30);
iEvent = 3;
n_timePoints = 1000;
t = linspace(-tWindow,tWindow,n_timePoints);
doPhase = true;

phaseCorrs_sens = [];

if doSetup
    all_Times = [];
    allW = [];
    iSession = 0;
    allTimes = [];
    startIdx = 1;
    for iNeuron = selectedLFPFiles'
        iSession = iSession + 1;
        disp(num2str(iSession));
        sevFile = LFPfiles_local{iNeuron};
        [~,name,~] = fileparts(sevFile);
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        curTrials = all_trials{iNeuron};

        [trialIds,allTimes] = sortTrialsBy(curTrials,doTiming);
        [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,{eventFieldnames{iEvent}});
        tIdxs = floor(linspace(1,size(W,2),n_timePoints));
        endIdx = startIdx + size(W,3) - 1;
        allW(:,startIdx:endIdx,:) = squeeze(W(:,tIdxs,:,:));
        startIdx = endIdx + 1;
        all_Times = [all_Times;allTimes'];
    end
    all_pval = [];
    all_rho = [];
    for iFreq = 1:size(allW,3)
        for iT = 1:size(allW,1)
            if doPhase
                theseAngles = angle(allW(iT,:,iFreq));
                [rho,pval] = circ_corrcl(theseAngles,all_Times);
            else
                theseAngles = abs(allW(iT,:,iFreq)).^2;
                [rho,pval] = circ_corrcc(theseAngles,all_Times); 
            end
            all_pval(iT,iFreq) = pval;
            all_rho(iT,iFreq) = rho;
        end
    end
end

% noteText = 't > 0 data intact';
noteText = 't > 0 data removed';
min_p = min(min(all_pval));
[min_t,min_f] = find(all_pval == min_p);
markText = {['p_{min} = ',num2str(min_p,2)],['f_{min} = ',num2str(freqList(min_f),'%1.2f'),' Hz'],...
    ['t_{min} = ',num2str(t(min_t),'%1.2f'),' s'],['rho = ',num2str(all_rho(min_t,min_f),2)]};

h = ff(1000,750);
caxisVals = [0 1;0 0.05];
rows = 2;
cols = 2;
for ii = 1:2
    subplot(rows,cols,prc(cols,[1,ii]));
    imagesc(t,1:size(allW,3),all_pval');
    hold on;
    plot(t(min_t),min_f,'ro','markerSize',20);
    text(t(min_t)+0.2,min_f,markText,'color','k');
    set(gca,'ydir','normal');
    caxis(caxisVals(ii,:));
    colormap(gca,parula);
    yticks(1:size(allW,3));
    yticklabels(compose('%2.1f',freqList));
    ylabel('freq (Hz)');
    xlabel('time (s)');
    cb = colorbar;
    cb.Label.String = 'p-value';
    cb.Ticks = caxis;
    title([eventFieldnames{iEvent},' corrcl(phase,RT)']);
    set(gca,'fontsize',10);
    
    subplot(rows,cols,prc(cols,[2,ii]));
    imagesc(t,1:size(allW,3),all_rho');
    hold on;
    plot(t(min_t),min_f,'ro','markerSize',20);
    text(t(min_t)+0.2,min_f,markText,'color','k');
    set(gca,'ydir','normal');
    caxis(caxisVals(ii,:));
    colormap(gca,hot);
    yticks(1:size(allW,3));
    yticklabels(compose('%2.1f',freqList));
    ylabel('freq (Hz)');
    xlabel('time (s)');
    cb = colorbar;
    cb.Label.String = 'rho';
    cb.Ticks = caxis;
    title([eventFieldnames{iEvent},' corrcl(phase,RT)']);
    set(gca,'fontsize',10);
end
set(gcf,'color','w');
addNote(h,noteText);