saveFile = '/Users/mattgaidica/Desktop/plotByUnitClass3DPETHVideo2.avi';
legendPath = '/Users/mattgaidica/Dropbox/Presentations/2017 NGP Symposium/assets/Choice Task';
legendName = 'CT-sequence-frames_';
legendExt = '.jpg';
legendCoords = [722 2208];

doVideo = true;

colors = jet(7);
useEvents = [1:7];
all_AP = [];
all_ML = [];
all_DV = [];
all_colors = [];
usedNeuronIds = [];
neuronCount = 1;
for iNeuron = 1:size(analysisConf.neurons,1)
    neuronName = analysisConf.neurons{iNeuron};
    sessionConf = analysisConf.sessionConfs{iNeuron};
    [electrodeName,electrodeSite,electrodeChannels] = getElectrodeInfo(neuronName);
    channelData = get_channelData(sessionConf,electrodeChannels);
    event_id = eventIds_by_maxHistValues(iNeuron);
    if ~ismember(event_id,useEvents)
        continue;
    end
    if isempty(channelData)
        continue;
    end
    wiggle = (rand(1) - 0.5) * 0.1;
    AP = channelData{1,'ap'} + wiggle;
    wiggle = (rand(1) - 0.5) * 0.1;
    ML = channelData{1,'ml'} + wiggle;
    wiggle = (rand(1) - 0.5) * 0.1;
    DV = channelData{1,'dv'} * -1 + wiggle;
    all_AP = [all_AP;AP];
    all_ML = [all_ML;ML];
    all_DV = [all_DV;DV];
    
%     all_colors = [all_colors;colors(event_id,:)];
    usedNeuronIds(neuronCount) = iNeuron;
    neuronCount = neuronCount + 1;
end

if doVideo
    newVideo = VideoWriter(saveFile,'Motion JPEG AVI');
    newVideo.Quality = 100;
    newVideo.FrameRate = 30;
    open(newVideo);
end

ninterp = 5;
firstLoop = true;
az = 140;
el = 10;
colormapArr = ones(size(neuronPeth,3) * ninterp,3);
tickWidth = ceil(size(neuronPeth,3) * ninterp * 0.02);
colormapArr(1:tickWidth,:) = 0;
for iEvent = 1:size(neuronPeth,2) % use all events right now
    for iFrame = 1:size(neuronPeth,3) * ninterp
        all_colors = [];
        all_sizes = [];
        for iNeuron = usedNeuronIds
            curPeth = squeeze(squeeze(neuronPeth(iNeuron,iEvent,:))); % 40 samples
            smoothdata = interp(curPeth,ninterp);
            neuronZFrameVal = abs(smoothdata(iFrame)); % might want negative?
            neuronBaseColor = colors(eventIds_by_maxHistValues(iNeuron),:);
            neuronBaseColorHsv = rgb2hsv(neuronBaseColor);
% %             neuronBaseColorHsv(1,2) = min([neuronZFrameVal*1.5,1]); % base SAT, w/ max = 1
            neuronFinalColor = hsv2rgb(neuronBaseColorHsv);
            all_colors = [all_colors;neuronFinalColor];
            all_sizes = [all_sizes;0.03 + neuronZFrameVal*0.07];
        end
        h1 = figure('position',[0 0 1334 750],'Visible','On');
        ax = [];
        hold on;
        for ii = 1:numel(eventFieldnames)
            ax(ii) = plot(rand(1,2),rand(1,2),'.','markerSize',50,'color',colors(ii,:));
        end
        
        shapeColors = {'r','g','b','y'};
        for iShape = 1:numel(shapes)
            h = plot(shapes{iShape});
%             h.FaceLighting = 'gouraud';
            h.AmbientStrength = 0.3;
            h.DiffuseStrength = 0.8;
%             h.SpecularStrength = 0.9;
%             h.SpecularExponent = 25;
        %     h.BackFaceLighting = 'unlit';
            h.EdgeColor = 'none';
            h.FaceColor = shapeColors{iShape};
            h.FaceAlpha = 0.15;
            hold on;
        end

        scatter3sph(all_AP,all_ML,all_DV,'size',all_sizes,'color',all_colors,'transp',0.75);
        eventFieldnamesLegend = {'Light On','Nose In','Cue/Go','Nose Out','Side In','Side Out','Food Cup'};
        lgd = legend(ax,eventFieldnamesLegend,'location','northeastoutside','FontSize',20);
        legend('boxoff');
        drawnow;
        delete(ax);

        if firstLoop
            set(gcf,'color','w');
%             light('Position',[1 1 1],'Style','local','Color',[1 1 1]);
%             lighting gouraud;
            grid on;
            
%             xlabel('ML'); 
            lims_ml = [.5 2.5]; yticks(lims_ml); yticklabels({'lateral','medial'}); ylim(lims_ml);
%             ylabel('AP');
            lims_ap = [-4 -1.5]; xticks(lims_ap); xticklabels({'posterior','anterior'}); xlim(lims_ap);
%             zlabel('DV');
            lims_dv = [-8 -5.5]; zticks(lims_dv); zticklabels({'dorsal','ventral'}); zlim(lims_dv);
            
%             set(gca,'zdir','reverse');
            set(gca,'xdir','reverse');
%             set(gca,'ydir','reverse');
            set(gca,'fontSize',14);
            
            c = colorbar('southoutside');
            cticks = [-1 -.75 -.5 -.25 0 .25 .5 .75 1];
            caxis([-1 1]);
            set(c,'YTick',cticks);
            set(c,'FontSize',20);
            ylabel(c,'time (s)');
            colormap(circshift(colormapArr,iFrame-1));
            
            
%             firstLoop = false;
        end
        view(az,el);
        az = az - (0.3 / ninterp);
        el = el + (0.1 / ninterp);
%         title(eventFieldnames{iEvent},'FontSize',18);
%         drawnow;
        disp(iFrame);
        im = frame2im(getframe(gcf));
        im_legend = imread(fullfile(legendPath,[legendName,num2str(iEvent),legendExt]));
        im(legendCoords(1):legendCoords(1)+size(im_legend,1)-1,...
            legendCoords(2):legendCoords(2)+size(im_legend,2)-1,:) = im_legend;
        if doVideo
            writeVideo(newVideo,im);
        end
        close(h1);
    end
end

if doVideo
    close(newVideo);
end

% % hold on;
% % xlims = xlim;
% % ylims = ylim;
% % ax = [];
% % for ii = 1:numel(useEvents)
% %     ax(ii) = plot(xlims(1),ylims(1),'.','markerSize',30,'color',colors(useEvents(ii),:));
% % end
% % 
% % legend(ax,eventFieldnames(useEvents));
% % drawnow;
% % delete(ax);