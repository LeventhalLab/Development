rootDir = '/Volumes/Tbolt_02/VM thal analysis';
cd(rootDir);

ratDirs = dir;

t_span = 2;    % seconds
num_cols = 3;
num_rows = 4;
num_spans = num_cols * num_rows;


for i_ratDir = 1 : length(ratDirs)
    
    cd(rootDir);
    
    cur_ratDir = ratDirs(i_ratDir).name;
    if ~isdir(cur_ratDir) || any(strcmp(cur_ratDir,{'.','..'}))
        continue;
    end
    
    cur_ratDir = fullfile(rootDir,cur_ratDir);
    cd(cur_ratDir);
    sessionDirs = dir;
    
    for i_sessionDir = 1 : length(sessionDirs)
        
        cur_sessionDir = sessionDirs(i_sessionDir).name;
        cd(cur_ratDir);
        if ~isdir(cur_sessionDir) || any(strcmp(cur_sessionDir,{'.','..'}))
            continue;
        end
        
        full_cur_sessionDir = fullfile(cur_ratDir,cur_sessionDir);
        cd(full_cur_sessionDir);
        LFPFiles = dir('*lfp.mat');
        
        for iLFP = 1 : length(LFPFiles)
            
            lfp_fname = LFPFiles(iLFP).name;
            
            load(lfp_fname);
            spanSamps = round(t_span * Fs);
            
            max_t = length(sevFilt)/Fs;
            t = linspace(1/Fs,max_t,length(sevFilt));
            
            h_fig = figure;
            for ii = 1 : num_spans
                
                subplot(num_rows,num_cols,ii)
                
                if ii == num_spans
                    [pxx,f] = pwelch(sevFilt,[],[],[],Fs);
                    plot(f,smooth(log10(pxx),100));
                    set(gca,'xlim',[0 65],'xtick',0:10:60,'ylim',[0 8])
                else
                    
                    spanStart = floor(rand() * (length(sevFilt)-spanSamps-1));
                    span_idx = spanStart : spanStart + spanSamps - 1;


                    plot(t(span_idx),sevFilt(span_idx));
                    set(gca,'xlim',[min(t(span_idx)),max(t(span_idx))]);
                    set(gca,'ylim',[-500 1000]);
                end
                
                if ii == 1
                    title(lfp_fname)
                end
            end
            PDFname = sprintf('%s_ch%02d_lfp.pdf',cur_sessionDir,header.channelNum);
            fp = fillPage(h_fig,'margins',[0 0 1 0],'papersize',[11 8.5]);
            print(h_fig,'-opengl','-dpdf','-r200',fullfile(full_cur_sessionDir,PDFname))
            close(h_fig)
        end
    end
end