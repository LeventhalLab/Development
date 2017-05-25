function [pulse_binary,pulse_ts] = extractLaserProtocol(sev_laser,header,minResetTime)

% % figure; plot(sev_laser_laser);
% % [~,laserThresh] = ginput(1);
laserThresh = 4e5; % found empirically

% minResetTime = 0; % seconds, make 0 for fast pulses
resetSamples = 1;
pulse_binary = [];
pulse_ts = [];
nts = 1;
laserState = false;
for iSample = 1:numel(sev_laser)
    if sev_laser(iSample) > laserThresh && ~laserState % rising edge
        laserState = true;
        if resetSamples / header.Fs > minResetTime
            pulse_ts(nts) = iSample / header.Fs;
            nts = nts + 1;
            pulse_binary(iSample) = true;
        end
        resetSamples = 1;
    else % anywhere after rising edge
        pulse_binary(iSample) = false;
        resetSamples = resetSamples + 1;
    end
    
    if sev_laser(iSample) < laserThresh && laserState     
        laserState = false;
    end
end

% figure;
% plot(normalize(sev_laser));
% hold on;
% plot(pulse_binary);