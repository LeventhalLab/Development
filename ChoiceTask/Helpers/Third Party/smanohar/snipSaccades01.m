function [r, info]=snipSaccades(s, start, finish, varargin)
% r=snipSaccades(saccadeStructure, start, finish [,'param', value...])
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
%             the length to cut out after the start point. i.e., 
%             If 'finish' is a number rather than a string, take exactly this 
%             number of data points after 'start'.
%
% parameters:
%  'saccadeonly', N : only retain the eye position data for the actual
%             time of Nth saccade.
%  'rotate', X : specify a vector the same size as s, with the angle X to rotate
%             each saccade, in radians. Default 0.
%  'reflect', B : a vector the same size as s, of boolean values indicating
%             whether or not to flip each trial. If no flip angle is
%             provided, the reflection is left-to-right. Default 0.
%  'reflectangle' X : a vector the same size as s, of angles in radians (or an
%             [n x 2] matrix of vectors) representing the axis along which
%             to reflect each saccade.
%  'centre' [x,y] : the screen centre in pixels, to be subtracted from all x and
%             y coordinates of pos.
%  'stretch', L : interpolate the snipped saccades so that they all line up to
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
%  'plot' :   plot the values on a graph. Any unrecognised input parameters 
%             are sent to the plot command.
%  'clean', T :  a value in milliseconds for cleanup. It is the minimum length
%             of valid samples needed to retain a segment of data. Default
%             50ms.
%  'excludenan': exclude trials where any datapoint is nan, from the mean
%             and from the plot.
%  'verbose' : display extra information about what is being calculated
% 
% returns: 
%   a matrix with one row for each trial, containing the snipped eye data
%

%%%% parse parameters
remove=[];
rotate=zeros(size(s));
flip=(zeros(size(s))>0);
centre=[0 0];
flipangle=1j;
stretch=0;
baselinesub=0;
pupil=0;
meancriteria=[];
doplot=0;
excludenan=0;
CLEAN_MS=50;
verbose=0;
browse=1;
saccadeonly=0;
for(i=1:length(varargin))
    used=0;
    if strcmpi(varargin{i},'rotate')
        rotate=varargin{i+1};
        used=2;
    end
    if strcmpi(varargin{i},'flip')
        flip=varargin{i+1};
        used=2;
    end
    if strcmpi(varargin{i},'centre')
        centre=varargin{i+1};
        used=2;
    end    
    if strcmpi(varargin{i},'flipangle')
        flipangle=varargin{i+1};
        used=2;
    end    
    if strcmpi(varargin{i},'stretch')
        stretch=varargin{i+1};
        used=2;
    end    
    if strcmpi(varargin{i},'baselinesub')
        baselinesub=varargin{i+1};
        used=2;
    end
    if strcmpi(varargin{i},'pupil')
        pupil=varargin{i+1};
        used=2;
    end
    if strcmpi(varargin{i},'meancriteria')
        meancriteria=varargin{i+1};
        used=2;
    end
    if strcmpi(varargin{i},'clean')
        CLEAN_MS=varargin{i+1};
        used=2;
    end
    if strcmpi(varargin{i},'plot')
        doplot=1; used=1;
    end
    if strcmpi(varargin{i},'excludenan')
        excludenan=1; used=1;
    end
    if strcmpi(varargin{i},'verbose')
        verbose=1;used=1;
    end
    if strcmpi(varargin{i},'saccadeonly')
        saccadeonly = varargin{i+1}
        used=2;
    end
    if(used>0) remove=[remove i]; 
        if(used>1) remove=[remove i+1]; i=i+1;
        end
    end
