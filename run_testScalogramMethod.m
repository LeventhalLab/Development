% scalogram test
fpass = [10 100];
freqList = logFreqList(fpass,30);

filename = '/Users/mattgaidica/Desktop/R0142_20161218a_R0142_20161218a-1_data_ch1.sev';
[sev, header] = read_tdt_sev(filename);
decimateFactor = round(header.Fs / (fpass(2) * 10));
sevFilt = decimate(double(sev),decimateFactor);
Fs = header.Fs / decimateFactor;

t = 0:1/Fs:5; % 5 seconds of data
A = 200; % uV

f = 75;
Y1 = A*sin(2*pi*f*t);

f = 35;
Y2 = A*sin(2*pi*f*t);

sevFiltAdd = sevFilt(1:length(t)) + Y1 + Y2;
[W, freqList] = calculateComplexScalograms_EnMasse(sevFiltAdd','Fs',Fs,'freqList',freqList);
scalo = squeeze(mean(abs(W).^2,2))';

h = figure;
imagesc(t,freqList,scalo);
set(gca,'YDir','normal');
set(gca,'YScale','log');
set(gca,'Ytick',round(logFreqList(fpass,10)));
set(gca,'TickDir','out');
colormap(jet);