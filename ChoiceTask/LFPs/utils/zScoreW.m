function [Wz_power,Wz_phase] = zScoreW(W,Wlength,tWindow)
% [ ] return t based on tWindow/2
% [ ] find all places this function is used and make sure half window is known!
% this function will return half tWindow (uses first half as ref)
% note: Wz_angle is really just to provide a phase version of Wz with the same dimensions
disp('Converting W to Wz *Wz is half tWindow!*');

if Wlength > size(W,2)
    error('only built to downsample not interpolate');
end

resampleTs = floor(linspace(1,size(W,2),Wlength*2));
returnRange = (1:Wlength) + ceil(Wlength/2);
Wz_phase = angle(W(:,resampleTs(returnRange),:,:));
W_power = abs(W(:,resampleTs(:),:,:)).^2; % returnRange applied later

Wz_power = [];
for iFreq = 1:size(W_power,4)
    refW = squeeze(W_power(1,1:Wlength,:,iFreq)); % cue event
    refStd = mean(std(refW));
    for iEvent = 1:size(W_power,1)
        for iTrial = 1:size(W_power,3)
            refMean = mean(refW(:,iTrial));
            theseW = squeeze(W_power(iEvent,returnRange,iTrial,iFreq));
            theseWz = (theseW - refMean) ./ refStd;
            Wz_power(iEvent,:,iTrial,iFreq) = theseWz;
        end
    end
end