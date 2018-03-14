function [SI_mag,SI_phase] = synchronizationIndex(allW,t,tWindow,iEvent,lowFreqIdx)
% based on /Users/mattgaidica/Dropbox/Science/Mthal LFPs/Literature/1-s2.0-S0165027007005237-main.pdf
% size(allW) = (7,9766,94,18)
tSweep = .5; % seconds, 2 cycles of minimum freq (4 Hz)
sweep_window = ceil(numel(t) / (range(t) / tSweep) / 2); % samples
startIdx = closest(t,-tWindow);
endIdx = closest(t,tWindow);
SI_mag = [];
SI_phase = [];
iFreq = 1;
for highFreqIdx = lowFreqIdx+1 : size(allW,4)
    disp(['Using highFreqIdx: ',num2str(highFreqIdx),' of ',num2str(size(allW,4))]);
    trialSI_mag = [];
    trialSI_phase = [];
    for iTrial = 1:size(allW,3)
        % sweep thru time
        insideSI_mag = [];
        insideSI_phase = [];
        iti = 1;
        % use the window around time point iti
        for it = startIdx : endIdx
            lowData = allW(iEvent,it-sweep_window:it+sweep_window-1,iTrial,lowFreqIdx);
            highData = allW(iEvent,it-sweep_window:it+sweep_window-1,iTrial,highFreqIdx);
            lowPower = normalize(abs(highData));
            lowPhase = angle(hilbert(lowPower));
            highPhase = angle(highData);
            x = lowPhase - highPhase;
            insideSI_mag(iti) = abs(mean(exp(1i .* x)));
            insideSI_phase(iti) = angle(mean(exp(1i .* x)));
            iti = iti + 1;
        end
        trialSI_mag(iTrial,:) = insideSI_mag;
        trialSI_phase(iTrial,:) = insideSI_phase;
    end
    
    SI_mag(iFreq,:) = mean(trialSI_mag);
    SI_phase(iFreq,:) = circ_mean(trialSI_phase);
    iFreq = iFreq + 1;
end