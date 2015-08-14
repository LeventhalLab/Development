function FR = eventSmoothFR(neuronTS,tStart,tEnd,dt,varargin)
%neuronTS is a 1xn array of spike timestamps
%tStart is what part of the neuron timeline to start analyzing(in seconds)
%tEnd is what part of the neuron timeline to stop analyzing
%dt is the time step (usually .001)
%Can pass in 'plot' for varargin to have it plot the firing rate

%Adjusting the edges and sigma itself is a reflection of how accurate, aka
%'confidence interval' that a neuron fired. Will change smoothed output.



sigma = .05; %s
binwidth = .001;
binned = hist(neuronTS(find(neuronTS>tStart & neuronTS<tEnd)),[tStart:binwidth:tEnd-binwidth]);
edges = [-3*sigma: dt: 3*sigma];
kernel = normpdf(edges,0,sigma);
FR = conv(binned,kernel,'same');

if nargin >4
    if varargin{1} == 'plot'
        figure();
        plot(tStart:binwidth:tEnd-binwidth,FR);
        xlabel('time(s)');ylabel('Firing Rate(hz)')
        hold on; 
        plot([tStart:binwidth:tEnd-binwidth],binned)
    end
end
%sliding window for comparison
% dt = .01
% t= 0:dt:1-dt
% for i=1:length(t)
% slidingFR(i)= length(find(neuronTS < t(i)+dt & neuronTS > t(i)))./dt;
% end
% 
% plot(t,slidingFR)


end