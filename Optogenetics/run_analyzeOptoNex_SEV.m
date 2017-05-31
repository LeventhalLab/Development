dosteps = [1,2]; % step 1: select laser epoch, step 2: generate plots
protocol = 1; % 1 = long, 2 = short, 3 = custom
useUnits = []; % empty runs plots for all units in NEX file

if true % make false if data is already in MATLAB; save time, time = money, money is everything
    % extract system-specific data
    laserFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-1/R0181_20170525c_cylinder_R0181_20170525c_cylinder-1_data_ch65.sev';
    [laserData,header] = read_tdt_sev(laserFile);

    ephysFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-1/R0181_20170525c_cylinder_R0181_20170525c_cylinder-1_data_ch58.sev';
    [ephysData,header] = read_tdt_sev(ephysFile);
end

% may contain multiple unit timestamps
nexFile = '/Volumes/RecordingsLeventhal2/ChoiceTask/R0181/R0181-opto/R0181_20170525_cylinder/R0181_20170525c_cylinder-1/R0181_20170525c_cylinder_R0181_20170525c_cylinder-1_data_ch[58  60  62  64].nex';

Fs = header.Fs;
% % [pulse_binary,pulse_ts] = analyzeOptoNex(ephysData,laserData,nexFile,Fs,dosteps,protocol,useUnits);
analyzeOptoNex(ephysData,laserData,nexFile,Fs,dosteps,protocol,useUnits);