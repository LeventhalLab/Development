function [Wz_power,Wz_phase] = zScoreW(W,Wlength)
% note: Wz_angle is really just to provide a phase version of Wz with the same dimensions
if Wlength > size(W,2)
    error('only built to downsample not interpolate');
end

resampleTs = floor(linspace(1,size(W,2),Wlength));
Wz_phase = angle(W(:,resampleTs,:,:));
W_power = abs(W).^2; % !! [ ] handle phase too

Wz_power = [];
for iFreq = 1:size(W_power,4)
    refW = squeeze(W_power(1,:,:,iFreq)); % cue event
    refMean = mean2(refW);
    refStd = mean(std(refW));
    for iEvent = 1:size(W_power,1)
        theseW = squeeze(W_power(iEvent,:,:,iFreq));
        theseWz = (theseW - refMean) ./ refStd;
        Wz_power(iEvent,:,:,iFreq) = theseWz(resampleTs,:);
    end
end