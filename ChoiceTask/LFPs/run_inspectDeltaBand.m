ratIds = {'R0088','R0117','R0142','R0154','R0182'};
sevIds = [20,53,77,335,346]; % one from each, psuedo-random
decimateFactor = 10;

figure;
for sevId = sevIds
    sevFile = LFPfiles{sevId};
    disp(sevFile);
    [sev,header] = read_tdt_sev(sevFile);
    sevFilt = decimate(double(sev),decimateFactor);
    Fs = header.Fs / decimateFactor;

    simpleFFT(sevFilt,Fs,'newFig',false,'nSmooth',100);
end
grid on;
legend(ratIds);
ylim([0 1]);