%poissonSurprise.m
%Burst detector using the Poisson Surprise method
%Input: time stamps

function poissonSurprise(ts)
threshSurprise = 3;
width = 20; %s
minNumSpikes = 3;
interval = .5; %s
endTime = ts(length(ts));
sValues = [];
times = [];
aveFR = length(ts)/(ts(length(ts)) - ts(1));

%Plot the time stamps
subplot(211);
y = ones(1, length(ts));
plot(ts, y, '.');

%Sliding window
for i = ts(1): interval: endTime
    numSpikes = 0;
    burst = [];
    %Find number of spikes within time window
     for z = 1:length(ts)
         if (ts(z) < i + width) && (ts(z) > i)
             numSpikes = numSpikes + 1;
             burst = [burst ts(z)];
         end
     end
    %Calculate firing rate within the window
    %firingRate = numSpikes/width;
    %Get the surprise value
    S = getSvalue(aveFR, burst(length(burst)) - i, minNumSpikes);
    
    %Store times and Surprise values
    times = [times i];
    sValues = [sValues S];
end

%Plot surprise values
subplot(212);
plot(times, sValues);
hold on;
t = zeros(1, length(times));
t = t + threshSurprise;
plot(times, t, '--');
axis([ts(1) endTime 0 10]);

end

%Function to get the Surprise value
%Inputs: Firing Rate, window size, minimum number of spikes per burst
%Output: Surprise value
function [S] = getSvalue(fr, time, minNumSpikes)
syms k;
f = exp(-fr*time)*((fr*time)^k)/factorial(k);
P = symsum(f, k, minNumSpikes, Inf);
%P = exp(-fr*time)*sum;
S = -log(P);
end
