function [tr] = createTrials(ex)
% Create a structure of trials from experiment parameters.
% (c) Sanjay Manohar 2008
%
% ex.blocks         : number of blocks in the experiment
% ex.blockLen       : number of trials in each block
%
% ex.blockVariables 
% ex.trialVariables
%     structures whose fields are the variables to vary in each trial or
%     block respectively. The value of each field should be a list or
%     vector of the possible values for that variable, e.g.
%       ex.trialVariables.contrast = [0.1, 0.4, 0.6, 0.9]
% ex.unequalTrials
%     unless this is set, do not allow unequal numbers of each trial type.
%
%
% returns:  
%   a structure array whosee elements
%   tr(block, trial).variablename = value
%
%   with each block and trial variable set to one of the specified values
%   in each trial, and
%   with trials and blocks in randomised counterbalanced order (if possible)
%

if(isfield(ex, 'trials')) tr=ex.trials; return; end;
if ~isfield(ex,'blockVariables') 
  ex.blockVariables.blockType=1;
end

tr=struct;
bvarnames = fieldnames(ex.blockVariables);
tvarnames = fieldnames(ex.trialVariables);

for i=1:length(bvarnames);  % possible values of each block variable
    bvvlist{i}=getfield(ex.blockVariables, bvarnames{i});
    bvnum(i)=length(bvvlist{i});
end;
            
for i=1:length(tvarnames); % possible values of each trial variable
    tvvlist{i}=getfield(ex.trialVariables, tvarnames{i});
    tvnum(i)=length(tvvlist{i});
end;

repetitionsPerBlock = ex.blockLen/prod(tvnum);
if(floor(repetitionsPerBlock) < repetitionsPerBlock)
  error('There not enough trials in each block (%d repetitions)', repetitionsPerBlock) ;
end;
if((repetitionsPerBlock-floor(repetitionsPerBlock)) > 0 && ~isfield(ex,'allowUnequalTrials'))
  error('There are insufficient trials to give an equal number of each trial type');
end

bvvi=ones(1,length(bvarnames)); % index of current block variables, in range 0-bvnum(i)
for b = 1:ex.blocks      % construct the blocks
    tvvi=ones(1, length(tvarnames)); % index of current trial variables
    for t = 1:ex.blockLen
        %tr{b,t}=ex; %copy all params -- optional!
        for i=[1:length(bvarnames)]  % set block type
            if iscell(bvvlist{i})
                tr=setfield(tr,{b,t}, bvarnames{i}, bvvlist{i}{bvvi(i)});
            else
                tr=setfield(tr,{b,t}, bvarnames{i}, bvvlist{i}(bvvi(i)));
            end;
        end;
        for i=[1:length(tvarnames)] % set trial type
            if iscell(tvvlist{i})
                tr=setfield(tr,{b,t}, tvarnames{i}, tvvlist{i}{tvvi(i)});
            else
                tr=setfield(tr,{b,t}, tvarnames{i}, tvvlist{i}(tvvi(i)));
            end;
        end;
        done=false;
        ti=1;
        while ~done                % serially increment trial type
            tvvi(ti)=tvvi(ti)+1;
            if(tvvi(ti)>tvnum(ti)) % increment next trial variable
                tvvi(ti)=1;
                ti=ti+1;
                if(ti>length(tvvi)) done=1; end; %back to ones
            else done=1; end;
        end;
    end;
    done=false;
    while ~done                    % serially increment block type
        bi=1;
        bvvi(bi)=bvvi(bi)+1;
        if(bvvi(bi) > bvnum(bi))   % increment next block variable
            bvvi(bi)=1;
            bi=bi+1;
            if(bi>length(bvvi)) done=1; end; % back to ones
        else done=1;   end;
    end;
end;


% trial order - shuffle for each block, but counterbalance trial order
% across blocks
nbt=prod(bvnum);    % number of block types
nebt=ex.blocks/nbt; % number of each block type
for b=1:ex.blocks
    if(b<=ex.blocks/2+1)    % counterbalance order across blocks
        order(b,:) = Shuffle(1:ex.blockLen);
    else
        order(b,:) = order(ex.blocks-b+1,:);
    end
    tr(b,:)=tr(b,order(b,:));
end;


% block order

otr=tr; counterbalance=1;
if( (nebt/2) == floor(nebt/2) )  % if even, counterbalance blocks
    if(isfield(ex, 'blockorder'))
        if(length(ex.blockorder)==ex.blocks/2)
            blockorder=ex.blockorder;
        else
            blockorder=repmat(ex.blockorder,1,1+floor(ex.blocks/length(ex.blockorder)));
            blockorder=blockorder(1:ex.blocks);
            warning('createTrials:blockorder',['Block order is ' num2str(length(ex.blockorder))...
                ' blocks long, but experiment is ' num2str(ex.blocks) ' long. '...
                'Blocks not counterbalanced.']);
            counterbalance=0;
        end
    else
        blockorder=Shuffle(1:ex.blocks/2);
    end;

else                       % otherwise randomise blocks
    if(isfield(ex, 'blockorder'))
        blockorder=ex.blockorder;
        if(length(blockorder)<ex.blocks) % blockorder too small? repeat it
            blockorder=repmat(blockorder,1,1+floor(ex.blocks/length(blockorder)));
            warning('createTrials:blockorder', ['blockorder is only ' ...
                num2str(length(ex.blockorder)) 'items. Repeating to fill '...
                num2str(ex.blocks) ' blocks.']);
        end;
    else
        blockorder=Shuffle(1:ex.blocks);
        warning('createTrials:blocknumber',...
            ['There are ' num2str(nbt) ' types of block, but ' num2str(ex.blocks)...
            ' blocks. Shuffling them, but some will be more frequent.']);
    end;
    counterbalance=0;
end;
if(counterbalance)
    tr(1:ex.blocks/2,:) = tr(blockorder,:);
    tr(ex.blocks/2+1:end,:) = tr(ex.blocks/2:-1:1,:);
else
    tr(:,:)=tr(blockorder,:);
end;
blockorder