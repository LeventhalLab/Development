
function tr=runSingleTrialAndProcess(scr,el,ex,tr,doTrial,b,t)
% this prepares a trial structure for the experiment,
% calls "doTrial" of your experiment, 
% checks if it needs repeating, and checks for things like calibration
% requests or if the eyelink computer 'abort' or 'end' was pressed.
    tr.block=b; tr.trialIndex=t;         % initialise trial position
    tr.allTrialIndex = t + (b-1)*ex.blockLen; % index relative to whole experiment
    tr.key=[];  tr.R=ex.R_INCOMPLETE;    % initialise trial exit status
    while (tr.R==ex.R_INCOMPLETE)   % repeat trial immediately?
        kcode = 1; while any(kcode) [z z kcode]=KbCheck; end;
        FlushEvents;             % ensure no keys pressed at start of trial
        if ex.useEyelink         %%%% begin recording
            eyelink('startrecording'); 
            el.eye=eyelink('eyeavailable')+1;
            if ~el.eye 
                error('No eye available');
                el.eye=1;
            end;
            eyelink('message', 'B %d T %d', b,t);
        end;
        if ex.useSqueezy
          retval=calllib(ex.mplib, 'startMPAcqDaemon');
          if ~strcmp(retval,'MPSUCCESS')
            error('Could not start squeezy acquisition daemon');
          end
          fprintf('starting acqisition\n');
          retval = calllib(ex.mplib, 'startAcquisition');
          if ~strcmp(retval,'MPSUCCESS')
            fprintf(1,'Failed to Start Acquisition.\n');
            calllib(ex.mplib, 'disconnectMPDev');
            error('Failed to start squeezy acquisition');
          end
          tr=LogEvent(ex,el,tr,'startSqueezyAcquisition');
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Call External doTrial routine
        tr = doTrial(scr, el, ex, tr);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Returns the results of that trial
        if(~isfield(tr,'key')) tr.key=[]; end            % well, it's just possible that you return a completely
        if(~isfield(tr,'R')) tr.R=ex.R_UNSPECIFIED; end; % different structure to the one we provided!
        [z z kcode]=KbCheck;
        if kcode(27) tr.key=27;end; % override repeat trial if escape pressed.
        if kcode(112) allowinput(scr,ex); end; % f1: allow modification of expt params
        if(length(tr.key)>1) tr.key=tr.key(1);end; 
        if (isempty(tr.key) || (tr.key==0));  tr.key=find(kcode); % expt provided no keypress data --> check our own
        else
          if tr.key=='R' tr.R=ex.R_NEEDS_REPEATING; end;
          if (tr.key=='D' && ex.useEyelink) dodriftcorrection(el ); tr.R=ex.R_NEEDS_REPEATING;end;
          if (tr.key=='C' && ex.useEyelink) EyelinkDotrackersetup(el); tr.R=ex.R_NEEDS_REPEATING; end;
          if tr.key==27  tr.R=ex.R_ESCAPE;  end;
        end
        if ex.useEyelink            %%%% stop recording
            if(tr.R==ex.R_NEEDS_REPEATING) eyelink('message', 'VOID_TRIAL'); end;
            eyelink('stoprecording'); 
            eyeStatus=eyelink('checkrecording');
            switch(eyeStatus)       % check eyelink status - was the trial aborted?
                case el.ABORT_EXPT,   tr.R=ex.R_ESCAPE; eyelink('stoprecording'); break;
                case el.REPEAT_TRIAL, tr.R=ex.R_NEEDS_REPEATING; tr.key='R';eyelink('stoprecording');
                case el.SKIP_TRIAL,   tr.R=ex.R_NEEDS_REPEATING; tr.key='R';eyelink('stoprecording');
            end;
        end;
        if ex.useSqueezy
          calllib(ex.mplib, 'stopAcquisition')
        end
        
    end; % while trial needs repeating

