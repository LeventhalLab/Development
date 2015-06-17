% figure;
% hold on;
% plot(data);
% butterdata = filtfilt(b,a,double(data));
% % [smoothdata] = eegfilt(sev(1:1e6),header.Fs,500,2500);
% % plot(smoothdata);
% % [smoothdata] = eegfilt(sev(1:1e6),header.Fs,750,2500);
% % plot(smoothdata);
% % [smoothdata] = eegfilt(sev(1:1e6),header.Fs,1000,2500);
% % plot(smoothdata);
% 
% % [smoothdata] = eegfilt(sev(1:1e6),header.Fs,750,2000);
% % plot(smoothdata);
% [smoothdata] = eegfilt(sev(1:1e6),header.Fs,750,3000);
% plot(smoothdata);
% plot(butterdata);
% % [smoothdata] = eegfilt(sev(1:1e6),header.Fs,750,4000);
% % plot(smoothdata);
% 
% % legend({'500,2500','750,2500','1000,2500','500,4000','500,5000','500,7500'});

for ii=1:40
    disp(eventNames{tsArr(ii,1)});
end