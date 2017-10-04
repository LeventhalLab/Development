function scr=prepareScreen(d)
% setup Screen (returns 'scr' struct) on display 
% creates Screen window
% preloads images and sounds
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% returns:
%  scr.w        = window number
%  xhairCoords  = a crosshair as coords of two rects, at Screen centre
%
%  scr.soundData{i}  - sound file data         }
%  scr.soundFs{i}    - sound file format info  }  of the given files
%  scr.imageData{i}  - image file data         }
%  scr.imageMap{i}   - image file colour map   }  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% params:
%  d.bgColour
%  d.targetPos = [dx,dy] - returns scr.xhairCoords(:,:,2) and (:,:,3) as
%                          rects for crosshairs at these points relative to
%                          centre: [+dx,+dy], [-dx,-dy]
%  d.imageFiles = {'f1'} - returns scr.imageData and scr.imageMap as data
%                          from image files image, and a openGL texture
%                          texture.
%  d.imageAlpha = n      - colour index n is converted to the background
%                          colour index specified by d.bgColourIndex
%  d.soundFiles = {'f1'} - returns scr.soundData and scr.soundFs which 
%  d.displayNumber = n   - use display number to open experiment Screen,
%                          default = display 0
%

%d.displayNumber =1;


if(prod(size(Screen('Screens')))) Screen('CloseAll'); end;
if(isfield(d,'skipScreenCheck'))
    Screen('Preference', 'SkipSyncTests',d.skipScreenCheck);
end
if(~isfield(d,'displayNumber')) d.displayNumber=0; end;
[scr.w, scr.sszrect] = Screen('OpenWindow', d.displayNumber, d.bgColour);% [601 401 1400 1000]);
Screen('Flip',scr.w);
scr.ssz=scr.sszrect(:,3:4);
scr.centre=scr.ssz/2;
if(isfield(d,'xhairSize'))
    xh=repmat(d.xhairSize,1,2) .* [-1 -1 1 1];
    scr.xhairCoords(:,:,1)=[ repmat(scr.centre,1,2)+xh([1 2 3 4]);...
                 repmat(scr.centre,1,2)+xh([2 1 4 3]) ]; %centre
    if(isfield(d,'targetPos'))
        scr.xhairCoords(:,:,2)=[ repmat(scr.centre+d.targetPos,1,2)+xh([1 2 3 4]);...
                 repmat(scr.centre+d.targetPos,1,2)+xh([2 1 4 3]) ]; %right
        scr.xhairCoords(:,:,3)=[ repmat(scr.centre-d.targetPos,1,2)+xh([1 2 3 4]);...
                 repmat(scr.centre-d.targetPos,1,2)+xh([2 1 4 3]) ]; %left
    end;
end;
if(isfield(d,'imageFiles'))
    for i=1:length(d.imageFiles)
        fn=d.imageFiles{i};
        type = fn(end-2:end);
        if fn(end-3)~='.' 
            if fn(end-4)=='.'
                type=fn(end-3:end);
            else
                type='gif';
            end;
        end;
        [scr.imageData{i},scr.imageMap{i}]=imread(d.imageFiles{i},type);
        if(isfield(d,'imageAlpha'))
            discrimImage1(scr.imageData{i}==d.imageAlpha) = d.bgColourIndex;
            scr.imageTexture(i)=Screen('MakeTexture', scr.w, ...
               cat(3, scr.imageData{i}, scr.imageData{i}==d.bgColourIndex));
        else
            scr.imageTexture(i)=Screen('MakeTexture', scr.w, ...
                scr.imageData{i});
        end;
        scr.imageSize{i} = [size(scr.imageData{i},2) size(scr.imageData{i},1)];
    end;
end;

%cedrus=serial('COM6');
%fopen(cedrus);
if(isfield(d,'soundFiles'))
    for(i=1:length(d.soundFiles))
      if(isempty(d.soundFiles{i})) continue; end;
      try
        if exist('audioread','file')
            [scr.soundData{i} scr.soundFs{i}]=audioread(d.soundFiles{i});
            scr.soundPlayer{i} = audioplayer(scr.soundData{i}, scr.soundFs{i});
        else
            [scr.soundData{i} scr.soundFs{i}]=wavread(d.soundFiles{i});
        end
      catch exc
        fprintf('Error reading %s\n',d.soundFiles{i});
        rethrow(exc)
      end
    end;
end;
Screen(scr.w, 'TextSize', 32);
Screen(scr.w, 'TextFont',  'Arial');

HideCursor;
FlushEvents '';
