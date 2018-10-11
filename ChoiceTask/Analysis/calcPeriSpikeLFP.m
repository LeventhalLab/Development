function periSpikeLFPs = calcPeriSpikeLFP( ts, LFP, tWin, Fs )

% ts - spike timestamps

numSamps = floor(tWin * Fs);
endTs = length(LFP) / Fs;
periSpikeLFPs = zeros(1,numSamps*2 + 1);
num_valid_ts = 0;
for i_ts = 1 : length(ts)
    
    if ts(i_ts) <= tWin || ts(i_ts) >= endTs-tWin
        continue;
    end
    
    num_valid_ts = num_valid_ts + 1;
    
    centerSamp = round(ts(i_ts) * Fs);
    samples = centerSamp - numSamps : centerSamp + numSamps;
    
    periSpikeLFPs(num_valid_ts,:) = LFP(samples);
    
end