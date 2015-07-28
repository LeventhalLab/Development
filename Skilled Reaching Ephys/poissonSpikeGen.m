function [neuronTS] = poissonSpikeGen(fr, tSim)
dt = 1/1000; % s
nBins = floor(tSim/dt);
spikeMat = rand(1, nBins) < fr*dt;
tVec = 0:dt:tSim-dt;
neuronTS = [];
for j = 1:size(spikeMat,2)
    if spikeMat(j)==1
        neuronTS=[neuronTS tVec(j)];
    end
end
end