t = linspace(-pi*3,pi*3,1000);
x = sin(t);
close all;
h = ff(800,600);
rows = 3;
cols = 2;

for iCol = 1:2
    if iCol == 1
        y = x*4;
    else
        y = -x*4;
    end
    subplot(rows,cols,prc(cols,[1,iCol]));
    plot(x,'lineWidth',3);
    hold on;
    plot(y,':','lineWidth',3);
    legend('signal x','signal y');
    title('source signals');
    grid on;
    set(gca,'fontSize',16);

    subplot(rows,cols,prc(cols,[2,iCol]));
    [acor,lag] = xcorr(x,y);
    plot(lag,acor,'k','lineWidth',3);
    title('xcorr(x,y)');
    grid on;
    set(gca,'fontSize',16);

    subplot(rows,cols,prc(cols,[3,iCol]));
%     [acor,lag] = xcorr(a,b,'coeff');
acor = xcorr(x,y)/sqrt(sum(abs(x).^2)*sum(abs(y).^2));
    plot(lag,acor,'r','lineWidth',3);
    title("xcorr(x,y,'coeff')");
    grid on;
    set(gca,'fontSize',16);
    xlabel('"x lags y"');
end
set(gcf,'color','w');