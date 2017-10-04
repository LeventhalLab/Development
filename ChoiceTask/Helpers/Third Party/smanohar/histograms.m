function histograms(data,criteria,bins, normalise)
% histograms ( data, criteria, bins )
% data is an array same size as criteria.
% each each unique value of criteria generates a sepearate histogram.
% colours taken from the current colormap.
% bins - number of histogram bars per dataset
if exist('bins')~=1, bins=50;end;
if exist('normalise')~=1, normalise=1;end;
if exist('criteria')~=1, criteria=repmat([1:size(data,1)]',1,size(data,2));end;
u=unique(criteria);
n=length(u);
c=colormap;
cs='rgbcymk';
LINE=1;

for i=1:n
    [dh(i,:),dbin(i,:)]=hist(data(criteria==u(i)),bins);
end
N=sum(sum(dh));
for i=1:n
    cc=cs(mod(i,length(cs))); %it(i,n,c)
    if LINE
        plot(dbin(i,:), dh(i,:)/sum(dh(i,:)),cc);
    else
        bar(dbin(i,:), dh(i,:)/sum(dh(i,:)), cc);
        h = findobj(gca,'Type','patch', 'EdgeColor', 'k');
        set(h(end),'EdgeColor',cc, 'FaceColor','none', 'LineWidth',2);
    end;
    leg{i}=num2str(u(i));
    hold on;
end;
hold off;
legend(leg{:});

function r=it(i,n,c)
p=(i-1)/(n);
nc=size(c,1);
r=c(1+floor(nc*p),:);
