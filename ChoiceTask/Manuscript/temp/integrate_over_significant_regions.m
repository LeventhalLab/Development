function [abs_zDiff_sum,abs_zDiff_mean,zDiff_sum,zDiff_mean] = ...
    integrate_over_significant_regions(zDiff,p_values,analyzeRange, varargin)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

pCutoff = 0.01;
for iarg = 1 : 2 : nargin - 3
    switch lower(varargin{iarg})
        case 'pcutoff'
            pCutoff = varargin{iarg + 1};
    end
end

% 1 - contra
% 2 - ipsi
% 3 - both
numUnits = size(zDiff, 1);
zDiff_sum = zeros(numUnits, 3);
abs_zDiff_sum = zeros(numUnits, 3);
zDiff_mean = zeros(numUnits, 3);
abs_zDiff_mean = zeros(numUnits, 3);

sig_p_idx = zeros(size(p_values,1),size(p_values,2),3);
sig_p_idx(:,:,1) = (p_values < pCutoff);
sig_p_idx(:,:,2) = (p_values > (1-pCutoff));
sig_p_idx(:,:,3) = squeeze(sig_p_idx(:,:,1)) | squeeze(sig_p_idx(:,:,2));

zDiff_forAnalysis = zDiff(:, analyzeRange);
for iDir = 1 : 3
    
    sig_p_forAnalysis = logical(squeeze(sig_p_idx(:, analyzeRange, iDir)));

    for iUnit = 1 : numUnits
        zDiff_sum(iUnit,iDir) = sum(zDiff_forAnalysis(iUnit,sig_p_forAnalysis(iUnit,:)), 2);
        abs_zDiff_sum(iUnit,iDir) = sum(abs(zDiff_forAnalysis(iUnit,sig_p_forAnalysis(iUnit,:))), 2);
    end

    totalSigBins = sum(sig_p_forAnalysis, 2);
    zDiff_mean(:,iDir) = zDiff_sum(:,iDir) ./ totalSigBins;
    abs_zDiff_mean(:,iDir) = abs_zDiff_sum(:,iDir) ./ totalSigBins;
    
end


