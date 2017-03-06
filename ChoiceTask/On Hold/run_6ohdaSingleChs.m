% chs = [1 3 5 7 34 36 38 40 41 43 45 47]; % MTHAL
% target = 'MTHAL';

chs = [58 60 62 64 19 21 23 25 18 20 22 24]; % STR
target = 'STR';

figure('position',[500 500 700 300]);

for iCh = 1:numel(chs)
    disp(['ch',num2str(chs(iCh)),' ',target]);
    rVEHFile = ['/Volumes/RecordingsLeventhal2/ChoiceTask/R0154/R0154-rawdata/R0154_20170227a/R0154_20170227a/R0154_20170227a_R0154_20170227a-1_data_ch',num2str(chs(iCh)),'.sev'];
    rNNCFile = ['/Volumes/RecordingsLeventhal2/ChoiceTask/R0154/R0154-rawdata/R1054_20170228a/R0154_20170228a/R0154_20170228a_R0154_20170228a-1_data_ch',num2str(chs(iCh)),'.sev'];

    params.fpass = [5 35];
    params.pad = 0;
    params.tapers = [3 5];
    nSmooth = 2000;
    nDown = 10;

    [sevNNC,header] = read_tdt_sev(rNNCFile);
    sevNNC = downsample(double(sevNNC),nDown);
    params.Fs = round(header.Fs/nDown);
    [SNNC,f] = mtspectrumc(sevNNC',params);

    [sevVEH,header] = read_tdt_sev(rVEHFile);
    sevVEH = downsample(double(sevVEH),nDown);
    params.Fs = round(header.Fs/nDown);
    [SVEH,f] = mtspectrumc(sevVEH',params);

    subplot(4,3,iCh);
    plot_vector(smooth(SNNC,nSmooth),f,'l',[],'b');
    hold on;
    plot_vector(smooth(SVEH,nSmooth),f,'l',[],'r');

    legend('NNC','Vehicle');
    title(['ch',num2str(chs(iCh)),' ',target]);
end