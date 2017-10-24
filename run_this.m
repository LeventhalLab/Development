% % dirSelNeurons_contra_incorrContra
% % dirSelNeurons_ipsi_incorrIpsi
% % dirSelNeurons_sameDir
% % 
% % dirSelNeurons_contra_incorrIpsi
% % dirSelNeurons_ipsi_incorrContra
% % dirSelNeurons_not_sameDir





figure;
barData = [sum(dirSelNeurons_contra_corr) sum(dirSelNeurons_ipsi_corr);...
    sum(dirSelNeurons_contra_incorrContra) sum(dirSelNeurons_ipsi_incorrIpsi);...
    sum(dirSelNeurons_contra_incorrIpsi) sum(dirSelNeurons_ipsi_incorrContra)];
bar(barData);
xticklabels({['corr (',num2str(barData(1,:)),' = ',num2str(sum(barData(1,:))),')'],...
    ['+incorr SAME move (',num2str(barData(2,:)),' = ',num2str(sum(barData(2,:))),')'],...
    ['+incorr DIFF move (',num2str(barData(3,:)),' = ',num2str(sum(barData(3,:))),')']});
xtickangle(30);
ylim([0 80]);

title('dirSel when incorr trials are included');

[x2,p] = chiSquare(sum(dirSelNeurons_contra_corr),sum(dirSelNeurons_ipsi_corr),...
    sum(dirSelNeurons_contra_incorrContra),sum(dirSelNeurons_ipsi_incorrIpsi));
text(1.5,40,{['\chi^2 = ',num2str(x2,'%1.3f')],['p = ',num2str(1-p,'%0.5f')]},'HorizontalAlignment','center');

[x2,p] = chiSquare(sum(dirSelNeurons_contra_corr),sum(dirSelNeurons_ipsi_corr),...
    sum(dirSelNeurons_contra_incorrIpsi),sum(dirSelNeurons_ipsi_incorrContra));
text(2,70,{['\chi^2 = ',num2str(x2,'%1.3f')],['p = ',num2str(1-p,'%0.5f')]},'HorizontalAlignment','center');

[x2,p] = chiSquare(sum(dirSelNeurons_contra_incorrContra),sum(dirSelNeurons_ipsi_incorrIpsi),...
    sum(dirSelNeurons_contra_incorrIpsi),sum(dirSelNeurons_ipsi_incorrContra));
text(2.5,40,{['\chi^2 = ',num2str(x2,'%1.3f')],['p = ',num2str(1-p,'%0.5f')]},'HorizontalAlignment','center');



% % dirSelNeurons_contra_corr = dirSelNeurons_contra;
% % dirSelNeurons_ipsi_corr = dirSelNeurons_ipsi;
% % dirSelNeurons_corr = dirSelNeurons;