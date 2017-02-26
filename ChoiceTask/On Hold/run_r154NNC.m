fpass = [1 80];
freqList = [10:40];
decimateFactor = 1;
params.fpass = fpass;
params.pad = 0;
params.tapers = [3 5];

% % [W, freqList] = calculateComplexScalograms_EnMasse(r154NNC_sev_before_decimated','Fs',Fs,'freqList',freqList,'doplot',true);
% % [W, freqList] = calculateComplexScalograms_EnMasse(r154NNC_sev_afterEarly_decimated','Fs',Fs,'freqList',freqList,'doplot',true);
figure;
ch = '59';

r154NNC_before_filename = ['/Users/mattgaidica/Documents/Data/ChoiceTask/R0154_20170225a_beforeNNC-1/R0154_20170225a_beforeNNC_R0154_20170225a_beforeNNC-1_data_ch',ch,'.sev'];
[r154NNC_before_sev,header] = read_tdt_sev(r154NNC_before_filename);
r154NNC_sev_before_decimated = decimate(double(r154NNC_before_sev),decimateFactor);
Fs = header.Fs / decimateFactor;
[S_before,f] = mtspectrumc(r154NNC_sev_before_decimated',params);
plot_vector(smooth(S_before,300),f,'l',0,'b');

dataSnip = size(r154NNC_sev_before_decimated,2);

hold on;

r154NNC_after_filename = ['/Users/mattgaidica/Documents/Data/ChoiceTask/R0154_20170225a_afterNNC-1/R0154_20170225a_afterNNC_R0154_20170225a_afterNNC-1_data_ch',ch,'.sev'];
[r154NNC_after_sev,header] = read_tdt_sev(r154NNC_after_filename);
r154NNC_sev_after_decimated = decimate(double(r154NNC_after_sev),decimateFactor);

r154NNC_sev_afterEarly_decimated = r154NNC_sev_after_decimated(1,1:dataSnip);
r154NNC_sev_afterLate_decimated = r154NNC_sev_after_decimated(1,end-dataSnip:end);

[S_afterEarly,f] = mtspectrumc(r154NNC_sev_afterEarly_decimated',params);
plot_vector(smooth(S_afterEarly,300),f,'l',0,'r');

[S_afterLate,f] = mtspectrumc(r154NNC_sev_afterLate_decimated',params);
plot_vector(smooth(S_afterLate,300),f,'l',0,'k');


ylim([-10 30]);
xlim(fpass);
title(['R154 FFT, ch',ch]);
legend({'R154 Before NNC','','R154 Early NNC','','R154 Late NNC',''});