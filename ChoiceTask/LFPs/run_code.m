pIdx = 8;
aIdx = 17;
phase = squeeze(angle(W(iEvent,:,:,pIdx)));
phase = phase(:)';

amplitude = squeeze(abs(W(iEvent,:,:,aIdx)).^2);
amplitude = amplitude(:)';

close all
figure;
yyaxis left;
plot(phase);
phase = circshift(phase,randi(numel(phase)));
hold on;
plot(phase,'r-');
yyaxis right;
plot(amplitude);
% polarhistogram(phase,11);

% phase = circshift(phase,randi(numel(phase)));