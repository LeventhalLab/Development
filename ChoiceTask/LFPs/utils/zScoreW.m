function [Wz,Wz_angle] = zScoreW(W,Wlength)

if Wlength > size(W,2)
    error('only built to downsample not interpolate');
end

resampleTs = floor(linspace(1,size(W,2),Wlength));
Wz_angle = angle(W(:,resampleTs,:,:));
Wpower = abs(W).^2; % !! [ ] handle phase too

Wz = [];
for iFreq = 1:size(Wpower,4)
    refW = squeeze(Wpower(1,:,:,iFreq)); % cue event
    refMean = mean2(refW);
    refStd = mean(std(refW));
    for iEvent = 1:size(Wpower,1)
        theseW = squeeze(Wpower(iEvent,:,:,iFreq));
        theseWz = (theseW - refMean) ./ refStd;
        Wz(iEvent,:,:,iFreq) = theseWz(resampleTs,:);
    end
end