end
varargin(remove)=[];
if size(flipangle,2)==2 flipangle=angle(flipangle*[i,1j]); end;         % convert to column of complexs
if length(flipangle)==1 flipangle=flipangle*ones(size(s)); end; % duplicate it if single value given
if(stretch==1) stretch=100;end; % default as 100
if(length(meancriteria)==1) meancriteria=meancriteria*ones(size(s)); end;
%%%% process saccades
r=[];
for(i=1:length(s))
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
    if(pupil==0)
        p=s(i).pos(filter,[2:3]) * [1;1j];     % get whole trace for this saccade
        p=p-centre*[1;1j];                     % centre trace on zero
        p=p*exp(rotate(i)*1j);                 % rotate trace
        if(flip(i))                            % reflect along axis angled at 'reflectangle' radians
            p=abs(p) .* exp( 1j * (2*flipangle(i)-angle(p)) );
        end
    else
        p=s(i).pos(filter,4);
    end
    
    % calculate speed
    v=diff(p);
    spd=abs(v);
    vs=smooth(v,8);
    if ~pupil % saccades!
        as=diff(vs);                               % grab points where vel > 3 px/ms
        issaccnow=(  abs(vs)>1.8 ...
            ... % | [0;abs(as)]>0.5) ...% or acc > 0.5 px/ms/ms
            & ~isnan(p(1:end-1))  );
        startsaccpoints=find(diff(issaccnow)==1);
        endsaccpoints  =find(diff(issaccnow)==-1);
        tooclosestart  =diff(startsaccpoints)<30;  % find saccade starts closer than 30ms
        if(length(startsaccpoints>1))              % and remove them
            startsaccpoints=startsaccpoints(~[false;tooclosestart]) ;
        end
        toocloseend    =diff(endsaccpoints)<30;    % find saccade ends closer than 30ms
        if(length(endsaccpoints>1))                % and remove them
            endsaccpoints=endsaccpoints(~[toocloseend;false]);
        end
        

        % saccades only? cut out all of data except Nth saccade
        if(saccadeonly)
            if length(startsaccpoints)>=saccadeonly
                p=p(startsaccpoints(saccadeonly):endsaccpoints(saccadeonly));
            else
                p=[];
            end
        end
        
        if(browse)
            subplot(3,1,1);plot(abs(vs));
            subplot(3,1,2);plot(abs(as));
            subplot(3,1,3);plot([real(p), imag(p)]);legend({'X','Y'});
            hold on
            for(j=1:length(startsaccpoints)) plot(startsaccpoints(j)*[1 1],get(gca,'ylim'),'b-');end;
            for(j=1:length(endsaccpoints)) plot(endsaccpoints(j)*[1 1],get(gca,'ylim'),'y-');end;
            hold off;
            pause
        end
    end
    
    
    % clean up bad data
    if(pupil) ABSMAX=20000;else ABSMAX=1000;end;
    bad=find( (spd>40 & [abs(diff(v)); 0]>30) ...
            | (abs(p(1:end-1))>ABSMAX) | (abs(p(2:end))>ABSMAX) );
    p(bad)=nan;
    lastnan=1;
    removedsegments(i)=0;
    for(k=1:length(p))
        if(isnan(p(k))) 
            if( ((k-lastnan)<CLEAN_MS) && ((k-lastnan)>1) )
                p(lastnan:k)=nan; 
                removedsegments(i)=removedsegments(i)+1;
            end
            lastnan=k;
        end
    end;
    hasnan(i)=any(isnan(p));
    
    % pack into results array
    if(stretch==0)                       % no stretch: add nans at the end
        r=nancat(1,r,p.'); 
    else                                 % stretch: interpolate data
        r(i,:)=interp1( s(i).pos(filter,1), p, linspace(1,length(p),stretch) );
    end
    
    if isnumeric(baselinesub) && baselinesub>0  % find baseline
        baseline=mean(p(1:baselinesub));
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
end
if verbose 
    fprintf('cleanup: %d short data segments removed from %d trials\n', sum(removedsegments), sum(removedsegments>0));
end
if ~isempty(meancriteria)                % use criteria to take means?
    ucr = unique(meancriteria);
    for(j=1:length(ucr))                     % select trials with a certain criterion
        f=meancriteria==ucr(j);              % mean of eye data is taken for 
        if(excludenan) f=f & ~any(isnan(r),2)'; end; % exclude trials with nans?
        cm(j,:)=nanmean(r(f,:));             % each time point across selected trials
        cs(j,:)=nanstd(r(f,:))/sqrt(sum(f)); % standard error of mean
        leg{j}=num2str(ucr(j));
        if verbose fprintf('criterion %s has %d valid trials\n', leg{j}, sum(f)); end;
    end
    r=cm;
    info.sem=cs;
    info.criteria=ucr;
    if(doplot)
        held=ishold();
        plot(cm.','-', varargin{:});
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
        plot(r(f,:).', varargin{:});
    end
end
