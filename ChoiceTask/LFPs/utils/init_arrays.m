testVals = 0:1000000:100000000; % 0 to 100 million, step 1 million
nTests = numel(testVals);
runTest = true;

if runTest
    tVals_uninit = [];
    for iTest = 1:nTests
        disp(iTest);
        a = [];
        tic;
        for ii = 1:testVals(iTest)
            a(ii) = 1;
        end
        tVals_uninit(iTest) = toc;
    end

    tVals_init = [];
    for iTest = 1:nTests
        a = zeros(testVals(iTest),1);
        tic;
        for ii = 1:testVals(iTest)
            a(ii) = 1;
        end
        tVals_init(iTest) = toc;
    end
end

h = figure('position',[0,0,800,500]);
plot(tVals_init,'lineWidth',3);
hold on;
plot(tVals_uninit,'lineWidth',3);

xtickLocs = [1 find(testVals == 1e6) find(testVals == 1e7) nTests];
xticks(xtickLocs);
xticklabels({'0','1 Million','10 Million','100 Million'});
set(gca,'xscale','log');
xlabel('Array Elements');

ylabel('Time (s)');

legend({'Initialized','Uninitialized'},'location','northwest');
title('Time to Build Array in MATLAB');
set(gca,'fontSize',16);
set(gcf,'color','w');