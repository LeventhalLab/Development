function [all_W,all_data] = eventsLFP(trials,sevFilt,tWindow,Fs,freqList,eventFieldnames)

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
all_data = [];
newFig = true;
for iFreqRange = 1:(size(freqList,1))
    if iFreqRange == 1
        sevFiltFilt = sevFilt;
    else
        
    
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
        chop_tWindowSamples = round(Fs * tWindow_select);
        selectRange = (numel(lfp)/2) - round(chop_tWindowSamples):(numel(lfp)/2) + round(chop_tWindowSamples) - 1;
        if chopWindow
            all_data(iField,:,:) = data(selectRange,:);
        else
            all_data(iField,:,:) = data;
        end

        if ~isempty(freqList)
            if size(freqList,1) == 1 % use W
                W = calculateComplexScalograms_EnMasse(data,'Fs',Fs,'freqList',freqList,'doplot',doDebug);
                if chopWindow
                    all_W(iField,:,:,:) = W(selectRange,:,:);
                else
                    all_W(iField,:,:,:) = W;
                end
            else % use hilbert
    %             for iFreqRange = 1:size(freqList,1)
    %                 Fc = freqList(iFreqRange,:);
    %                 Wn = Fc ./ (Fs/2);
    %                 [b,a] = butter(4,Wn);
    %                 sevFiltFilt = filtfilt(b,a,sevFilt);
    %                 hx = hilbert(sevFiltFilt);
    %                 if chopWindow
    %                     all_W(iField,:,:,iFreqRange) = hx(selectRange,:);
    %                 else
    %                     all_W(iField,:,:,iFreqRange) = hx;
    %                 end
    %             end
            end
        end
    end
    if iFreqRange == 1
        all_LFP = all_data;
    else
        all_W(iField,:,:,iFreqRange) = all_data;
    end
end