dosteps = [1,2]; % step 1: select laser epoch, step 2: generate plots
protocol = 1; % 1 = long, 2 = short, 3 = custom
useUnits = []; % empty runs plots for all units in NEX file

useChannel = 0;
if false % make false if data is already in MATLAB; save time, time = money, money is everything
    % extract system-specific data
    rhdFile = '/Volumes/RecordingsLeventhal2/OptoEphys/R0177/R0177-rawdata/052417_opto/R0177_052417_optoephys1_170524_172440.rhd';
    read_Intan_RHD2000_file(rhdFile);
end

ephysData = amplifier_data(useChannel+1,:);
laserData = board_adc_data(1,:);

% may contain multiple unit timestamps
nexFile = '/Volumes/RecordingsLeventhal2/OptoEphys/R0177/R0177-rawdata/052417_opto/DDT Files/R0177_052417_optoephys1/R0177_052417_channel_0.nex';

Fs = frequency_parameters.amplifier_sample_rate;
analyzeOptoNex(ephysData,laserData,nexFile,Fs,dosteps,protocol,useUnits);