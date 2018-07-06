trainingPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/MachineLearning/trainingData250msRT';
longXT = 200; % ms
trainingFrac = 0.8;
scramble = false;
showDist = false;

accuracy = [];
for iEvent = 3%1:7
    allFiles = dir(fullfile(trainingPath,['*e',num2str(iEvent),'*.jpg'])); % u364_e7_t094_RT0687_id18291
    im = imread(fullfile(allFiles(1).folder,allFiles(1).name));

    nFiles = numel(allFiles);
    randIds = randperm(nFiles);

    trainingIds = randIds(1:round(nFiles * trainingFrac));
    [files,labels,labelsArr] = imdsInputs(allFiles,trainingIds,meanBinsSeconds,scramble);
    imdsTrain = imageDatastore(files,'Labels',labels);

    validationIds = randIds(round(nFiles * trainingFrac):end);
    [files,labels,labelsArr] = imdsInputs(allFiles,validationIds,meanBinsSeconds,scramble);
    imdsValidation = imageDatastore(files,'Labels',labels);

    layers = [
        imageInputLayer([size(im) 1])

        convolution2dLayer(3,8,'Padding',1)
        batchNormalizationLayer
        reluLayer

        maxPooling2dLayer(2,'Stride',2)

        convolution2dLayer(3,16,'Padding',1)
        batchNormalizationLayer
        reluLayer

        maxPooling2dLayer(2,'Stride',2)

        convolution2dLayer(3,32,'Padding',1)
        batchNormalizationLayer
        reluLayer

        fullyConnectedLayer(numel(meanBinsSeconds)-1)
        softmaxLayer
        classificationLayer];

    options = trainingOptions('sgdm', ...
        'MaxEpochs',4, ...
        'ValidationData',imdsValidation, ...
        'ValidationFrequency',30, ...
        'Verbose',false, ...
        'Plots','training-progress');

    net = trainNetwork(imdsTrain,layers,options);

    YPred = classify(net,imdsValidation);
    YTrain = imdsTrain.Labels;
    YValidation = imdsValidation.Labels;

    accuracy(iEvent) = sum(YPred == YValidation)/numel(YValidation);
    if showDist
        figure('Units','normalized','Position',[0.2 0.2 0.5 0.5]);
        subplot(2,1,1)
        histogram(YTrain)
        title("Training Label Distribution")
        subplot(2,1,2)
        histogram(YValidation)
        title("Validation Label Distribution")
    end
    if showDream
        I = deepDreamImage(net,layer,1:12);
        figure;
        montage(I,'Size',[12,1]);
        
        figure;
        plotconfusion(YValidation,YPred,'Validation Data')
    end
% %     analyzeNetwork(net);
end

figure;
bar(accuracy);
ylim([0.7 1]);