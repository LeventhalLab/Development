rootDir = '/Volumes/Tbolt_02/VM thal analysis';
cd(rootDir);
testName = '*_spike_triggered_scalos';
ratDirs = dir(testName);

target_f = [16,23];
target_t = [-1,1] * 0.05;
target_f_idx = (f>=target_f(1) & (f <= target_f(2)));
target_t_idx = (t>=target_t(1) & (t <= target_t(2)));
numUnits = 0;
target_p = zeros(2,sum(target_f_idx),sum(target_t_idx));
all_p = zeros(2,length(f),length(t));
for i_ratDir = 1 : length(ratDirs)
    
    cd(rootDir);
    
    cur_ratDir = ratDirs(i_ratDir).name;
    if ~isdir(cur_ratDir) || any(strcmp(cur_ratDir,{'.','..'}))
        continue;
    end
    ratID = cur_ratDir(1:5);
    cur_ratDir = fullfile(rootDir,cur_ratDir);
    cd(cur_ratDir);

    sessionDirs = dir;
    
    for i_sessionDir = 1 : length(sessionDirs)
        cur_sessionDir = sessionDirs(i_sessionDir).name;
        cd(cur_ratDir);
        if ~isdir(cur_sessionDir) || any(strcmp(cur_sessionDir,{'.','..'}))
            continue;
        end
        
        cur_sessionDir = fullfile(cur_ratDir,cur_sessionDir);
        cd(cur_sessionDir);
        testName = '*_scalos_correctOnly_lin_f_p.mat';
        pFiles = dir(testName);
        
        for iP = 1 : length(pFiles)
            cur_pFile = pFiles(iP).name;
            if length(cur_pFile) < 4;continue;end
            if strcmpi(cur_pFile(1:2),'._'); continue; end
            
            load(cur_pFile);
            numUnits = numUnits + 1;
            LTS_p = squeeze(all_p(3,:,:));
            target_p(numUnits,:,:) = LTS_p(target_f_idx,target_t_idx);
            all_p(numUnits,:,:) = LTS_p;
            
            
        end
    end
end

%%
figure
num_sig_p = 0;
num_noLTS = 0;
for ii = 1 : size(target_p,1)
    
    
    hold on
    cur_p = squeeze(target_p(ii,:,:));
    if all(cur_p(:)<0.0020); num_noLTS = num_noLTS + 1;end
    
    toPlot = squeeze(mean(cur_p));
    pfilt = imboxfilt(cur_p,5);
    if any(pfilt(:) > 0.8); num_sig_p = num_sig_p + 1; end
    
    plot(t(target_t_idx),mean(cur_p))
    set(gca,'ylim',[-.1,1.1])
    
end