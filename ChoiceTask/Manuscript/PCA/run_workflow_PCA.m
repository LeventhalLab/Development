useDir = ''; % '' or 'ipsi' or 'contra'
shortPCA = true;
timingField = 'RT'; % timing assumes useDir = '';
run_compile_PCAarr
run_compute_PCA
sessionPCA_RT = sessionPCA;
sessionPCA_500ms = sessionPCA;
sessionPCA_500ms_RT = sessionPCA;

useDir = ''; % '' or 'ipsi' or 'contra'
shortPCA = true;
timingField = 'MT'; % timing assumes useDir = '';
run_compile_PCAarr
run_compute_PCA
sessionPCA_500ms_MT = sessionPCA;

useDir = ''; % '' or 'ipsi' or 'contra'
shortPCA = false;
timingField = 'RT'; % timing assumes useDir = '';
run_compile_PCAarr
sessionPCA_1000ms = sessionPCA;

useDir = 'contra'; % '' or 'ipsi' or 'contra'
shortPCA = false;
timingField = 'RT'; % timing assumes useDir = '';
run_compile_PCAarr
sessionPCA_1000ms_contra = sessionPCA;

useDir = 'ipsi'; % '' or 'ipsi' or 'contra'
shortPCA = false;
timingField = 'RT'; % timing assumes useDir = '';
run_compile_PCAarr
sessionPCA_1000ms_ipsi = sessionPCA;

if false

    % first get all the data formatted *using preferred time windows*
    % e.g., PCA_arr(iEvent,neuronCount,startRange:endRange)
    % tWindow >> tWindow_vis because of edge effect
    % tWindow = 2;
    % tWindow_vis = 0.5;
    run_compile_PCAarr

    % compute PCs for each session and event
    % e.g., sessionPCA(iSession).coeff & sessionPCA(iSession).explained
    run_compute_PCA.m
    % save
    sessionPCA_500ms = sessionPCA; % save

    % re-compile if visualization time window is different (+/-1s)
    % tWindow = 3;
    % tWindow_vis = 1;
    run_compile_PCAarr
    sessionPCA_1000ms = sessionPCA; % save

    % save the session in case MATLAB crashes
    % !!! why is this >7GB right now?
    save(['session_',datestr(now,'YYYYMMDD'),'_PCA'],'analysisConf','eventFieldnames','all_ts','sessionPCA_500ms','sessionPCA_1000ms','-v7.3');


    % how to do directional selectivity
    useDir = 'ipsi'; % or '' or 'contra'
    % then
    run_compile_PCAarr
    % then
    % % run_compute_PCA.m
    % % sessionPCA_500ms_ipsi = sessionPCA; % save
    % % sessionPCA_500ms_contra = sessionPCA; % save

    sessionPCA_1000ms_ipsi = sessionPCA; % save
    sessionPCA_1000ms_contra = sessionPCA; % save
end