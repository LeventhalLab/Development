

[f,p]=uigetfile({'*.sev'});
[sev,header] = read_tdt_sev(fullfile(p,f));
[b,a] = butter(4, [0.02 0.2]);
HPdata =  filtfilt(b,a,double(sev));
ddt_write_v('',1,length(HPdata),3e4,HPdata/1000);