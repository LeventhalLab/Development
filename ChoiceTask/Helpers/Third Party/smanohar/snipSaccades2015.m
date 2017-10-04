function [r, info]=snipSaccades(s, start, finish, varargin)
% [A, info]=snipSaccades(saccadeStructure, start, finish [,'param', value...])
% 
% snip out saccade paths for each trial.
%
% With no extra parameters, simply returns the nan-padded array of saccades
% as complex numbers. 
% Also handles pupil size, rotating/reflecting, baseline/centre subtraction.
%
% input: 
%   saccadeStructure s: is a struct-array created by the program readEDFASC
%             and contains the field pos(t,1:4) = [times, x,y,pupil]
%             and fields with the names in 'start' and 'finish', containing 
%             times of the start and finish events.
%   start:    A string specifying the field name in the structure to use as
%             start times for cutting.  If 'start' is a number rather than 
%             a string, begin at this fixed datapoint index. If it is a
%             vector (the same size as s), begin at this index into the 
%             respective trial
%   finish:   as for start, except absolute numbers and vectors indicate 
%             the length to include after the start point. i.e., 
%             If 'finish' is a number rather than a string, take exactly this 
%             number of data points after 'start'.
%
% parameters:
%  'saccadeonly', N : only retain the eye position data for the actual
%             time of Nth saccade.
%  'rotate', X : specify a vector the same size as s, with the angle X to rotate
%             each saccade, in radians. Default 0.
%  'flip', B : a vector the same size as s, of boolean values indicating
%             whether or not to flip each trial. If no flip angle is
%             provided, the reflection is left-to-right. Default 0.
%  'flipangle' X : a vector the same size as s, of angles in radians (or an
%             [n x 2] matrix of vectors) representing the axis along which
%             to reflect each saccade.
%  'centre' [x,y] : the screen centre in pixels, to be subtracted from all x and
%             y coordinates of pos.
%  'stretch', L : interpolate the snipped saccades so that each trace is 
%             interpolated to have length L, and so they all line up to
%             the given length L. i.e., there is no padding of nans at the
%             end of the saccade - it is stretched in time to fit.
%  'baselinesub', X: subtract baseline values. the parameter can be: 
%             X = single number N: then the mean baseline is taken over N 
%                     samples after event1
%             X = string 'event3': the baseline is taken at the point event3
%  'pupil' :  analyse pupil data instead of eye position. In this case, the
%             values are all reals.
%  'meancriteria', X : take the mean values of the eye data, across trials.
%             The parameter X specifies which group/bin each trial falls
%             into. The return value has one row for each unique value of
%             the criteria, in sorted order. info contains the criteria in 
%             order.
%  'smoothing', N : average using a boxcar function over N samples 
%  'plot' :   plot the values on a graph. Any unrecognised input parameters 
%             are sent to the plot command.
%  'clean', T :  a value in milliseconds for cleanup. It is the minimum length
%             of valid samples needed to retain a segment of data. Default
%             50ms.
%  'excludenan': exclude trials where any datapoint is nan, from the mean
%             and from the plot.
%  'minsize' : minimum saccade size to register
%  'saccadeonly' N : get rid of all data except the actual position data
%             for the Nth saccade(s)
%  'verbose' : display extra information about what is being calculated
%  'browse' : for each trial, pause and show a diagram of the trace
%             of the saccade
%  'traces' : if 0, then don't return an array of traces. [] is returned as
%             the first return value. Speeds up calculation of saccades,
%             but is not compatible with plot / browse / meancriteria
%             option.
%  'interpolate', N: if a sequence of fewer than N nans occurs, after
%             cleaning, then use linear interpolation to fill in the gap.
% returns: 
%   a matrix with one row for each trial, containing the snipped eye data
%

%%%% parse parameters
[rotate, flip, centre, flipangle, stretch, baselinesub,...
 pupil, meancriteria, CLEAN_MS, saccadeonly, minsize,...
 verbose, browse, excludenan, doplot, RETURN_TRACES, ...
 smoothing, interpolate]...
 = parsepvpairs( ...
    {'rotate', 'flip', 'centre','flipangle', 'stretch', 'baselinesub',...
     'pupil', 'meancriteria', 'clean', 'saccadeonly', 'minsize', ...
     'verbose','browse','excludenan','plot', 'traces', ...
     'smoothing', 'interpolate'}, ...
    { zeros(size(s)), zeros(size(s))>0, [0 0], 1j, 0, 0, ...
      0, [], 50, 0, 0, ...
      0, 0, 0, 0, 1, ...
      0, 0 }, varargin{:} ...
    );

