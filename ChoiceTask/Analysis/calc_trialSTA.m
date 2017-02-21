function [ STA ] = calcSTA( ts, lfp, Fs, twin )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

sampWin = round(twin * Fs);
numSamps = range(sampWin) + 1;
STA = zeros(1, numSamps);

num_valid_ts = 0;
for i_ts = 1 : length(ts)

    centerSamp = round(ts(i_ts) * Fs);
    if centerSamp < (1-sampWin(1)) || centerSamp > length(lfp) - sampWin(2)
        continue;
    end
    sampRange = centerSamp + sampWin;
    STA = STA + lfp(sampRange(1):sampRange(2));
    num_valid_ts = num_valid_ts + 1;
end

STA = STA / num_valid_ts;

