% 6OHDA
figure('position',[0 0 400 400]);
filesDir = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0153_20170213_openField-1';
files = dir(fullfile(filesDir,'*.sev'));
files = {files.name};

allA = [];
for iFile = 1:length(files)
    disp(['reading: ',files{iFile}]);
    [sev,header] = read_tdt_sev(fullfile(filesDir,files{iFile}));
    [A,f] = simpleFFT(sev,header.Fs,false);
    allA(iFile,:) = A;
end

subplot(211);
meanA = mean(allA);
stdA = std(allA);
segRange = 1:25000;
semilogy(f(segRange),smooth(meanA(segRange),300));
% shadedErrorBar(f(segRange),smooth(meanA(segRange),300),smooth(stdA(segRange),300));
xlim([1 35]);
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
ylim([10^-1 10^1]);

% % % controls
% % figure('position',[0 0 400 400]);
% % filesDir = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0088_6OHDAcontrol';
% % files = dir(fullfile(filesDir,'*.sev'));
% % files = {files.name};
% % 
% % allA = [];
% % for iFile = 1:length(files)
% %     disp(['reading: ',files{iFile}]);
% %     [sev,header] = read_tdt_sev(fullfile(filesDir,files{iFile}));
% %     [A,f] = simpleFFT(sev,header.Fs,false);
% %     allA(iFile,:) = A;
% % end
% % 
% % % subplot(212);
% % semilogy(f,smooth(mean(allA),300));
% % xlim([5 80]);
% % xlabel('Frequency (Hz)')
% % ylabel('|Y(f)|')
% % ylim([10^-1 10^1]);