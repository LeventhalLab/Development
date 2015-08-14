function [figHandle] = eventRaster(eventTS, neuronTS, twidth)
%eventTS will be an 1xn array of ts pertinent to the event, i.e. start of reach
%    Also assume each eventTS entry is a different trial
%neuronTS will be an 1xn array of ts for one neuron 
%twidth(in seconds) is the window around the ts to create a plot for
%assume that no ts will be exactly matched up with event time stamp.

windowTS = zeros(length(eventTS),1);

for i=1:length(eventTS)
    idx = find(abs(eventTS(i)-neuronTS)<twidth);
    for j=1:length(idx)    
          windowTS(i,j) = neuronTS(idx(j)) - eventTS(i);
    end
end

figHandle = figure();
for i=1:length(eventTS)
    for j=1:size(windowTS,2)
        if windowTS(i,j)
        line([windowTS(i,j) windowTS(i,j)], [i-1 i])
        end
    end
end
ylim([0 length(eventTS)]);
set(gca,'TickDir','out');
xlabel('Time (s)');
ylabel('Trial #');
set(gca,'YTick',linspace(1,length(eventTS),length(eventTS)));

end