r6ohdaFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0153_20170214_openField-1/R0153_20170214_openField_R0153_20170214_openField-1_data_ch63.sev';
rnormFile = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0154_20170214_openField-2/R0154_20170214_openField_R0154_20170214_openField-2_data_ch63.sev';

params.fpass = [0 80];
params.pad = 0;
params.tapers = [3 5];

[sev,header] = read_tdt_sev(r6ohdaFile);
params.Fs = round(header.Fs);
[S,f] = mtspectrumc(sev',params);
figure;
plot_vector(smooth(S,300),f,'l',[],'b');



hold on;

[sev,header] = read_tdt_sev(rnormFile);
params.Fs = round(header.Fs);
[S,f] = mtspectrumc(sev',params);
plot_vector(smooth(S,300),f,'l',[],'r');