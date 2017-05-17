timingField = 'MT';
eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
eventId = 4;
if true
    zScoreTimingCorr_z = [];
    zScoreTimingCorr_rt = [];

    nCorr = 1;

    for iNeuron = 1:size(all_tsPeths,2)
        if eventIds_by_maxHistValues(iNeuron) ~= eventId
            continue;
        end
        trials = all_trials{iNeuron};
        [trialIds,allTimesRT] = sortTrialsBy(trials,timingField);
        ts = all_ts{iNeuron};
        tsPeths = eventsPeth(trials(trialIds),ts,tWindow,eventFieldnames);
        for iTrial = 1:size(tsPeths,1)
            if allTimesRT(iTrial) <= 0
                continue;
            end
            z_tsPeth = tsPeths{iTrial,1};
            [z_counts,z_centers] = hist(z_tsPeth,nBins_tWindow);
            z_idxs = find(nBins_tWindow <= 0);
            z_counts = z_counts(z_idxs);
            z_centers = z_centers(z_idxs);

            if mean(z_counts) < 0.5
                continue;
            end

            tsPeth = tsPeths{iTrial,eventId};
            [counts,centers] = hist(tsPeth,nBins_tWindow);
            zscore = (counts - mean(z_counts)) / std(z_counts);

    %         if max(abs(zscore)) > 15
    %             disp('stop');
    %         end

            zScoreTimingCorr_z(nCorr) = trapz(abs(zscore(21:end)));
            zScoreTimingCorr_rt(nCorr) = allTimesRT(iTrial);

            nCorr = nCorr + 1;
        end
    end
end

figure('position',[0 0 600 900]);
subplot(211);
lsidx(1) = plot(zScoreTimingCorr_rt,zScoreTimingCorr_z,'k.');
xlabel(timingField);
ylabel('Z-score');

corrInterval = 0.05;
startInterval = 0.0;
    endInterval = 0.8;
if strcmp(timingField,'MT')
    startInterval = 0.15;
    endInterval = 0.8;
end
nUpperMean = 20;
all_zs = [];
all_zstd = [];
all_ints = [];
for ii = startInterval-corrInterval:corrInterval:endInterval
    idx = find(zScoreTimingCorr_rt >= ii & zScoreTimingCorr_rt < ii + corrInterval);
    if ~isempty(idx)
        cur_zs = flip(sort(zScoreTimingCorr_z(idx)));
        upperIdxs = min([numel(cur_zs),nUpperMean]);
        all_zs = [all_zs mean(cur_zs(1:upperIdxs))];
        all_zstd = [all_zstd std(cur_zs(1:upperIdxs))];
    else
        all_zs = [all_zs NaN];
        all_zstd = [all_zstd NaN];
    end
    all_ints = [all_ints ii];
end

all_ints = all_ints + corrInterval/2;

nSmooth = 10;
hold on;
plot(interp(all_ints,nSmooth),interp(inpaint_nans(all_zs),nSmooth));
lsidxx = shadedErrorBar(interp(all_ints,nSmooth),interp(inpaint_nans(all_zs),nSmooth),interp(inpaint_nans(all_zstd),nSmooth),{'g'},1);
lsidx(2) = lsidxx.mainLine;
% plot((all_ints),(inpaint_nans(all_zs)));
xlim([startInterval endInterval]);
cur_ylim = ylim;
lsidx(3) = plot([mean(zScoreTimingCorr_rt) mean(zScoreTimingCorr_rt)],cur_ylim,'r');
lsidx(4) = plot([median(zScoreTimingCorr_rt) median(zScoreTimingCorr_rt)],cur_ylim,'b');

legend(lsidx,{'Trials',['Abs(Z) Area (',num2str(nUpperMean),')'],'Mean','Median'});
title([eventFieldnames{eventId},' - Trial Timing Distribution']);

subplot(212);
title('Timing Histogram');
[counts,centers] = hist(zScoreTimingCorr_rt,[startInterval-corrInterval:corrInterval:endInterval]);
bar(centers,counts,'k');
xlim([startInterval endInterval]);
xlabel(timingField);
ylabel('Trial Counts');
set(gca,'yscale','log');
