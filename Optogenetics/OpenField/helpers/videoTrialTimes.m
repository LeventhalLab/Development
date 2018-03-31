function trialTimes = videoTrialTimes(filename,startStop)
rgbIdx = 2; % green LED
offFrames = 100;
inTrialStd = 100;

v = VideoReader(filename);
iFrame = 0;
pixelValues = [];
pos = [];
inTrial = false;
trialCount = 0;
trialTimes = [];

if ~isempty(startStop)
    v.CurrentTime = startStop(1);
end

while hasFrame(v)
    disp(num2str(v.CurrentTime));
    iFrame = iFrame + 1;
    
    frame = readFrame(v);
    if isempty(pos)
        disp('select indicator pixel');
        h = figure;
        imshow(frame);
        pos = getPosition(imrect);
        close(h);
    end
    cropFrame = imcrop(frame,pos);
    pixelValues(iFrame) = mean2(cropFrame(:,:,rgbIdx));
    
    % state machine
    if iFrame > offFrames
        if ~inTrial
            if pixelValues(iFrame) > mean(pixelValues(1:offFrames)) + inTrialStd*std(pixelValues(1:offFrames))
                inTrial = true;
                trialCount = trialCount + 1;
                trialTimes(trialCount,1) = v.CurrentTime; % trial start
            end
        else
            if pixelValues(iFrame) - inTrialStd*std(pixelValues(1:offFrames)) < mean(pixelValues(1:offFrames)) 
                inTrial = false;
                trialTimes(trialCount,2) = v.CurrentTime; % trial end
            end
        end
    end
    
    if numel(startStop) > 1 && v.CurrentTime > startStop(2)
        break;
    end
end

figure;
plot(pixelValues);