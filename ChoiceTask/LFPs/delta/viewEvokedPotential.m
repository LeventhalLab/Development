% % load('session_20181106_entrainmentData.mat', 'selectedLFPFiles');
% % load('session_20181106_entrainmentData.mat', 'eventFieldnames');
% % load('session_20180804_ERPAC.mat', 'LFPfiles_local');
% % load('session_20181106_entrainmentData.mat', 'all_trials');

savePath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/delta';

doSetup = true;
doSave = true;
freqList = {[1 4]}; % hilbert method
iEvent = 4;
tWindow = 1;

if doSetup
    iSession = 0;
    for iNeuron = selectedLFPFiles(1)'
        iSession = iSession + 1;
        disp(num2str(iSession));
        sevFile = LFPfiles_local{iNeuron};
        [sevFilt,Fs,decimateFactor] = loadCompressedSEV(sevFile,[]);
        curTrials = all_trials{iNeuron};

        [trialIds,allTimes] = sortTrialsBy(curTrials,'RT');
        [W,all_data] = eventsLFPv2(curTrials(trialIds),sevFilt,tWindow,Fs,freqList,eventFieldnames);
    end
end

rows = 2;
cols = 1;
lineWidth = 1.5;
t = linspace(-tWindow,tWindow,size(all_data,2));
for iTrial = 1:numel(allTimes)
    h = ff(500,300);

    subplot(rows,cols,prc(cols,[1 1]));
    plot(t,all_data(iEvent,:,iTrial),'k-','lineWidth',lineWidth);
    xticks([-tWindow,0,tWindow]);
    ylim(repmat(max(abs(ylim)),[1 2]).*[-1 1]);
    yticks(sort([ylim,0]));
    title({eventFieldnames{iEvent},'Wideband'});
    grid on;

    subplot(rows,cols,prc(cols,[2 1]));
    yyaxis left;
    plot(t,real(W(iEvent,:,iTrial)),'lineWidth',lineWidth);
    ylabel('real');
    yticks(ylim);
    xlabel('time (s)');

    yyaxis right;
    plot(t,angle(W(iEvent,:,iTrial)),'lineWidth',lineWidth);
    ylabel('phase');
    yticks([-pi,0,pi]);
    yticklabels({'-\pi','0','\pi'});
    ylim([-4 4]);
    xticks([-tWindow,0,tWindow]);
    xlabel('time (s)');
    title('\delta-band');
    grid on;

    set(gcf,'color','w');
    if doSave
        saveas(h,fullfile(savePath,['deltaRawPhase_s',num2str(iSession,'%02d'),'_t',num2str(iTrial,'%03d'),'.png']));
        close(h);
    end
end