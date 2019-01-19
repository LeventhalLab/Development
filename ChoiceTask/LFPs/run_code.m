t = linspace(-pi*3,pi*3,1000);
a = sin(t);
b = a;

h = ff(800,800);
rows = 3;
cols = 2;

for iCol = 1:2
    if iCol == 1
        b = a;
    else
        b = -a;
    end
    subplot(rows,cols,prc(cols,[1,iCol]));
    plot(t,a,'lineWidth',3);
    hold on;
    plot(t,b,':','lineWidth',3);
    legend('signal a','signal b');
    title('source signals');
    grid on;

    subplot(rows,cols,prc(cols,[2,iCol]));
    [acor,lag] = xcorr(a,b);
    plot(lag,acor,'k','lineWidth',3);
    title('raw xcorr');
    grid on;

    subplot(rows,cols,prc(cols,[3,iCol]));
    [acor,lag] = xcorr(a,b,'coeff');
    plot(lag,acor,'k','lineWidth',3);
    title('norm xcorr');
    grid on;
end