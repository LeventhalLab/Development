doSetup = false;

h = ff(400,800);
rows = 2;
cols = 1;
rlimVals = [0 0.02];
pMark = 0.01;
for iFreq = 1%:numel(freqList)
    if doSetup
        in_dir = [];
        in_ndir = [];
        out_dir = [];
        out_ndir = [];
        in_other = [];
        out_other = [];
        for iNeuron = 1:numel(all_ts)
            these_alphas_out = all_spikeHist_alphas{iNeuron,iFreq};
            these_alphas_in = all_spikeHist_inTrial_alphas{iNeuron,iFreq};
            if isempty(these_alphas_out) || isempty(these_alphas_in)
                continue;
            end
            if ismember(iNeuron,dirSelUnitIds)
                in_dir = [in_dir;these_alphas_in];
                out_dir = [out_dir;these_alphas_out];
            elseif ismember(iNeuron,ndirSelUnitIds)
                in_ndir = [in_ndir;these_alphas_in];
                out_ndir = [out_ndir;these_alphas_out];
            else
                in_other = [in_other;these_alphas_in];
                out_other = [out_other;these_alphas_out];
            end
        end
        % calc
        r_in_dir = circ_r(in_dir);
        r_in_ndir = circ_r(in_ndir);
        r_out_dir = circ_r(out_dir);
        r_out_ndir = circ_r(out_ndir);
        r_in_other = circ_r(in_other);
        r_out_other = circ_r(out_other);

        mu_in_dir = circ_mean(in_dir);
        mu_in_ndir = circ_mean(in_ndir);
        mu_out_dir = circ_mean(out_dir);
        mu_out_ndir = circ_mean(out_ndir);
        mu_in_other = circ_mean(in_other);
        mu_out_other = circ_mean(out_other);

        rtest_in_dir = circ_rtest(in_dir);
        rtest_in_ndir = circ_rtest(in_ndir);
        rtest_out_dir = circ_rtest(out_dir);
        rtest_out_ndir = circ_rtest(out_ndir);
        rtest_in_other = circ_rtest(in_other);
        rtest_out_other = circ_rtest(out_other);

        kuiper_in_dir_ndir = circ_wwtest(in_dir,in_ndir);
        kuiper_in_dir_other = circ_wwtest(in_dir,in_other);
        kuiper_in_ndir_other = circ_wwtest(in_ndir,in_other);
        kuiper_out_dir_ndir = circ_wwtest(out_dir,out_ndir);
        kuiper_out_dir_other = circ_wwtest(out_dir,out_other);
        kuiper_out_ndir_other = circ_wwtest(out_ndir,out_other);
        kuiper_inOut_dir = circ_wwtest(in_dir,out_dir);
        kuiper_inOut_ndir = circ_wwtest(in_ndir,out_ndir);
        kuiper_inOut_other = circ_wwtest(in_other,out_other);
    end
    
    % IN trial
    subplot(rows,cols,prc(cols,[1 iFreq]));
    lns(1) = polarplot([mu_in_dir mu_in_dir],[0 r_in_dir],'color','r','lineWidth',2); % DIR
    hold on;
    polarplot(mu_in_dir,rlimVals(2),'.','MarkerSize',30,'color','r','lineWidth',2);
    if rtest_in_dir < pMark
        polarplot(mu_in_dir,rlimVals(2),'*','MarkerSize',15,'color','r','lineWidth',1);
    end
    
    lns(2) = polarplot([mu_in_ndir mu_in_ndir],[0 r_in_ndir],'color','k','lineWidth',2); % NDIR
    polarplot(mu_in_ndir,rlimVals(2),'.','MarkerSize',30,'color','k','lineWidth',2);
    if rtest_in_ndir < pMark
        polarplot(mu_in_ndir,rlimVals(2),'*','MarkerSize',15,'color','k','lineWidth',1);
    end
    
    lns(3) = polarplot([mu_in_other mu_in_other],[0 r_in_other],'color',repmat(0.8,[1 4]),'lineWidth',1); % OTHER
    polarplot(mu_in_other,rlimVals(2),'.','MarkerSize',15,'color',repmat(0.8,[1 3]),'lineWidth',1);
    if rtest_in_other < pMark
        polarplot(mu_in_other,rlimVals(2),'*','MarkerSize',10,'color',repmat(0.8,[1 3]),'lineWidth',1);
    end
    
    legend(lns,{'dirSel','ndirSel','other'});
    ax = gca;
    ax.ThetaDir = 'counterclockwise';
    ax.ThetaZeroLocation = 'top';
    ax.ThetaTick = [0 90 180 270];
    rlim(rlimVals);
    rticks(rlimVals);
    title({[num2str(freqList(iFreq),'%1.2f'),' Hz'],'IN trial',...
        ['dir x ndir: ',num2str(kuiper_in_dir_ndir,2)],...
        ['dir x other: ',num2str(kuiper_in_dir_other,2)],...
        ['ndir x other: ',num2str(kuiper_in_ndir_other,2)]});
    
    % OUT trial
    subplot(rows,cols,prc(cols,[2 iFreq]));
    lns(1) = polarplot([mu_out_dir mu_out_dir],[0 r_out_dir],'color','r','lineWidth',2); % DIR
    hold on;
    polarplot(mu_out_dir,rlimVals(2),'.','MarkerSize',30,'color','r','lineWidth',2);
    if rtest_out_dir < pMark
        polarplot(mu_out_dir,rlimVals(2),'*','MarkerSize',15,'color','r','lineWidth',1);
    end
    
    lns(2) = polarplot([mu_out_ndir mu_out_ndir],[0 r_out_ndir],'color','k','lineWidth',2); % NDIR
    polarplot(mu_out_ndir,rlimVals(2),'.','MarkerSize',30,'color','k','lineWidth',2);
    if rtest_out_ndir < pMark
        polarplot(mu_out_ndir,rlimVals(2),'*','MarkerSize',15,'color','k','lineWidth',1);
    end
    
    lns(3) = polarplot([mu_out_other mu_out_other],[0 r_out_other],'color',repmat(0.8,[1 4]),'lineWidth',1); % OTHER
    polarplot(mu_out_other,rlimVals(2),'.','MarkerSize',15,'color',repmat(0.8,[1 3]),'lineWidth',1);
    if rtest_out_other < pMark
        polarplot(mu_out_other,rlimVals(2),'*','MarkerSize',10,'color',repmat(0.8,[1 3]),'lineWidth',1);
    end
    
    legend(lns,{'dirSel','ndirSel','other'});
    ax = gca;
    ax.ThetaDir = 'counterclockwise';
    ax.ThetaZeroLocation = 'top';
    ax.ThetaTick = [0 90 180 270];
    rlim(rlimVals);
    rticks(rlimVals);
    title({'OUT trial',...
        ['dir x ndir: ',num2str(kuiper_out_dir_ndir,2)],...
        ['dir x other: ',num2str(kuiper_out_dir_other,2)],...
        ['ndir x other: ',num2str(kuiper_out_ndir_other,2)],...
        ['INxOUT dir: ',num2str(kuiper_inOut_dir,2),', ndir: ',num2str(kuiper_inOut_ndir,2),', other: ',num2str(kuiper_inOut_other,2)]});
    
    set(gcf,'color','w');
end

nBins = 20;
figure;
h1 = polarhistogram(in_dir,nBins,'FaceColor','r');
h1.DisplayStyle = 'stairs';
hold on;
ax = gca;
ax.ThetaDir = 'counterclockwise';
ax.ThetaZeroLocation = 'top';
ax.ThetaTick = [0 90 180 270];
h2 = polarhistogram(in_ndir,nBins,'FaceColor','k');
h2.DisplayStyle = 'stairs';
