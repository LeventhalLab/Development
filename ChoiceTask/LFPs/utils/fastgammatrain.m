function [t,s] = fastgammatrain(duration,meanrate,order)
% https://www.neuron.yale.edu/phpBB/viewtopic.php?t=416
% function [t,s] = fastgammatrain(duration,meanrate,order)
%
% returns spike train output of an integrate and fire neuron with
% a random spiking threshold which is distributed according to
% a gamma distribution of order n. n=1 gives a poisson train.
% increasing n gives increasingly regular spike trains.
%
% where
% duration = duration of spiketrain (ms)
% meanrate = mean firing rate of the spike train (spikes/s)
% order = order of the gamma distribution for resetting threshold
%
% return parameters are:
% t = vector containing the time index for spike train (ms)
% s = spike train (1's represent spikes, 0's represent no spikes)


delta_t = 1; % resolution of spike train in ms

t = 0:delta_t:duration;
idur=length(t);
Vrandth = gamrnd(order,1/order,1,idur);
itonextspike =round(Vrandth/(meanrate/1000*delta_t));
itonextspike = itonextspike(itonextspike > 2); % refractory period = 0.002 ms
ispikes = cumsum(itonextspike);
ispikes = ispikes(ispikes < (duration/delta_t));
nspikes = length(ispikes);
s = sparse(1,ispikes,1,1,idur,nspikes);
if (nargout == 0)
plot(t,s)
end
s = full(s);