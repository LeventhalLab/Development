function [h_fig, h_axes, varargout] = createFigPanels5(figProps, varargin) %Takes the figure proportions and the 
%
% usage: [h_fig, h_axes] = createFigPanels5(figProps, varargin)
%
% INPUTS:
%   figProps - structure containing formatting for the figure. All
%   measurements in cm
%       .m = number of rows in the figure
%       .n = number of columns in the figure
%       .panelWidth = n-element vector containing the width of the axes in 
%           each column
%       .panelHeight = m-element vector containing the height of the axes 
%           in each row
%       .colSpacing = (n-1) element vector containing the horizontal
%           between axes in each column
%       .rowSpacing = (m-1) element vector containing the vertical
%           between axes in each column
%       .width = width of the figure (cm)
%       .height = height of the figure (cm)
%       .topMargin = space left at the top of the figure for header info
%
% VARARGs:
%   units - units to use in drawing the figure (e.g., pixels, centimeters,
%       etc.). Use the standard matlab figure unit options

unitName = 'centimeters';

for iarg = 2 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'units',
            unitName = varargin{iarg + 1};
    end
end
% 
% h_fig = figure('units',unitName,...
%                'position',[1 1 figProps.width figProps.height], ...
%                'color','w');
           
h_fig = figure('units',unitName,...
               'position',[1 1 figProps.width figProps.height], ...
               'paperunits',unitName,...
               'papersize',[figProps.width figProps.height], ...
               'color','w');

actualFigurePosition = get(h_fig,'position');
x_scaleRatio = actualFigurePosition(3) / figProps.width;
y_scaleRatio = actualFigurePosition(4) / figProps.height;
figProps.width  = actualFigurePosition(3);
figProps.height = actualFigurePosition(4);

figProps.panelWidth  = figProps.panelWidth * x_scaleRatio;
figProps.panelHeight = figProps.panelHeight * y_scaleRatio;

figProps.colSpacing = figProps.colSpacing * x_scaleRatio;
figProps.rowSpacing = figProps.rowSpacing * y_scaleRatio;
figProps.topMargin  = figProps.topMargin * y_scaleRatio;

m = figProps.m; n = figProps.n;

h_axes = zeros(m, n);

fullPanelWidth = sum(figProps.panelWidth) + sum(figProps.colSpacing);
ltMargin = (figProps.width - fullPanelWidth) / 2;
if ltMargin < 0
    disp('panels will not fit horizontally');
    return;
end
fullPanelHeight = sum(figProps.panelHeight) + sum(figProps.rowSpacing);
botMargin = (figProps.height - figProps.topMargin - fullPanelHeight);
if botMargin < 0
    disp('panels will not fit vertically');
    return;
end

for iRow = 1 : m
    
    for iCol = 1 : n
%     fprintf('row %d, col %d\n', iRow, iCol)
        leftEdge = ltMargin + sum(figProps.panelWidth(1:iCol-1)) + sum(figProps.colSpacing(1:iCol-1));
        if iRow == m
            botEdge = botMargin;
        else
            botEdge  = botMargin + sum(figProps.panelHeight(iRow+1:end)) + sum(figProps.rowSpacing(iRow:end));
        end
        h_axes(iRow, iCol) = axes('parent',h_fig, ...
                                  'units',unitName, ...
                                  'position',[leftEdge, botEdge, figProps.panelWidth(iCol), figProps.panelHeight(iRow)]);
                              
    end
    
end

varargout{1} = figProps;