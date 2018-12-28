function cmap = magma(varargin)
cmapPath = '/Users/mattgaidica/Documents/MATLAB/LeventhalLab/Development/ChoiceTask/LFPs/utils/magma.png';
if ~isempty(varargin) % set nColors
    cmap = mycmap(cmapPath,varargin{1});
else
    cmap = mycmap(cmapPath);
end