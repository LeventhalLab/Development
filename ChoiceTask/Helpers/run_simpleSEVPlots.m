testDir = '/Users/mattgaidica/Desktop/test-2';
files = dir(fullfile(testDir,'*.sev'));
filenames = natsort({files(:).name})';

channels = [9 11 13 15];

figure('position',[0 0 900 500]);
for iCh = 1:4
    subplot(4,1,iCh);
    curCh = channels(iCh);
    curFile = fullfile(testDir,filenames{curCh});
    [fdata,header] = filterSev(curFile);
    if iCh == 1 && ~exist('x','var')
        h1 = figure;
        plot(fdata);
        [x,y] = ginput(1);
        x = round(x);
        close(h1);
    end
    ax(iCh) = plot(fdata(x:x+round(header.Fs)));
    ylim([-500 500]);
    drawnow;
end

linkaxes(ax);