if size(flipangle,2)==2 flipangle=angle(flipangle*[1,1j]); end; % convert to column of complexs
if length(flipangle)==1 flipangle=flipangle*ones(size(s)); end; % duplicate it if single value given
if(stretch==1) stretch=100;end; % default as 100
if(length(meancriteria)==1) meancriteria=meancriteria*ones(size(s)); end;
if ~RETURN_TRACES & (browse | doplot | meancriteria )
    error('no traces is not compatible with plotting / mean options');
end

if(stretch>0) warning('off', 'MATLAB:interp1:NaNinY'); end;

MS_PER_SAMPLE = mean(diff(s(1).pos(:,1))); % sampling rate

%% process saccades
%%%% results for each saccade:
r=[];
info.sRT    = []; % onset time of saccade
info.sEndpt = []; % physical location of endpoint
info.sBlink = []; % is there a blink in this saccade? 1/0
info.sAmpl  = []; % amplitude = abs(sVec)
info.sBendT = []; % time of maximal deviation from saccade line
info.sBendA = []; % angle of point with maximal deviation from saccade line (but now distance of this point from the saccade line)
info.sVec   = []; % endpoint relative to startpoint
info.sCurvA = []; % unsigned maximal curvature (radial acceleration)
info.sCurvS = []; % signed maximal curvature 
info.sDepA  = []; % angle of departure (where it leaves the 30-pixel circle)
info.sSpd   = []; % maximum speed of eye during saccade

