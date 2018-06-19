function [all_W,all_Lfp] = eventsLFP(trials,sevFilt,tWindow,Fs,freqList,eventFieldnames)

% 2-element tWindow means analyze larger range than returned to avoid edges
chopWindow = false;
if numel(tWindow) == 2
    tWindow_select = tWindow(1);
    tWindow = tWindow(2);
    chopWindow = true;
end

tWindowSamples = round(Fs * tWindow);
doDebug = false;

all_W = [];
all_Lfp = [];
newFig = true;
for iField = 1:numel(eventFieldnames)
    data = [];
    for iTrial = 1:numel(trials)
        try
            centerTs = getfield(trials(iTrial).timestamps,eventFieldnames{iField});
            centerSample = round(centerTs*Fs);
            centerRangeSamples = (centerSample - tWindowSamples):(centerSample + tWindowSamples - 1);
            if centerRangeSamples(1) > 0 && centerRangeSamples(end) < length(sevFilt)
                lfp = sevFilt(centerRangeSamples);
            end
        catch % for trials without all events
            centerRangeSamples = -tWindowSamples:tWindowSamples - 1;
            lfp = NaN(1,numel(centerRangeSamples));
        end
        data(:,iTrial) = lfp;
    end

    all_Lfp(iField,:,:) = data;
    if ~isempty(freqList)
        W = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList,'doplot',doDebug);

        if chopWindow
            chop_tWindowSamples = round(Fs * tWindow_select);
            selectRange = (size(W,1)/2) - round(chop_tWindowSamples):(size(W,1)/2) + round(chop_tWindowSamples) - 1;
            all_W(iField,:,:,:) = W(selectRange,:,:);
        else
            all_W(iField,:,:,:) = W;
        end
    end
end