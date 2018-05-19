function data = butterme(data,Fs,hilow)

Wn1 = hilow(1) / (Fs / 2);
Wn2 = hilow(2) / (Fs / 2);

[b,a] = butter(4, [Wn1 Wn2]); % 4th order
data = filtfilt(b,a,double(data));