for(i=1:length(s))
  if ~isempty(s(i).pos)
    if(isnumeric(start))
        if(length(start)~=1)  t1=start(i);       % vector of start positions
        else                  t1=start;          % fixed start position
        end
    else                      t1=s(i).(start);   % event name
    end
    if(isnumeric(finish))
        if(length(finish)~=1) t2=finish(i)+start;% vector of finish positions
        else                  t2=finish+t1;      % fixed finish position relative to start
        end
    else                      t2=s(i).(finish);  % event name
    end
    
    filter = s(i).pos(:,1) > t1 & s(i).pos(:,1) < t2;
    pt=s(i).pos(filter,1);                     % times of points in region of interest
    if(pupil==0)
        p =s(i).pos(filter,[2:3]) * [1;1j];    % get whole trace for this saccade
        p=p-centre*[1;1j];                     % centre trace on zero
        p=p*exp(rotate(i)*1j);                 % rotate trace
        if(flip(i))                            % reflect along axis angled at 'reflectangle' radians
            p=abs(p) .* exp( 1j * (2*flipangle(i)-angle(p)) );
        end
    else
        p=s(i).pos(filter,4);
    end


    
    % calculate speed
    if ~exist('smooth','file')
      warning('cannot find smooth function');
      % create 'smooth' function in the current workspace... but don't
      % allow it to think smooth is a variable!
      eval('smooth=@(x,y,z)conv(x,ones(y,1)/y,''same'');'); 
    end
    v=diff(p);
    spd=abs(v);
    smoothMethod = 'moving'; % use 'boxcar' for spktools version
    if(length(v)>8)
      vs=smooth(v,8,smoothMethod); 
    else vs=[];
    end
    if ~pupil % saccades!
      if ~isempty(s(i).saccade)
        as=diff(vs);                               % grab points where vel > 3 px/ms
        % flag to indicate if saccade is during the period of interest
        %saccin=s(i).saccade(:,2)>t1 & s(i).saccade(:,1)<t2; % allow saccades that transgress start and endpoints?
        saccin  =s(i).saccade(:,1)>t1 & s(i).saccade(:,2)<t2; % don't allow transgressing start and endpoints
        scStartT=s(i).saccade(saccin,1); % times of start
        scEndT  =s(i).saccade(saccin,2); % and end of saccades
        scStart=nan; scEnd=nan;
        
        scBegpt=nan; scBlink=nan; scBendT=nan; scBendA=nan; scCurvA=nan;
        scCurvS=nan; scAmpl=nan; scCurvT=nan; scEndPt=nan; scBendP=nan;
        scBendR=nan; scDepA=nan; scSpd=nan;  
        
        if(length(scStartT)>0 && length(scEndT)>0) % saccades aren't all empty:
          for(j=1:length(scStartT))
            scStart(j,:) = find(pt>=scStartT(j),1); % index of start
          end
          for(j=1:length(scEndT))
            scEnd(j,:) = find(pt>=scEndT(j),1); % and end of saccades
          end
          
          %scVec  =( s(i).saccade(saccin,[6,7])-s(i).saccade(saccin,[4,5]) ) * [1;1j];
          % use transformed coords
          scVec  = p(scEnd)-p(scStart);
          if(size(scVec,2)==1) scVec=scVec'; end; % ensure it's a row
          % remove small saccades
          remove = abs(scVec) < minsize;
          scStartT(remove)=[]; scEndT(remove)=[]; scVec(remove)=[];
          scStart(remove)=[]; scEnd(remove)=[];
          if(length(scVec)~=length(scStartT)) disp(scStartT, scVec);keyboard
          end
          
          for( j = 1:length(scStart) ) % for each saccade
            scPath    = p(scStart(j):scEnd(j)) - p(scStart(j)); % the path of the sacc, relative to point of 
            scBegpt(j)= p(scStart(j));
            scEndpt   = scPath(end);  % vector of this saccade
            scEndPt(j)= p(scEnd(j));  % endpoint of each saccade
            scBlink(j)= any(isnan(scPath)); % will catch nans in x or y
            scAmpl(j) = abs(scEndpt);
            % calculate deviation from a straight line, at each p
            scDev     = scPath - scEndpt.*(real(scPath).*real(scEndpt) ...
              + imag(scPath).*imag(scEndpt))./(abs(scEndpt).^2);
            %scDev = scDev .*
            maxDevPt  = find(abs(scDev)==max(abs(scDev)),1); % first point of max deviation
            scDevMax  = scDev(maxDevPt); % maximum vector of deviation (it's perpendicular to the trajectory).
            if ~isempty(maxDevPt) % && ~any(isnan(p(maxDevPt-1:maxDevPt+1))) % make sure surrounded by decent datapoints! 
              scBendT(j)= maxDevPt;
              scBendA(j)= mod(pi+angle(scPath(scBendT(j))) - angle(scEndpt),2*pi)-pi;
              scBendR(j)= abs(scDev(maxDevPt)) ... actual deviation distance, 
                * (2*(imag(scDevMax * scPath(maxDevPt)'.' )>0)-1); % make it the same sign as imag( dev . traj* ), which is dev dot perp(traj)
              scBendP(j)= p(scBendT(j));
            else
              scBendT(j)=nan; scBendA(j)=nan; scBendP(j)=nan;
            end
            if length(scPath)>5
              scVel     = diff(smooth(scPath,3,smoothMethod)) / MS_PER_SAMPLE;
              % calculate this on *unit* velocity if you want d/ds (curvature) rather than d/dt
              scAcc     = [0;diff(smooth(scVel,3,smoothMethod))] / MS_PER_SAMPLE;
              % projection of acceleration onto unit vector perpendicular to velocity
              % ddp - (ddp . dp) dp / |dp|^2
              %     = Radial component of acceleration
              scCurv    = scAcc - (real(scAcc).*real(scVel) + imag(scAcc).*imag(scVel)) .* scVel./(abs(scVel).^2);
              scCurvT(j)= find(scCurv==max(scCurv),1);
              % calculate the sign term as the cross product of the endpoint and the nontangential acceleration
              scCurvs   = abs(scCurv) .* (real(scCurv).*imag(scEndpt) - real(scEndpt).*imag(scCurv));
              scCurvA(j)= scCurvs(scCurvT(j));
              scCurvS(j)= scCurv(scCurvT(j));
              % find "point of departure", when saccade actually gets moving! 
              departT   = find( abs(smooth(scPath,3,smoothMethod)) > 50,1 ); % arbitrary 30 pixel criterion
              % calculate max speed
              scSpd(j)  = max(abs(scVel)); if scSpd(j)>100, scSpd(j)=nan; end
              
              if ~isempty(departT) scDepA(j) = angle( scPath(departT) ); % depature angle
              else scDepA(j)=nan;  % only valid for larger saccades.
              end
            end
          end
        end
      end % if empty(saccades)

        % saccades only? cut out all of data except Nth saccade
        if(saccadeonly && any(~isnan(scStart)))
            if length(scStart)>=saccadeonly
                p=p(scStart(saccadeonly):scEnd(saccadeonly));
                v=v(scStart(saccadeonly):scEnd(saccadeonly)-1);
                spd=spd(scStart(saccadeonly):scEnd(saccadeonly)-1);
            else
                p=[]; v=[], spd=[];
            end
        end
        if ~exist('scStartT','var') || isempty(scStartT) 
          scStartT=nan; scVec=nan; scEndPt=nan; scBlink=true;
          scAmpl=nan; scBendT=nan; scBendR=nan; scVec=nan; 
          scCurvA=nan; scCurvS=nan; scDepA=nan; scSpd=nan;
        end
        info.sRT    = nancat(1, info.sRT, scStartT'-t1);
        info.sEndpt = nancat(1, info.sEndpt, scEndPt);
        info.sBlink = nancat(1, info.sBlink, scBlink);
        info.sAmpl  = nancat(1, info.sAmpl, scAmpl);
        info.sBendT = nancat(1, info.sBendT, scBendT);
        info.sBendA = nancat(1, info.sBendA, scBendR); % was scBendA for angle. now use scBendR for distance
        info.sVec   = nancat(1, info.sVec, scVec);
        info.sCurvA = nancat(1, info.sCurvA, scCurvA);
        info.sCurvS = nancat(1, info.sCurvS, scCurvS);
        info.sDepA  = nancat(1, info.sDepA,  scDepA);
        info.sSpd   = nancat(1, info.sSpd,   scSpd);
    end
    
    if ~isempty(v) && ~saccadeonly % 2014 added no cleaning if saccadeonly is requested
      % clean up bad data
      % was 1.5
      BLINKSPD=1.5; % speed above which data is removed around nans
      nanC=nan+nan*1j;
      if(pupil) ABSMAX=20000;else ABSMAX=2000;end;
      bad=find( (spd>40 & [abs(diff(v)); 0]>30) ...
        | (abs(p(1:end-1))>ABSMAX) | (abs(p(2:end))>ABSMAX) );
      p(bad)=nanC;
      p(isnan(p))=nanC; % note that if real(p) is nan, it doesn't guarantee imag(p)==nan.
      lastnan=1; lastwasfast=0;
      removedsegments(i)=0;
      spdsm= spd;%smooth(spd,3,'boxcar');
      for(k=1:length(p)) % remove short segments of data surrounded by nans
        if(isnan(p(k)))
          if( ((k-lastnan)<CLEAN_MS) && ((k-lastnan)>1) )
            p(lastnan:k)=nanC;
            removedsegments(i)=removedsegments(i)+1;
          end
          lastnan=k; lastwasfast=0;
          % remove fast segments before nans
          m=1;while( k-m>0 && ~isnan(p(k-m)) && ...
              ( spdsm(k-m)>BLINKSPD || (k-m-1>0 && spdsm(k-m-1)>BLINKSPD) || ...
              (k-m-2>0 && spdsm(k-m-2)>BLINKSPD) ) ...
              );
            p(k-m)=nanC;
            m=m+1;
          end
        else % remove fast movements after nans
          if ( (k-lastnan==1) || lastwasfast) && k<length(p) && ...
              ( spdsm(k)>BLINKSPD || (k+1<length(p) && spdsm(k+1)>BLINKSPD) || ...
              (k+2<length(p) && spdsm(k+2)>BLINKSPD) );
            p(k)=nanC;
            lastwasfast=1;
          else
            lastwasfast=0;
          end
        end
      end;
      if interpolate
        startnans=1; lastwasnan=0; % keep track of sequences of nans
        for k=1:length(p)
          if isnan(p(k)) && ~lastwasnan % begin sequence of nans
            startnans=k; % store the current index
          elseif lastwasnan && ~isnan(p(k)) % end sequence of nans
            if   (k-startnans <= interpolate) ...
                && (startnans>1) ... % no extrapolation!
                && (k<length(p)-2) ... % no extrapolation if only 2 points at end
                && (~isnan(p(k+1))) ... % ensure not extrapolating to single point 
                && (~isnan(p(k+2))) ...
                && abs(p(startnans-1)-p(k))<1000 % and distance < 1000
              p(startnans:(k-1)) = interp1([startnans-1,k], [p(startnans-1), p(k)], [startnans:(k-1)]);
            end
          end
          lastwasnan = isnan(p(k));
        end
      end
    else % not doing cleaning - v=[] or saccadeonly=true
      removedsegments=[];
    end
    hasnan(i)=any(isnan(p));
    
    % remove saccades that have only a nan segment after them.
    if ~pupil && ~isempty(s(i).saccade) &&  ~isempty(scStart)
      for j=1:length(scStart)
        if isnan(scEnd(j)) continue; end
        % remove saccades where pretty much all the points are nan after
        nextgood = find(~isnan(p(scEnd(j):end)),1); % next good point after saccade
        later    = min(length(p),nextgood+500);
        if mean(isnan(p(scEnd(j):nextgood)))>0.95 || scEnd(j)==length(p),
          info.sVec(end,j)=nan; info.sCurvA(end,j)=nan; info.sCurvS(end,j)=nan; info.sEndpt(end,j)=nan;
          info.sBendT(end,j)=nan; info.sBendA(end,j)=nan;  info.sAmpl(end,j)=nan; info.sDepA(end,j)=nan;
        end
      end
    end
    
  else % pos was empty.
    p=nan;
  end
    
    if(browse && length(scStart)>0)
        subplot(3,1,1);plot(abs(vs));
        ylim([0,100]);title(sprintf('trial %d',i));
        subplot(3,1,2);plot(p,'.'); xlim([-300 300]);ylim([-300,300]);
        hold on;            
        plot(real([p(scStart) p(scEnd)])', imag([p(scStart) p(scEnd)])','b:');
        vecs=[p(scCurvT+scStart.'), p(scCurvT+scStart.')+10*scCurvS.']; 
        plot(real(vecs)', imag(vecs)' , '-r' ); hold off;
        vecs=[p(scBendT+scStart.'), p(scBendT+scStart.')+40*scBendA.']; hold on;
        plot(real(vecs)', imag(vecs)' , '-g' ); hold off;
        subplot(3,1,3);plot([real(p), imag(p)]);legend({'X','Y'});
        ylim([-300,300]);
        hold on
        for(j=1:length(scStart)) 
            plot(scStart(j)*[1 1],get(gca,'ylim'),'b-');
            plot(scEnd(j)*[1 1],get(gca,'ylim'),'y-');
            plot( scStart(j)+[0 real(scVec(j))], [0 imag(scVec(j))], 'r');
            plot( [1 1]*(scStart(j)+scCurvT(j)),  [0 scCurvA(j)], 'g');
        end 
        hold off;
        keyboard
        %pause;
    end
    
    if RETURN_TRACES % Do we want to return the individual traces for trials?
      if isempty(p) p=nan;end;
        % pack into results array
        if(stretch==0)                       % no stretch: add nans at the end
            r=nancat(1,r,p.'); 
        else                                 % stretch: interpolate data
          if(length(p)==1)
            r(i,:)=p;
          else
            %r(i,:)=interp1( s(i).pos(filter,1)-t1, p, linspace(1,length(p),stretch)' );
            r(i,:)=interp1( 1:length(p), p, linspace(1,length(p),stretch)' ); % edited 2014 july
          end
        end

        if isnumeric(baselinesub) && baselinesub>0  % find baseline
            if length(p)>=baselinesub
                baseline=nanmean(p(1:baselinesub));
            else
                baseline=nanmean(p);
            end
        elseif ischar(baselinesub)
            t=s(i).pos(:,1)>=s(i).(baselinesub);
            if ~isempty(t)
                baseline=p(t(i));
            else % something has gone wrong - couldn't find specified time.
                baseline=p(1);
                warning(['snip: cant find time ' baselinesub]);
            end
        else baseline=0;
        end
        r(i,:)=r(i,:)-baseline;
        if smoothing & length(r)>smoothing
          r(i,:)=smooth(r(i,:), smoothing, 'boxcar');
        end
    end
end
if verbose 
    fprintf('cleanup: %d short data segments removed from %d trials\n', sum(removedsegments), sum(removedsegments>0));
end

if RETURN_TRACES & ~isempty(meancriteria)                % use criteria to take means?
    ucr = unique(meancriteria);
    for(j=1:length(ucr))                     % select trials with a certain criterion
        f=meancriteria==ucr(j);              % mean of eye data is taken for 
        if(excludenan) f=f & ~any(isnan(r),2)'; end; % exclude trials with nans?
        cm(j,:)=nanmean(r(f,:));             % each time point across selected trials
        cs(j,:)=nanstd(r(f,:))/sqrt(sum(f)); % standard error of mean
        leg{j}=num2str(ucr(j));
        if verbose fprintf('criterion %s has %d valid trials\n', leg{j}, sum(f)); end;
        if smoothing
          cm(j,:) = smooth(cm(j,:), smoothing, 'boxcar');
          cs(j,:) = smooth(cs(j,:), smoothing, 'boxcar');
        end
    end
    r=cm;
      
    info.sem=cs;
    info.criteria=ucr;
    if(doplot)
        held=ishold();
        plot(cm.','-');
        hold on
        plot((cm-cs).',':');
        plot((cm+cs).',':');
        legend(leg);
        if(~held) hold off;end;
    end
else                                    % not taking means?
    if(doplot)
        isheld=ishold();                   % basic plot of all saccades
        if(excludenan)
            f=~hasnan;            % which trials to exclude
            if verbose fprintf('plot: %d trials removed containing nan\n', sum(hasnan)); end;
        else  f=ones(size(r,1),1)==1;
        end
        if pupil     plot(real(r(f,:))');
        else         plot(r(f,:).');
        end
    end
end

