function FR = eventSmoothFR(neuronTS)
sigma = .05; %s
dt = .001; %s
binwidth = .001;
binned = hist(neuronTS,[0:binwidth:1-binwidth]);
edges = [-3*sigma: dt: 3*sigma];
kernel = normpdf(edges,0,sigma);
FR = conv(binned,kernel,'same');


figure();
plot(0:binwidth:1-binwidth,FR);
xlabel('time(s)');ylabel('Firing Rate')
hold on; 
plot([0:.001:1-dt],binned)

%sliding window for comparison
dt = .01
t= 0:dt:1-dt
for i=1:length(t)
slidingFR(i)= length(find(neuronTS < t(i)+dt & neuronTS > t(i)))./dt;
end

plot(t,slidingFR)


end