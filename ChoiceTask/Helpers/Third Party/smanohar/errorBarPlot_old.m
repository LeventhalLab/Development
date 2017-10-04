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
addon=0;
if length(varargin)>1 &&  strcmp(varargin{1},'maineffect')
    medim=varargin{2};
    varargin(1:2)=[];
    if(medim==3)
        addon=sq(repmat(nanmean(nanmean(X,1),2),[1,size(X,2),1]));
        X=X-repmat(nanmean(X,3),[1,1,size(X,3)]);
    elseif medim==2
        addon=sq(repmat(nanmean(nanmean(X,1),3),[1,1,size(X,3)]));
        X=X-repmat(nanmean(X,2),[1,size(X,2),1]);
    end
end
if length(varargin)>0 &&  strcmpi(varargin{1},'area')
  AREA=true;
  varargin(1)=[];
else AREA=false;
end
if length(varargin)>0 &&  strcmpi(varargin{1},'alpha')
  alpha=varargin{2};
  varargin(1:2)=[];
else alpha=0.5;
end
if length(varargin)>0 && strcmpi(varargin{1},'xaxisvalues')
  xaxisvalues=varargin{2};
  varargin(1:2)=[];
else xaxisvalues=[];
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
  if isempty(xaxisvalues)
    h=errorbar(Y,error, varargin{:});
  else
    if (isrow(xaxisvalues) && iscolumn(Y)) || (iscolumn(Y)) && isrow(xaxisvalues)
      xaxisvalues=xaxisvalues'; 
    end;
    xaxisvalues=bsxfun(@(a,b)a,xaxisvalues, Y);
    h=errorbar(xaxisvalues, Y,error, varargin{:});
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
      stdshade(X(:,:,i), alpha, col(i,:), varargin{:});
      hold on
    end
  end
  if(~ho) hold off; end
end


function stdshade(amatrix,alpha,acolor,F,smth)
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

amean=smooth(nanmean(amatrix),smth)';
% astd=nanstd(amatrix); % to get std shading
astd=nanstd(amatrix)/sqrt(size(amatrix,1)); % to get sem shading

col1=get(gca,'colororder');
if exist('alpha','var')==0 || isempty(alpha) 
    fill([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor,'linestyle','none');
    acolor=col1(1);
else fill([F fliplr(F)],[amean+astd fliplr(amean-astd)],acolor, 'FaceAlpha', alpha,'linestyle','none');    
end

if ishold==0
    check=true; else check=false;
end

hold on;plot(F,amean,'color',acolor,'linewidth',1.5); %% change color or linewidth to adjust mean line

if check
    hold off;
end


