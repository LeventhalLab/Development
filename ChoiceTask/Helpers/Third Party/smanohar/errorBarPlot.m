function h=errorBarPlot(X, varargin)
% h = errorBarPlot(X, varargin)
% plot with within-subject standard error bars - means are taken over dimension 1.
% options:
%           'area': 0 = error bars only
%                1 = shaded transparent area
%                2 = use dotted lines for min and max of std error. 
%                3 or greater: show Quantiles. 3=[.33 to .66], 4=[.25 to .75],
%                  5=[.2 to .8, and .4 to .6], etc. Note: median used, meanfun ignored. 
%           'alpha': after area - use an alpha for call to 'fill' when
%                plotting . Default 0.5
%           'xaxisvalues': specify the x-values of the graph. Otherwise
%                just uses 1,2,3...
%           'maineffect' dim 
%                dim should be 2 or 3 to indicate a main effect of
%                dimension 2 or 3 of the data.
%                subtract the mean for that dimension from all values
%                before averaging and taking std error. then add on the
%                mean before plotting.%           'withinSubjectError' - subtract subjects' intercepts before
%                calculating error bars. Default 0.
%           'standardError': 1 = use SEM for error bars (default).
%                0 = calculate bootstrapped confidence intervals at p=0.05.
%                    In that case, also specify 'nBoot' = num permutations.
%                2 = use standard deviation
%                between 0 and 0.5: use percentile above and below median
%           'width':  adjust the width of the errorbars. needs 'errorbarT.m'
%               function (download from Matlab Central)
%           'type': 'line' (default) or 'bar'. Note, 'area' only works with
%                line. 'bar' needs 'barwitherr.m', download from Matlab Central.
%           'meanfun' : function to calculate mean. Default: @nanmean
%                if using this, and you want error bars to reflect the
%                deviation of this value, use 'standardError' false.
%           'plotargs':  send the following items to 'plot'. Arguments
%                should be in a cell array.
% Sanjay Manohar 2014

% 1. Decide upon parameters
DEFAULT_WITHIN_SUBJECT_ERROR = 1;
if exist('nanmean','file'),   fmean = @nanmean; % mean function
else                          fmean = @mean; end
try
  % read parameters
  [medim, AREA, alpha, xaxisvalues, SMOOTH, plotargs,...
    WITHINSUBJECTERROR, STANDARD_ERROR, NBOOT, WIDTH, COLOR, ...
    TYPE, fmean, PLOT_INDIVIDUALS] = parsepvpairs( ...
  {'MainEffect', 'Area', 'Alpha', 'xaxisvalues', 'smooth', 'plotargs', ...
    'withinSubjectError', 'standardError', 'nBoot' , 'width','color', ...
    'type' , 'meanfun','plotIndividuals'}, ...
    {[], false, 0.5,     [],         1,       {} , ...
     DEFAULT_WITHIN_SUBJECT_ERROR, 1,     5000,   [],     [] ...
     'line', @nanmean ,false}, ... 
    varargin{:});
  varargin={};
catch me
  medim=[]; AREA=false; alpha=0.5; xaxisvalues=[]; SMOOTH=1; 
  WITHINSUBJECTERROR=DEFAULT_WITHIN_SUBJECT_ERROR;
  PLOT_INDIVIDUALS = false;
  STANDARD_ERROR=1; WIDTH=[]; COLOR=[]; TYPE='line';
  warning('all varargins to errorbarplot will now be passed to Plot. Use plotArgs next time, please.');
  plotargs=varargin;
end
DOTTED_AREA = AREA==2; % use dotted line above and below, instead of area plot

if ~isempty(COLOR), plotargs=[plotargs {'color',COLOR}]; end

% 2. Calculate main effects 
addon=0;
if ~isempty(medim) % main effect analysis? 
    % remove means across all dimensions except the specified one 
    % before doing standard deviation
    if(medim==3)
        addon=sq(repmat(fmean(fmean(X,1),2),[1,size(X,2),1]));
        X=X-repmat(fmean(X,3),[1,1,size(X,3)]);
    elseif medim==2
        addon=sq(repmat(fmean(fmean(X,1),3),[1,1,size(X,3)]));
        X=X-repmat(fmean(X,2),[1,size(X,2),1]);
    else error('Please could you use MainEffect on dimension 2 or 3');
    end
end

% 3. Calculate error bars
if WITHINSUBJECTERROR  % within subject error bars?
  % subtract between-subject means first
  sx=size(X); M=fmean(fmean(fmean(fmean(X,1),2),3),4);
  m2 = fmean(X,2); if(size(m2,3)>1) m2=fmean(fmean(m2,3),4); end
  Xm=X-repmat(m2, [1, sx(2:end)] ); % subtract subject mean
  Xm=Xm+M;
  if all( sum(sum(~isnan(X),2),3) < 2 ), % are they all "one condition per subject"?
    Xm=X; 
    warning('one condition per subject: using between subjects error');
  end
else % Otherwise use raw values to compute standard error
  Xm=X;
end
NS = sum(~isnan(X),1); % num subjects

% use standard error? or bootstrapped confidence intervals?
if STANDARD_ERROR==1 % standard error calculation 
  yerror  = sq(bsxfun(@rdivide, sqrt(nanvar(Xm,[],1)), sqrt(NS)));
  yerrorm = yerror; % 'minus' errors same as 'plus' errors
