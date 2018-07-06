trainingPath = '/Users/mattgaidica/Documents/Data/ChoiceTask/LFPs/MachineLearning/trainingData250msRT';
longXT = 200; % ms
trainingFrac = 0.8;
scramble = false;

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
    YValidation = imdsValidation.Labels;

    accuracy(iEvent) = sum(YPred == YValidation)/numel(YValidation);
    
% %     analyzeNetwork(net);
end

figure;
bar(accuracy);
ylim([0.7 1]);