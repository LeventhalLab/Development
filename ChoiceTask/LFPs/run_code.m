% close all;
ff(600,800);
rows = 4;
cols = 2;
iEvent = 7;
thisPhase = squeeze(dataPhase(iEvent,:,:));
useTrials = 1:100;

natPhase = (2*pi)/(size(thisPhase,2)/(tWindow*2)/freqList);

t = linspace(-tWindow,tWindow,size(thisPhase,2));
for iTrial = useTrials
    subplot(rows,cols,prc(cols,[1,1]));
    plot(t,thisPhase(iTrial,:));
    hold on;
end
xlabel('time (s)');
ylabel('phase');
title(['showing ',num2str(max(useTrials)),' trials']);

t = linspace(-tWindow,tWindow,size(thisPhase,2));
for iTrial = useTrials
    subplot(rows,cols,prc(cols,[2,1]));
    plot(t,unwrap(thisPhase(iTrial,:)));
    hold on;
end
xlabel('time (s)');
title('1. unwrapped');
ylabel('~phase');

t = linspace(-tWindow,tWindow,size(thisPhase,2)-1);
for iTrial = useTrials
    subplot(rows,cols,prc(cols,[3,1]));
    plot(t,diff(unwrap(thisPhase(iTrial,:))));
    hold on;
end
xlabel('time (s)');
title('2. diff(unwrapped)');
ylabel('~phase');

t = linspace(-tWindow,tWindow,size(thisPhase,2)-1);
for iTrial = useTrials
    subplot(rows,cols,prc(cols,[4,1]));
    plot(t,diff(unwrap(thisPhase(iTrial,:))) - natPhase);
    hold on;
end
xlabel('time (s)');
title({'3. diff(unwrapped) - 2.5 Hz baseline'});
ylabel('~phase');

t = linspace(-tWindow,tWindow,size(thisPhase,2)-1);
for iTrial = useTrials
    subplot(rows,cols,prc(cols,[1,2]));
    plot(t,abs(diff(unwrap(thisPhase(iTrial,:))) - natPhase));
    hold on;
end
xlabel('time (s)');
title({'4. abs(diff(unwrapped) - 2.5 Hz baseline)'});
ylabel('~phase');

t = linspace(-tWindow,tWindow,size(thisPhase,2)-1);
vals = [];
for iTrial = useTrials
    subplot(rows,cols,prc(cols,[2,2]));
    vals(iTrial,:) = abs(diff(unwrap(thisPhase(iTrial,:))) - natPhase);
% %     plot(t,vals(iTrial,:));
% %     hold on;
end
plot(t,mean(vals),'k','linewidth',2);
legend({'mean'});
xlabel('time (s)');
title({'5. mean(abs(diff(unwrapped) - 2.5 Hz baseline))'});
ylabel('~phase');