elseif STANDARD_ERROR ==2 % use standard deviation?
  yerror  = sq(sqrt(nanvar(Xm,[],1)));
  yerrorm = yerror;
elseif STANDARD_ERROR < 0.5 % treat fraction as percentile for bar
  yerror  =   quantile(Xm, 0.5+STANDARD_ERROR) - fmean(Xm);
  yerrorm = -(quantile(Xm, 0.5-STANDARD_ERROR) - fmean(Xm));
else              % bootstrap confidence interval at 5%
  yerror  = bootci(NBOOT, {fmean, Xm}, 'type', 'bca');
  yerrorm = -squeeze(yerror(1,:,:,:))+squeeze(fmean(Xm)); % minus errors
  yerror  = squeeze(yerror(2,:,:,:))-squeeze(fmean(Xm)); % plus errors
end

% 4. Draw the graph
ho=ishold(); % preserve hold-on status
if ~AREA % normal points/lines
  Y=sq(fmean(X,1))+addon; % get the mean across subjects
  if isrow(Y) Y=Y'; end;  % make sure it is a column
  if isempty(xaxisvalues) % X axis values not supplied?
    xaxisvalues = repmat([1:size(Y,1)]', [1,size(Y,2),size(Y,3)]);
  else % check the x-axis values shape is correct
    if (isrow(xaxisvalues) && iscolumn(Y)) || (iscolumn(Y)) && isrow(xaxisvalues)
      xaxisvalues=xaxisvalues';
    end;
    xaxisvalues=bsxfun(@(a,b)a,xaxisvalues, Y); % shape must match Y
  end

  switch TYPE
    case 'line',  
      % plot line with errorbars
      h=errorbar(xaxisvalues, Y,yerrorm,yerror, plotargs{:});
      if PLOT_INDIVIDUALS  % individuals as dotted lines
        hold on;
        plot(xaxisvalues,X',':',plotargs{:}); 
      end
    case 'bar', 
      % plot bar with errorbars
      h=barwitherr(cat(3, yerror, -yerrorm), xaxisvalues, Y, plotargs{:});
      if PLOT_INDIVIDUALS  % individuals as circles
        hold on;
        plot(xaxisvalues, X,'o',plotargs{:});  
      end
  end
  if WIDTH, errorbarT(h,WIDTH); end % adjust witdth of bars
else % AREA plot
  if DOTTED_AREA % use dotted lines above and below, instead of area?
    h1=plot(sq(fmean(X,1))+addon, plotargs{:}); % mean line
    hold on
    h2=plot(sq(fmean(X,1))+addon+yerror, plotargs{:},'linestyle',':');
    h3=plot(sq(fmean(X,1))+addon-yerrorm, plotargs{:},'linestyle',':');
    h=[h1 h2 h3];
  else % shade in area between errors
    if ~any(strcmpi(plotargs,'color')) % color not explicitly given?
      col=get(gca,'ColorOrder'); % use color order
    else % consume 'color' parameter
      ci=find(strcmp(plotargs,'color')); 
      col = plotargs{ci+1}; plotargs([ci ci+1])=[]; 
    end
    for i=1:size(X,3) % for each line
      coli = col(1+mod(i-1,size(col,1)),:); % color of line
      if ~isempty(xaxisvalues)
        % transpose to make it a column if needed
        if isvector(xaxisvalues) && size(xaxisvalues,1)==1, xaxisvalues=xaxisvalues'; end % make column
        % need to subselect columns of xaxisvalues?
        if size(xaxisvalues,2)>1, xav = xaxisvalues(:,i); else xav=xaxisvalues; end
      else % no x axis values specified; use 1 to N
        xav = [1:size(X,2)]'; % average x values
      end
      if AREA==1 % error region shading
        xm = fmean(Xm(:,:,i));   % calculate mean
        % fill in area as a polygon
        h(i,2)=fill( [xav' fliplr(xav')], [xm+yerror(:,i)' fliplr(xm-yerrorm(:,i)')], coli, 'linestyle','none','FaceAlpha',alpha);
        hold on;
        % plot mean line on top of area
        h(i,1)=plot( xav, xm, 'color', coli,'linewidth',1.5,plotargs{:} );
      else % AREA > 2 ==> QUANTILES
        % number of quantiles to calculate
        nquant = AREA; % AREA=3 gives 0.33,.67, AREA=4 gives .25,.75 etc.
        quantiles = [1:nquant-1]/nquant; % which quatiles to plot
        q = quantile(X(:,:,i), quantiles); % should give a [ nquant x size(X,2) ] array
        if SMOOTH % make the curves artificially smoother?
          q=smoothn(q',SMOOTH)'; % use a window convolution
        end
        for j=1:floor((nquant-1)/2); % for each pair of quantile lines, 
          % fill an area between them, using an alpha depending on the
          % number of quantiles to make the transparency look graded
          h(j)=fill( [xav', fliplr(xav')] ,  [ q(j,:) fliplr(q(length(quantiles)+1-j,:)) ],  coli, 'linestyle','none','FaceAlpha',2*alpha/nquant );
          hold on;
        end
        % plot the median line
        h(end+1)=plot( xav, smoothn(sq(nanmedian(X(:,:,i))),SMOOTH) , 'color', coli , 'linewidth',1.5, plotargs{:})
        hold off;
      end
      hold on
    end % next line
  end % dotted vs fill 
end % errorbars/area
if(~ho) hold off; end % restore hold-on status


 