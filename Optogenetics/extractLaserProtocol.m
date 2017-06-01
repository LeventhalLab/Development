function [pulse_binary,pulse_ts] = extractLaserProtocol(laserData,Fs,minResetTime)

% % figure; plot(sev_laser_laser);
% % [~,laserThresh] = ginput(1);
% % laserThresh = 4e5; % found empirically
laserThresh = max(laserData) * 0.2; % 20% of max should work for many types of data

% minResetTime = 0; % seconds, make 0 for fast pulses
resetSamples = 1;
pulse_binary = [];
pulse_ts = [];
nts = 1;
laserState = false;
for iSample = 1:numel(laserData)
    if laserData(iSample) > laserThresh && ~laserState % rising edge
        laserState = true;
        if resetSamples / Fs > minResetTime
            pulse_ts(nts) = iSample / Fs;
            nts = nts + 1;
            pulse_binary(iSample) = true;
        end
        resetSamples = 1;
    else % anywhere after rising edge
        pulse_binary(iSample) = false;
        resetSamples = resetSamples + 1;
    end
    
    if laserData(iSample) < laserThresh && laserState     
        laserState = false;
    end
end

% figure;
% plot(normalize(sev_laser));
% hold on;
% plot(pulse_binary);