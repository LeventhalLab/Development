function ffp()
if ismember(0,xlim)
    xticks(xlim);
else
    xticks(sort([0,xlim]));
end
if ismember(0,ylim)
    yticks(ylim);
else
    yticks(sort([0,ylim]));
end

set(gca,'fontSize',16);
set(gcf,'color','w');
grid on;