function FRtrialAnalysis(sessionConf,ratData,whichNeuron)
%Inputs: 
% sessionConf variable
% ratData.mat file that contains paw marking data
% whichNeuron is list of neurons to look at, i.e. ['T01_1'; 'T02_2']
%
    leventhalPaths = buildLeventhalPaths(sessionConf);
    nexPath = sessionConf.nexPath
    whichNeuron = cellstr(whichNeuron)
    for ii=1:length(whichNeuron)
        [neuronName,neuronCh] = getNeuronID(sessionConf, char(whichNeuron(ii)));
        [n,neuronTS] = nex_ts(nexPath,neuronName);

        %%Load paw marking data
        videoScores = [ratData.VideoFiles.Score];
        trialIDX = find(videoScores);


       for i=1:length(trialIDX)
          startFrame(i)=ratData.VideoFiles(trialIDX(i)).ManualStartFrame; 
          reachStart(i) = ratData.VideoFiles(trialIDX(i)).reachStart;
          reachEnd(i) = ratData.VideoFiles(trialIDX(i)).reachEnd;
          pawIDX = find(ismember([ratData.VideoFiles(trialIDX(i)).Data{:,5}],...
              'Center of Back Surface of Paw'));
          leftIDX =  find(ismember([ratData.VideoFiles(trialIDX(i)).Data{:,3}],...
              '(Video) Left'));
          centerIDX =  find(ismember([ratData.VideoFiles(trialIDX(i)).Data{:,3}],...
              'Center'));
          rightIDX =  find(ismember([ratData.VideoFiles(trialIDX(i)).Data{:,3}],...
              '(Video) Right'));
          lPawFrames(i,:) =  ratData.VideoFiles(trialIDX(i)).Data(intersect(pawIDX,leftIDX),2);
          cPawFrames(i,:) =  ratData.VideoFiles(trialIDX(i)).Data(intersect(pawIDX,centerIDX),2);
          rPawFrames(i,:) =  ratData.VideoFiles(trialIDX(i)).Data(intersect(pawIDX,rightIDX),2);
          lBackSurfaceX(i,:) = ratData.VideoFiles(trialIDX(i)).Data(intersect(pawIDX,leftIDX),7);
          lBackSurfaceY(i,:) = ratData.VideoFiles(trialIDX(i)).Data(intersect(pawIDX,leftIDX),8);
          cBackSurfaceX(i,:) = ratData.VideoFiles(trialIDX(i)).Data(intersect(pawIDX,centerIDX),7);
          cBackSurfaceY(i,:) = ratData.VideoFiles(trialIDX(i)).Data(intersect(pawIDX,centerIDX),8);
          rBackSurfaceX(i,:) = ratData.VideoFiles(trialIDX(i)).Data(intersect(pawIDX,rightIDX),7);
          rBackSurfaceY(i,:) = ratData.VideoFiles(trialIDX(i)).Data(intersect(pawIDX,rightIDX),8);

       end

       %Load behavioral Time stamp data for each trial
       [greenTrigTS,irTS,ap3TS,frameTrigger] = loadTrialsSR(sessionConf);
       
       %Plot FR
       for i=1:length(trialIDX)
        iRef = find(frameTrigger>greenTrigTS(i),1); %index of frame trigger at 300th frame
        tRef = frameTrigger(iRef);  %TS when green trigger aka 300th frame
        tReachStart(i) = frameTrigger(iRef-(300-reachStart(i)));
        tReachEnd(i)   = frameTrigger(iRef-(300-reachEnd(i)));
        %FR = eventSmoothFR(neuronTS,tReachStart(i),tReachEnd(i),.001);
       % figure();hold on
       % plot(0:.001: tReachEnd(i)-.001-tReachStart(i),FR);
        %plot([tReachEnd(i)-tReachStart(i)-5 tReachEnd(i)-tReachStart(i)-5],[0 10]);
       end

       plotReachStart = eventRaster(tReachStart,neuronTS,1);title(['Reach Start' whichNeuron(ii)])
       plotReachEnd = eventRaster(tReachEnd,neuronTS,1);title(['Reach End' whichNeuron(ii)])
       plotPos3 = eventRaster(ap3TS,neuronTS,1);title(['Actuator Position 3' whichNeuron(ii)])
    end
end