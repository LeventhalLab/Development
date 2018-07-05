% function Wz = zScoreW(W,Wlength)

if Wlength > size(W,2)
    error('only built to downsample not interpolate');
end

resampleTs = floor(linspace(1,size(W,2),Wlength));

Wz = [];
for iEvent = 1:size(W,1)
    refW = squeeze(W(1,:,:,iFreq)); % cue event
    refMean = mean2(refW);
    refStd = mean(std(refW));
    for iFreq = 1:size(W,4)
        theseW = squeeze(W(iEvent,:,:,iFreq));
        theseWz = (theseW - refMean) ./ refStd;
        Wz(iEvent,:,:,iFreq) = theseWz(resampleTs,:);
    end
end