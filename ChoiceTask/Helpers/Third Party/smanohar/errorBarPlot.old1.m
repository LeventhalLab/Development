function h=errorBarPlot(X, varargin)
% h = errorBarPlot(X, varargin)
% plot with within-subject standard error bars - means are taken over dimension 1.
% options:  'maineffect' dim 
%                dim should be 2 or 3 to indicate a main effect of
%                dimension 2 or 3 of the data.
%                subtract the mean for that dimension from all values
%                before averaging and taking std error. then add on the
%                mean before plotting.
%           'area': use dotted lines for min and max of std error. If
%                stdshade is available, use that (available from Mathworks
%                website)
%           'alpha': after area - use an alpha for call to 'stdshade' when
%                plotting .
%           'xaxisvalues': specify the x-values of the graph. Otherwise
%                just uses 1,2,3...
% 
% PS due to the clunky way i've written it, the params MUST come in this
% order!
% SGM 2014
addon=0;
try
 
  [medim, AREA, alpha, xaxisvalues, SMOOTH] = parsepvpairs({'MainEffect', 'Area', 'Alpha', 'xaxisvalues', 'smooth'}, ...
    {[], false, 0.5, [], 1}, ... 
    varargin{:});
catch me
  medim=[]; AREA=false; alpha=0.5; xaxisvalues=[]; SMOOTH=1;
  warning('all varargins to errorbarplot will now be passed to Plot');
end
if ~isempty(medim) % main effect analysis - remove means across all dimensions except the specified one before doing standard deviation
    if(medim==3)
        addon=sq(repmat(nanmean(nanmean(X,1),2),[1,size(X,2),1]));
        X=X-repmat(nanmean(X,3),[1,1,size(X,3)]);
    elseif medim==2
        addon=sq(repmat(nanmean(nanmean(X,1),3),[1,1,size(X,3)]));
        X=X-repmat(nanmean(X,2),[1,size(X,2),1]);
    end
end

WITHINSUBJECTERROR=1;
if(WITHINSUBJECTERROR)
  sx=size(X); M=nanmean(nanmean(nanmean(nanmean(X))));
  m2 = nanmean(X,2); if(size(m2,3)>1) m2=nanmean(nanmean(m2,3),4); end
  Xm=X-repmat(m2, [1, sx(2:end)] ); % subtract subject mean
  Xm=Xm+M;
end
NS = sum(~isnan(X),1);
error = sq(bsxfun(@rdivide, sqrt(nanvar(Xm,[],1)), sqrt(NS)));

if ~AREA
  Y=sq(nanmean(X,1))+addon;
  sizey = size(Y);
  linestyles={'-',':','--','-.'}; % set of line styles for groups
  if isempty(xaxisvalues)
    if length(sizey)>2 % if multidimensional, use line styles! (2014)
      h=[]; % keep handles of plots
      washold=ishold(); % store hold state
      for i=1:prod(sizey(3:end)) % for each grouping
        h=[h errorbar(Y(:,:,i), error(:,:,i), varargin{:}, ...
          'linestyle',linestyles{1+mod(i-1,length(linestyles))})];
        hold on;
      end
      if ~washold, hold off; end % restore hold state
    else
      h=errorbar(Y,error, varargin{:}); % Y has just 2 dimensions
    end
  else
    if (isrow(xaxisvalues) && iscolumn(Y)) || (iscolumn(Y)) && isrow(xaxisvalues)
      xaxisvalues=xaxisvalues'; 
    end;
    xaxisvalues=bsxfun(@(a,b)a,xaxisvalues, Y);
    if length(sizey)>2
      h=[]; % keep handles of plots
      washold=ishold(); % store hold state
      for i=1:prod(sizey(3:end)) % for each grouping
        h=[h errorbar(xaxisvalues, Y(:,:,i), error(:,:,i), varargin{:}, ...
          'linestyle',linestyles{1+mod(i-1,length(linestyles))})];
        hold on;
      end
      if ~washold, hold off; end % restore hold state      
    else
      h=errorbar(xaxisvalues, Y,error, varargin{:});
    end
  end
else
  ho=ishold();
  if ~exist('stdshade','file')
    h1=plot(sq(nanmean(X,1))+addon, varargin{:});
    hold on
    h2=plot(sq(nanmean(X,1))+addon+error, varargin{:},'linestyle',':');
    h3=plot(sq(nanmean(X,1))+addon-error, varargin{:},'linestyle',':');
    h=[h1 h2 h3];
  else
    col=get(gca,'ColorOrder');
    for i=1:size(X,3) % for each line
      if ~isempty(xaxisvalues)
        h=stdshade(X(:,:,i), alpha, col(i,:),  xaxisvalues, SMOOTH);
      else
        h=stdshade(X(:,:,i), alpha, col(i,:), [], SMOOTH);
      end
      hold on
    end
  end
  if(~ho) hold off; end
end


function h=stdshade(amatrix,alpha,acolor,F,smth)
% usage: stdshading(amatrix,alpha,acolor,F,smth)
% plot mean and sem/std coming from a matrix of data, at which each row is an
% observation. sem/std is shown as shading.
% - acolor defines the used color (default is red) 
% - F assignes the used x axis (default is steps of 1).
% - alpha defines transparency of the shading (default is no shading and black mean line)
% - smth defines the smoothing factor (default is no smooth)
% smusall 2010/4/23
if exist('acolor','var')==0 || isempty(acolor)
    acolor='r'; 
end

if exist('F','var')==0 || isempty(F); 
    F=1:size(amatrix,2);
end

if exist('smth','var'); if isempty(smth); smth=1; end
else smth=1;
end  

if ne(size(F,1),1)
    F=F';
end

% astd=nanstd(amatrix); % to get std shading
astd=nanstd(amatrix)/sqrt(size(amatrix,1)); % to get sem shading
amean=nanmean(amatrix);
if smth>1
  astd  = smooth(astd, smth, 'boxcar');
  amean = smooth(amean, smth, 'boxcar');
end

col1=get(gca,'colororder');
if exist('alpha','var')==0 || isempty(alpha) 
    h=fill([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor,'linestyle','none');
    acolor=col1(1);
else h=fill([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor, 'FaceAlpha', alpha,'linestyle','none');    
end

if ishold==0
    check=true; else check=false;
end

hold on;h1=plot(F,amean,'color',acolor,'linewidth',1.5); %% change color or linewidth to adjust mean line
h=[h h1];
if check
    hold off;
end


