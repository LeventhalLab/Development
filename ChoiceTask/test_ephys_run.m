for ii = 1:64
   filename = ['C:\Users\admin\Desktop\Hannah\20150617b_ephys_20150617b_ephys-1_data_ch', num2str(ii),'.sev'];
   [sev, header] = read_tdt_sev(filename);
   %[a,b] = butter(4, [.02, .2]);
   %filteredSev = filtfilt(b,a,double(sev));
   t = linspace(0,length(sev)/header.Fs, length(sev));
   figure;
   plot(t,sev);
   xlabel('Time (s)');
   %hold on;
   %plot(filteredSev);
    
end