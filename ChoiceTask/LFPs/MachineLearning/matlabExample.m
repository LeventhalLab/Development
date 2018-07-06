% % digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
% %     'nndatasets','DigitDataset');
% % imds = imageDatastore(digitDatasetPath, ...
% %     'IncludeSubfolders',true,'LabelSource','foldernames');

figure;
perm = randperm(10000,20);
for i = 1:20
    subplot(4,5,i);
    imshow(imds.Files{perm(i)});
end

labelCount = countEachLabel(imds)