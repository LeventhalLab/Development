r153path = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0153_20170214_openField-1';
r154path = '/Users/mattgaidica/Documents/Data/ChoiceTask/R0154_20170214_openField-2';

r153files = dir(fullfile(r153path,'*.sev'));
r153files = natsort({r153files.name});

r154files = dir(fullfile(r154path,'*.sev'));
r154files = natsort({r154files.name});

% chs = [1:2:16 33:2:48];
chs = [18 24 26 28 29 30 32 49 51 53 55 57 58 60 61 63]; %STR
% chs = [1 4 8 9 11 13 15 16 38 40 41 42 43 44 45 47]; %MTHAL

figure('position',[0 0 1100 800]);
for iCh = 1:numel(chs)
    disp(iCh);
    subplot(4,4,iCh);

    params.fpass = [0 80];
    params.pad = 0;
    params.tapers = [3 5];
    
    [r153sev,header] = read_tdt_sev(fullfile(r153path,r153files{chs(iCh)}));
    params.Fs = round(header.Fs);
    [S,f] = mtspectrumc(r153sev',params);
    plot_vector(smooth(S,300),f,'l',[],'b');
    
    hold on;
    
    [r154sev,~] = read_tdt_sev(fullfile(r154path,r154files{chs(iCh)}));
    [S,f] = mtspectrumc(r154sev',params);
    plot_vector(smooth(S,300),f,'l',[],'r');
    
    legend('R153 6-OHDA','R154 Normal','Location','southwest');
    xlim(params.fpass);
    ylim([-10 40]);
    title(['ch',num2str(chs(iCh))]);
    
    drawnow;
end