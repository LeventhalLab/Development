function [maxB, idx] = maxmag(B)
[maxB, idx] = max(abs(B(:)));
maxB = maxB * sign(B(idx));