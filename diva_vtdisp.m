function varargout=diva_vtdisp(option,varargin)

if ~nargin||isempty(option), option='init'; end
hfig=[];
if ishandle(option), hfig=option; option=varargin{1}; varargin=varargin(2:end); end

switch(lower(option))
    case 'init'
        %data.state.x=zeros(13,1);
        %[data.state.y,data.state.z,data.state.Outline]=diva_synth(data.state.x);
        
        % setting up figure
        data.handles.hfig=figure('units','norm','position',[.25 .35 .5 .5],'menubar','none','name','DIVA vocal tract display','numbertitle','off','color','w','interruptible','on','busyaction','queue');
        
        mfigTitle = uicontrol('Style','text','String','Articulatory Synthesizer','Units','normalized','FontUnits','norm','FontSize',0.8, 'HorizontalAlignment', 'center', 'Position', [0 0.955, 1, 0.05],'BackgroundColor',[1 1 1]);
        
        % setting up 2D vocal tract
        %data.handles.hax1=axes('units','norm','position',[.05 .3 .45 .65],'color',1*[1 1 1]);
        data.handles.hax1=axes('units','norm','position',[0 .26 .45 .65],'color',1*[1 1 1]);
        
        % memory first (h0 is outline, h1 is fill)
        % ver1 solid moving, dotted fixed
        % ver2 is the opposite
        data.handles.h1_memory=patch(nan,nan,'k','facecolor','none','linestyle','--','edgecolor','none','linewidth',2,'parent',data.handles.hax1);
        % regular 2D representation
        data.handles.h1=[patch(nan,nan,'k','facecolor',.50*[1 1 1],'facealpha',.25,'edgecolor','none','linewidth',2,'parent',data.handles.hax1),patch(nan,nan,'k','facecolor',.50*[1 1 1],'facealpha',.25,'edgecolor','none','linewidth',2,'parent',data.handles.hax1)];
        hold(data.handles.hax1,'on'); data.handles.h0=plot(nan,nan,'k','linewidth',2,'parent',data.handles.hax1); hold(data.handles.hax1,'off');
        hold(data.handles.hax1,'on'); data.handles.h0_memory=plot(nan,nan,'k','linestyle',':','linewidth',2,'parent',data.handles.hax1); hold(data.handles.hax1,'off');
        hold(data.handles.hax1,'on'); data.handles.mousepos1=plot(nan,nan,'.:','linewidth',1,'color',.85*[1 1 1],'parent',data.handles.hax1); hold(data.handles.hax1,'off');
        
        axis(data.handles.hax1,'equal','tight');
        set(data.handles.hax1,'xcolor','w','ycolor','w','xtick',[],'ytick',[],'xdir','reverse');
        %set(data.handles.h1,'xdata',real(data.state.Outline),'ydata',imag(data.state.Outline));
        
        % setting up supplementary plots for 2D vocal tract vocalization
        data.handles.hax1a=axes('units','norm','position',[.34 .26 .04 .65]);
        data.handles.hax1b=axes('units','norm','position',[.38 .26 .04 .65]);
        data.handles.hax1c=axes('units','norm','position',[.42 .26 .04 .65]);
        % arc plot data
        t = linspace(150, 210, 100); t2 = linspace(135, 225, 100); t3 = linspace(120, 240, 100);
        x  = 3 * cosd(t);y  = 3 * sind(t);x2 = 4 * cosd(t2);y2 = 4 * sind(t2);x3 = 5 * cosd(t3);y3 = 5 * sind(t3);
        data.handles.h1a = plot(-x+2, -y, 'k-', 'LineWidth', 2, 'parent', data.handles.hax1a,'visible', 'on');
        data.handles.h1b = plot(-x2, -y2, 'k-', 'LineWidth', 2, 'parent', data.handles.hax1b,'visible', 'on');
        data.handles.h1c = plot(-x3, -y3, 'k-', 'LineWidth', 2, 'parent', data.handles.hax1c,'visible', 'off');
        set(data.handles.hax1a, 'YLim', [-4 4], 'XLim', [4.5 5]); set(data.handles.hax1b, 'YLim', [-4 4], 'XLim', [3.3 4]); set(data.handles.hax1c, 'YLim', [-6 6], 'XLim', [3.0 5]);
        set(data.handles.hax1a,'box','off','xtick',[],'ytick',[], 'visible', 'off'); set(data.handles.hax1b,'box','off','xtick',[],'ytick',[], 'visible', 'off'); set(data.handles.hax1c,'box','off','xtick',[],'ytick',[], 'visible', 'off');
        
        % plotting area function
        data.handles.hax2=axes('units','norm','position',[.1 .06 .3 .15],'color',.85*[1 1 1]);
        data.handles.h2=patch(nan,nan,'k','facecolor',1*[1 1 1],'edgecolor','k','linewidth',2,'parent',data.handles.hax2);
        xlabel(data.handles.hax2,'distance to glottis (cm)'); ylabel(data.handles.hax2,'Area (cm^2)');
        
        % plotting frequency spectrum
        data.handles.hax3=axes('units','norm','position',[.6 .06 .3 .15],'box','off');
        data.handles.h3=plot(nan,nan,'k','color',.75*[1 1 1],'linewidth',2,'parent',data.handles.hax3);
        %hold on; data.handles.h6=plot(nan,nan,'co','markerfacecolor','c'); hold off; If I wanted to add cyan markers on the plot 
        hold on; data.handles.h3F1=plot(nan,nan,'-','color','k','linewidth',2,'parent',data.handles.hax3);  hold off;
        hold on; data.handles.h3F2=plot(nan,nan,'-','color','k','linewidth',2,'parent',data.handles.hax3);  hold off;
        hold on; data.handles.h3F3=plot(nan,nan,'-','color','k','linewidth',2,'parent',data.handles.hax3);  hold off;
        hold(data.handles.hax3,'on'); data.handles.mousepos2=plot(nan,nan,'.:','linewidth',1,'color',.85*[1 1 1],'parent',data.handles.hax3); hold(data.handles.hax3,'off');
        xlabel(data.handles.hax3,'Frequency (Hz)');
        ylabel(data.handles.hax3,'VT filter (dB)');
        data.handles.VTopenCheck = uicontrol('Style','checkbox','Tag','VTopen','String','Keep VT open','Units','norm','FontUnits','norm','FontSize',0.35,'Position', [0.91,0.046,0.09,0.05],'BackgroundColor',[1 1 1]);
        
        % plotting vert 'bar-sliders'
        %data.handles.hax4 = axes('units','norm','position',[.525 .325 .45 .625]);
        %data.handles.hplot4 = bar(zeros(1,13)); % psst you need to plot the bar first, before changing the axes properties
        %data.handles.hax4.YLimMode = 'manual';  % or else it'll just change the Ylim properties to be the default for bar plots!!
        %data.handles.hax4.YLim = [-1 1];        % used to be -3 to 3, but that seemed excessive....
        %data.handles.hplot4.FaceColor = 'flat';
        %data.handles.hplot4 = bar(-3+(3+3)*rand(1,13));
        
        % main articulators (1:10 or 1:numMainArt)
        %data.handles.hax4 = axes('units','norm','position',[.525 .325 .45 .625]);
        labels = diva_vocaltract();
        numMainArt = length((labels.Input.Plots_label(2:end)));
        %numMainArt = length((labels.Input.Plots_label(2:end-3)));
        data.numMainArt = numMainArt;
        mArtAxPos = [.535 .275 .22 .6];
        data.handles.hax4 = axes('units','norm','position',mArtAxPos);
        data.handles.hplot4 = barh(zeros(1,numMainArt), 'BarWidth', 0.8); % psst you need to plot the bar first, before changing the axes properties
        hold on; title('Motor articulators', 'FontWeight', 'normal'); hold off;
        hold on; data.handles.hplot5=plot(zeros(numMainArt,1),1:numMainArt,'ko','markerfacecolor','k'); hold off
        %%% adding bar values to main articulators 
        data.handles.h4text = text((zeros(numMainArt,1)-0.1),1:numMainArt,num2str(zeros(numMainArt,1)),'Color','black','vert','middle','horiz','right');
        data.handles.hplot4.FaceColor = 'flat';
        set(data.handles.hax4, 'YLimMode', 'manual', 'YLim', [0.5 numMainArt+0.5], 'XLimMode', 'manual', 'XLim', [-1 1], 'YDir', 'reverse');
        %motorArtLabels = labels.Input.Plots_label(2:end);
        %set(data.handles.hax4, 'FontUnits','norm','FontSize',0.04,'YTickLabel', pad(labels.Input.Plots_label(2:end),0), 'Fontunit', 'norm');
        set(data.handles.hax4, 'FontUnits','norm','FontSize',0.04,'YTickLabel', pad(labels.Input.Plots_label(2:end),18), 'Fontunit', 'norm');
        data.handles.lockTxt = uicontrol('Style','text','String','Lock:','Tag','lockTxt','Units','norm','FontUnits','norm','FontWeight','bold','FontSize',0.65,'Position',[0.505,0.86,0.029,0.025] ,'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0]);
        for i = 0:numMainArt-1 % creating restrict / lock checkboxes
            mArtLabelPos = [0.518, (mArtAxPos(2)*0.95)+(i*(mArtAxPos(4)/10))+(mArtAxPos(4)/10)/2 , 0.016, 0.0245];
            data.handles.mArtCheckboxes(i+1) = uicontrol('Style','checkbox','Tag',sprintf('mArtCheck%d', i+1),'Units','norm','FontUnits','norm','FontSize',0.35,'Position', mArtLabelPos,'BackgroundColor',[1 1 1]);
        end
        
        % Glottis articulators (11:13 or [numMainArt+1]:[numMainArt+3])
        numSuppArt = numMainArt+3; % ideally want +3 to be determined by total number of labels or something
        data.numSuppArt = numSuppArt;
        data.handles.hax4b = axes('units','norm','position',[.84 .72 .15 .16]);
        data.handles.hplot4b = barh((numMainArt+1:numSuppArt),[0 0.5 0.5], 'BarWidth', 0.6);
        hold on; title('Glottis','FontWeight', 'normal'); hold off;
        hold on; data.handles.hplot5b=plot([0 .5 .5],(numMainArt+1:numSuppArt),'ko','markerfacecolor','k'); hold off
        %%% adding bar values to supp articulators 
        data.handles.h4btext = text([-0.1 0.6 0.6],(numMainArt+1:numSuppArt),num2str([0.0;0.5;0.5]),'Color','black','vert','middle','horiz','right');
        set(data.handles.h4btext(2),'String',round(0.5,2,'significant'),'vert','middle','horiz','left');
        set(data.handles.h4btext(3),'String',round(0.5,2,'significant'),'vert','middle','horiz','left');
        data.handles.hplot4b.FaceColor = 'flat';
        set(data.handles.hax4b, 'YLimMode', 'manual', 'YLim', [numMainArt+0.5 numSuppArt+0.5], 'XLimMode', 'manual', 'XLim', [-1 1], 'YDir', 'reverse');
        set(data.handles.hax4b, 'FontUnits','norm','FontSize',0.15,'YTickLabel', {'Tension','Pressure','Voicing'}, 'Fontunit', 'norm');
        
        % Constriction articulators (14:20 or [numSuppArt+1]:[numConst+6])
        numConstArt = numSuppArt+6; % ideally want +3 to be determined by total number of labels or something
        data.numConstArt = numConstArt;
        data.handles.hax4c = axes('units','norm','position',[.84 .275 .15 .38]);
        data.handles.hplot4c = barh((numSuppArt+1:numConstArt),zeros(numConstArt-numSuppArt,1), 'BarWidth', 0.6);
        hold on; title('Constrictions','FontWeight', 'normal'); hold off;
        hold on; data.handles.hplot5c=plot(zeros(numConstArt-numSuppArt,1),(numSuppArt+1:numConstArt),'ko','markerfacecolor','k'); hold off
        %%% adding bar values constrictor articulators 
        data.handles.h4ctext = text(zeros(numConstArt-numSuppArt,1)-0.1,(numSuppArt+1:numConstArt),num2str(zeros(numConstArt-numSuppArt,1)),'Color','black','vert','middle','horiz','right');
        data.handles.hplot4c.FaceColor = 'flat';
        set(data.handles.hax4c, 'YLimMode', 'manual', 'YLim', [numSuppArt+0.5 numConstArt+0.5], 'XLimMode', 'manual', 'XLim', [-1 1], 'YDir', 'reverse');
        % formatting constriction labels
        constLabels = cellfun(@(x) [upper(x(4)) x(5:end)], labels.Output(2).Plots_label(4:end), 'UniformOutput', false);
        set(data.handles.hax4c, 'FontUnits','norm','FontSize',0.056,'YTickLabel', constLabels , 'Fontunit', 'norm');        
        
        set(data.handles.hfig,'WindowButtonDownFcn',@downcallback, 'WindowButtonUpFcn',@upcallback, 'WindowButtonMotionFcn',@overcallback); % callback for when mouse hovers over plot
        
        % create new target button
        data.handles.cr8TargetButton = uicontrol('Style','pushbutton','String','Create new target','Units','normalized','FontUnits','norm','FontSize',0.36,'Position',[.86 .93 .1 .05],'Visible','on','CallBack', @cr8TargetPushed);
        % reset button
        data.handles.resetButton = uicontrol('Style','pushbutton','String','Reset','Units','normalized','FontUnits','norm','FontSize',0.3,'Position',[.25 .26 .06 .06],'Visible','on','CallBack', @resetPushed);
        % synthesize button
        data.handles.synthButton = uicontrol('Style','pushbutton','String','Synthesize','Units','normalized','FontUnits','norm','FontSize',0.3,'Position',[.25 .33 .06 .06],'Visible','on','CallBack', @synthPushed);
             
        % flag for first time setup
        data.setup = 1;
        clear diva_synth %on rare occasions the persistent vt variable needs to be updated
        set(data.handles.hfig,'userdata',data);
        diva_vtdisp(data.handles.hfig,'updsliders',[zeros(numMainArt,1);0;.5;.5]); 
        diva_vtdisp(data.handles.hfig,'update',[zeros(numMainArt,1);0;.5;.5]); % uses 'update' case to initialize default plots
        drawnow;
        
    case 'setslider' % called when a slider is moved, or mouse is released
        %stateData = varargin{1};
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        n=[];
        %if numel(varargin)>=1, n=varargin{1}; end
        %if numel(varargin)>=2, v=varargin{2}; end
        % Instead of looking though fields for specific data var, should
        % just look at the newly implemented 'currAxis'
        if isfield(data, 'curBar') && isfield(data, 'curBarVal')
            n=data.curBar;
            v=data.curBarVal;
        elseif isfield(data, 'newVocalT')
            v=0;
        elseif isfield(data, 'curFtarget')
            v=0;
        else
            return;
        end
        if isempty(n), n=1:numel(v); end
        try, x=data.state.x(:,end);
        catch, x=zeros(data.numSuppArt,1);
        end
        
        if isfield(data, 'newVocalT')
            x=diva_solveinv('target_outline',x,data.newVocalT,'lambda',0.02,'center',data.oldstatex,'stepiter',.1); %,'center',data.oldVocalT);
            x=max(-1,min(1,x));
            %diva_vtdisp(hfig,'test',x,stateData);
            %diva_vtdisp(hfig,'updsliders',x,data);
            data = rmfield(data,'newVocalT'); % remove vCord var so that GUI doesn't always assume you are changing the vocal cord
        end
         if isfield(data, 'constTarget')
             x=diva_solveinv('target_somatosensory',x,data.constTarget,'lambda',0.02,'center',data.oldstatex);
             %x=diva_solveinv('target_formant',x,data.curFtarget,'center',data.origF);
             x=max(-1,min(1,x));
             %diva_vtdisp(hfig,'test',x,stateData);
             %diva_vtdisp(hfig,'updsliders',x,data);
             data = rmfield(data,'constTarget'); % remove vCord var so that GUI doesn't always assume you are changing the vocal cord
         end
        if isfield(data, 'curFtarget')
            x=diva_solveinv('target_formant',x,data.curFtarget,'lambda',0.02,'center',data.oldstatex);
            %x=diva_solveinv('target_formant',x,data.curFtarget,'center',data.origF);
            x=max(-1,min(1,x));
            %diva_vtdisp(hfig,'test',x,stateData);
            %diva_vtdisp(hfig,'updsliders',x,data);
            data = rmfield(data,'curFtarget'); % remove vCord var so that GUI doesn't always assume you are changing the vocal cord
        end
        diva_vtdisp(hfig,'updsliders',x,data);
        
        x=repmat(x,[1,100]);
        if (data.currAxis == '4') | (data.currAxis == '4b')  %| (data.currAxis == '4c')
            x(n,:)=[linspace(x(n,1),v,20),repmat(v,1,80)]; % for cases where articulator slides are being changed
        end 
        diva_vtdisp(hfig,'update',x,data);
        
        
    case 'updsliders'
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');

        %%% for constriction values
        x = varargin{1};
        x=repmat(x,[1,100]);
        n=[1:9:size(x,2)-1,size(x,2)];
        n=n(end);
        [test.state.Aud,test.state.Som,test.state.Outline,test.state.af,test.state.filt]=diva_synth(x(:,n), 'explicit');
        constVals = test.state.Som(1:6);
        
        newVals = varargin{1}';
        % for main articulators
        set(data.handles.hplot4, 'YData', newVals(1:data.numMainArt));
        set(data.handles.hplot5, 'XData', newVals(1:data.numMainArt));
        for i = 1:data.numMainArt
            set(data.handles.h4text(i),'String', round(newVals(i),3,'significant'));
            if newVals(i) > 0
                if newVals(i) > 0.5
                    set(data.handles.h4text(i),'horiz','right','Position', [newVals(i)-0.1,i,0],'Color', 'White');
                else
                    set(data.handles.h4text(i),'horiz','left','Position', [newVals(i)+0.1,i,0],'Color', 'Black');
                end
            else
                if newVals(i) < -0.5
                    set(data.handles.h4text(i),'horiz','left','Position', [newVals(i)+0.1,i,0],'Color', 'White');
                else
                    set(data.handles.h4text(i),'horiz','right','Position', [newVals(i)-0.1,i,0],'Color', 'Black');
                end
            end
        end
        % for supp articulators
        set(data.handles.hplot4b, 'YData', newVals(data.numMainArt+1:data.numSuppArt));
        set(data.handles.hplot5b, 'XData', newVals(data.numMainArt+1:data.numSuppArt));
        for i = data.numMainArt+1:data.numSuppArt
            set(data.handles.h4btext(i-data.numMainArt),'String', round(newVals(i),2,'significant'));
            if newVals(i) > 0
                if newVals(i) > 0.5
                    set(data.handles.h4btext(i-data.numMainArt),'horiz','right','Position', [newVals(i)-0.1,i,0],'Color', 'White');
                else
                    set(data.handles.h4btext(i-data.numMainArt),'horiz','left','Position', [newVals(i)+0.1,i,0],'Color', 'Black');
                end
            else
                if newVals(i) < -0.5
                    set(data.handles.h4btext(i-data.numMainArt),'horiz','left','Position', [newVals(i)+0.1,i,0],'Color', 'White');
                else
                    set(data.handles.h4btext(i-data.numMainArt),'horiz','right','Position', [newVals(i)-0.1,i,0],'Color', 'Black');
                end
            end
            if i == 13
                if newVals(i) >= 0.7
                    set(data.handles.h1a, 'visible', 'on');
                    set(data.handles.h1b, 'visible', 'on');
                    set(data.handles.h1c, 'visible', 'on');
                    set(data.handles.hfig,'userdata',data);
                elseif newVals(i) >= 0
                    set(data.handles.h1a, 'visible', 'on');
                    set(data.handles.h1b, 'visible', 'on');
                    set(data.handles.h1c, 'visible', 'off');
                    set(data.handles.hfig,'userdata',data);
                elseif newVals(i) >= -0.7
                    set(data.handles.h1a, 'visible', 'on');
                    set(data.handles.h1b, 'visible', 'off');
                    set(data.handles.h1c, 'visible', 'off');
                    set(data.handles.hfig,'userdata',data);
                else
                    set(data.handles.h1a, 'visible', 'off');
                    set(data.handles.h1b, 'visible', 'off');
                    set(data.handles.h1c, 'visible', 'off');
                    set(data.handles.hfig,'userdata',data);
                end
            end
        end
        % for constrictor articulators (section may change in future!!)
        set(data.handles.hplot4c, 'YData', constVals);
        set(data.handles.hplot5c, 'XData', constVals);
        for i = data.numSuppArt+1:data.numConstArt
            set(data.handles.h4ctext(i-data.numSuppArt),'String', round(constVals(i-data.numSuppArt),2,'significant'));
            if constVals(i-data.numSuppArt) > 0
                if constVals(i-data.numSuppArt) > 0.5
                    set(data.handles.h4ctext(i-data.numSuppArt),'horiz','right','Position', [constVals(i-data.numSuppArt)-0.1,i,0],'Color', 'White');
                else
                    set(data.handles.h4ctext(i-data.numSuppArt),'horiz','left','Position', [constVals(i-data.numSuppArt)+0.1,i,0],'Color', 'Black');
                end
            else
                if constVals(i-data.numSuppArt) < -0.5
                    set(data.handles.h4ctext(i-data.numSuppArt),'horiz','left','Position', [constVals(i-data.numSuppArt)+0.1,i,0],'Color', 'White');
                else
                    set(data.handles.h4ctext(i-data.numSuppArt),'horiz','right','Position', [constVals(i-data.numSuppArt)-0.1,i,0],'Color', 'Black');
                end
            end
        end
        set(data.handles.hfig,'userdata',data);
        
        
    case 'update'
        %if numel(varargin)> 1
        %    stateData = varargin{2};
        %end
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        data.state.x=varargin{1};
        if ~isfield(data,'oldstatex'), data.oldstatex=data.state.x(:,end); end
        
        % vocalization display
        if (exist('data', 'var') == 1 && isfield(data, 'curBar'))
            if data.curBar == data.numSuppArt
                if data.curBarVal >= 0.7
                    set(data.handles.h1a, 'visible', 'on');
                    set(data.handles.h1b, 'visible', 'on');
                    set(data.handles.h1c, 'visible', 'on');
                    set(data.handles.hfig,'userdata',data);
                elseif data.curBarVal >= 0
                    set(data.handles.h1a, 'visible', 'on');
                    set(data.handles.h1b, 'visible', 'on');
                    set(data.handles.h1c, 'visible', 'off');
                    set(data.handles.hfig,'userdata',data);
                elseif data.curBarVal >= -0.7
                    set(data.handles.h1a, 'visible', 'on');
                    set(data.handles.h1b, 'visible', 'off');
                    set(data.handles.h1c, 'visible', 'off');
                    set(data.handles.hfig,'userdata',data);
                else
                    set(data.handles.h1a, 'visible', 'off');
                    set(data.handles.h1b, 'visible', 'off');
                    set(data.handles.h1c, 'visible', 'off');
                    set(data.handles.hfig,'userdata',data);
                end
            end
        end
        
        d=1.5*.75/10;
        fs=4*11025;
        
        %pay attention here for real-time plot update
        %for n=[1:9:size(data.state.x,2)-1,size(data.state.x,2)]
        n=[1:9:size(data.state.x,2)-1,size(data.state.x,2)];
        n=n(end);
        %n = 100;
        
        [data.state.Aud,data.state.Som,data.state.Outline,data.state.af,data.state.filt]=diva_synth(data.state.x(:,n), 'explicit');
        
        % the following works, but it would be nicer for it to notify the
        % user and also not update the sliders / revert them to the last
        % config that worked.
        if 0,%sum(data.state.filt) == 0 % if this is 0, this is a configuration which results in no sound
            %disp('reached breaking point 2')
            set(data.handles.h0, 'Color' ,'red')
            set(data.handles.hfig,'userdata',data);
            return
        else
            set(data.handles.h0, 'Color' ,'black')
        end
        
        % vocal tract configuration
        x=data.state.Outline;
        x(end+1)=x(1);
        xI=real(x(353))+1i*imag(x(160));
        xA=[xI;x(354:end);x(1:160);xI];
        xB=[xI;x(160:353);xI];
        xC=[xA;xB];
        
        if data.setup
            set(data.handles.h0,'xdata',real(x),'ydata',imag(x));
            set(data.handles.h0_memory,'xdata',real(x),'ydata',imag(x));
        end
        
        if exist('data', 'var') == 1 && isfield(data, 'ready2play')
            if data.ready2play
                % Vocal tract memory ver 1
                set(data.handles.h0_memory,'xdata',real(x),'ydata',imag(x));
                % ver 2
                %set(data.handles.h0,'xdata',real(x),'ydata',imag(x));
                set(data.handles.hfig,'userdata',data);
            end
        end
        
        % Vocal tract memory ver 1
        set(data.handles.h0,'xdata',real(x),'ydata',imag(x));
        set(data.handles.h1(1),'xdata',real(xA),'ydata',imag(xA));
        set(data.handles.h1(2),'xdata',real(xB),'ydata',imag(xB));
        if isfield(data, 'reset') && data.reset == 1
            set(data.handles.h0_memory,'xdata',real(x),'ydata',imag(x));
            data.reset = 0;
        end
        % ver 2
        %set(data.handles.h0_memory,'xdata',real(x),'ydata',imag(x));
        %set(data.handles.h1_memory,'xdata',real(x),'ydata',imag(x));
        
        
        % area function
        set(data.handles.h2,'xdata',d*[1:numel(data.state.af) numel(data.state.af):-1:1],'ydata',[max(0,data.state.af(:))'/2, -fliplr(max(0,data.state.af(:))')/2]);
        set(data.handles.hax2,'xlim',d*[.5 numel(data.state.af)+.5],'ylim',max(8,max(data.state.af)/2)*[-1 1]);
        
        % frequency spectrum
        x=10*log10(abs(data.state.filt)); % does this need to be adjusted based on numMainArt?
        calcPeaks = find(x(2:end-1)>x(1:end-2)&x(2:end-1)>x(3:end))*fs/numel(data.state.filt)*1e0; % calc freq peaks
        % trying to integrate diva_synth vals
        audPeaks = round(data.state.Aud(2:end,:));
        combPeaks = [audPeaks;calcPeaks(4:end)];
        h3xdata = (0:numel(data.state.filt)-1)*fs/numel(data.state.filt)*1e0;
        set(data.handles.h3,'xdata',h3xdata,'ydata',x);
        peakIdx = find(x(2:end-1)>x(1:end-2)&x(2:end-1)>x(3:end));
        %peakVals = x(peakIdx+1);
        %f0box = annotation('textbox',[.5,.5,.5,.5],'String',peakVals(1), 'FitBoxToText','on');
        %set(data.handles.h3,'xdata',(0:numel(data.state.filt)-1)*fs/numel(data.state.filt)*1e0,'ydata',x);
        %set(data.handles.hax3,'xlim',[0 min(8000,fs/2)]*1e0,'ylim',[-15 max(15,max(x))],'box','off','xtick',combPeaks);
        set(data.handles.hax3,'xlim',[0 min(4000,fs/2)]*1e0,'ylim',[-15 max(15,max(x))],'box','off','xtick',calcPeaks);
        
        % old code, when basing position on formant position
        %Fpos = cell(3,1);
        %for j = 1:3
        %    Fpos{j} = [(0.58+(peakIdx(j)*0.3/800)),0.065,0.038,0.03]; %orig working pos
        %end
        
        Fpos = {[0.95,0.18,0.038,0.03]; [0.95,0.14,0.038,0.03]; [0.95,0.1,0.038,0.03]; [0.91,0.02,0.078,0.03]};
        
        if data.setup
            % Old ver (uses actual freq val)
            %data.handles.f1txt = uicontrol('Style','edit','Tag','f1txt','String',string(calcPeaks(1)),'Units','norm','FontUnits','norm','FontSize',0.8,'Position', Fpos{1},'Callback', @FboxEdited);
            %set(data.handles.h3F1, 'xdata',[h3xdata(peakIdx(1)),h3xdata(peakIdx(1))],'ydata', [-15 ,15]);
            
            % this version uses audPeaks values which are from
            % data.state.Aud or the diva_synth function
            data.handles.f1txt = uicontrol('Style','text','Tag','f1txt','String','F1:','Units','norm','FontUnits','norm','FontSize',0.8,'Position', [0.91,0.18,0.038,0.03]);
            data.handles.f2txt = uicontrol('Style','text','Tag','f2txt','String','F2:','Units','norm','FontUnits','norm','FontSize',0.8,'Position', [0.91,0.14,0.038,0.03]);
            data.handles.f3txt = uicontrol('Style','text','Tag','f3txt','String','F3:','Units','norm','FontUnits','norm','FontSize',0.8,'Position', [0.91,0.10,0.038,0.03]);
            data.handles.f123apply = uicontrol('Style','pushbutton','Tag','f123apply','String','Apply','Units','norm','FontUnits','norm','FontSize',0.8,'Position', Fpos{4},'visible','off','Callback', @FboxEdited);
            data.handles.f1edit = uicontrol('Style','edit','Tag','f1edit','String',string(audPeaks(1)),'Units','norm','FontUnits','norm','FontSize',0.8,'Position', Fpos{1},'Callback', @(varargin)set(data.handles.f123apply,'visible','on'));
            data.handles.f2edit = uicontrol('Style','edit','Tag','f2edit','String',string(audPeaks(2)),'Units','norm','FontUnits','norm','FontSize',0.8,'Position', Fpos{2},'Callback', @(varargin)set(data.handles.f123apply,'visible','on'));
            data.handles.f3edit = uicontrol('Style','edit','Tag','f3edit','String',string(audPeaks(3)),'Units','norm','FontUnits','norm','FontSize',0.8,'Position', Fpos{3},'Callback', @(varargin)set(data.handles.f123apply,'visible','on'));
            set(data.handles.h3F1, 'xdata',[audPeaks(1),audPeaks(1)],'ydata', [-15 ,15]);
            set(data.handles.h3F2, 'xdata',[audPeaks(2),audPeaks(2)],'ydata', [-15 ,15]);
            set(data.handles.h3F3, 'xdata',[audPeaks(3),audPeaks(3)],'ydata', [-15 ,15]);
            %data.handles.f3txt = uicontrol('Style','edit','Tag','f3txt','String',string(i(4)),'Units','normalized','Position', Fpos{4},'Callback', @FboxEdited);
            data.setup = 0;
            set(data.handles.hfig,'userdata',data);
        else
            % Old ver (uses actual freq val)
            %set(data.handles.f1txt,'String',string(calcPeaks(1)),'Position',Fpos{1});
            %set(data.handles.h3F1, 'xdata',[h3xdata(peakIdx(1)),h3xdata(peakIdx(1))],'ydata', [-15 ,15]);
            
            
            % this version uses audPeaks values which are from
            % data.state.Aud or the diva_synth function
            set(data.handles.f1edit,'String',string(audPeaks(1)),'Position',Fpos{1});
            set(data.handles.f2edit,'String',string(audPeaks(2)),'Position',Fpos{2});
            set(data.handles.f3edit,'String',string(audPeaks(3)),'Position',Fpos{3});
            set(data.handles.f123apply,'visible','off');
            set(data.handles.h3F1, 'xdata',[audPeaks(1),audPeaks(1)],'ydata', [-15 ,15]);
            set(data.handles.h3F2, 'xdata',[audPeaks(2),audPeaks(2)],'ydata', [-15 ,15]);
            set(data.handles.h3F3, 'xdata',[audPeaks(3),audPeaks(3)],'ydata', [-15 ,15]);
            %set(data.handles.f3txt,'String',string(i(4)),'Position',Fpos{4});
        end
        
        % Old play sound method
        %if exist('data', 'var') == 1 && isfield(data, 'ready2play')
        %    if data.ready2play
        %        %if size(data.state.x,2)>1,
        %        [data.state.s,data.state.fs]=diva_synth(data.state.x,'sound');
        %        sound(data.state.s,data.state.fs);
        %        %end
        %    end
        %end
        
        %set(data.handles.hax3,'XTickLabelRotation',45); % rotate x-axis label to avoid overlap
        set(data.handles.hfig,'userdata',data);
        %for n1=1:13,set(data.handles.hslider(n1),'value',data.state.x(n1,n));end
        drawnow;
        %end
end

%     function breakTest(data)
%         [data.state.Aud,data.state.Som,data.state.Outline,data.state.af,data.state.filt]=diva_synth(data.state.x(:,n), 'explicit');
%         
%          if sum(data.state.filt) == 0 % if this is 0, this is a configuration which results in no sound
%              disp('reached breaking point')
%              return
%          end
%    end

    function FboxEdited(ObjH, EventData)
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        % ObjH is the button handle
        %sprintf('%s text box was edited to have %s value',ObjH.Tag,ObjH.String)
        %F0 Limits 257 - 841 (limits work), but based on default as starting ponit
        %turns out the limitsare variable bc it depends on the solveinv
        %output.
        %allF = str2double(data.handles.hax3.XTickLabel);
        allF = [str2double(data.handles.f1edit.String);str2double(data.handles.f2edit.String);str2double(data.handles.f3edit.String)];
        f0 = 100; % may need to derive this based on tension in the future
        data.origF = [f0;allF(1:3)];
        curFtarget = [f0;allF(1:3)];
        curFtarget(1) = nan;
        data.curFtarget = curFtarget;
        origVocalTx = get(data.handles.h0,'xdata');
        origVocalTy = get(data.handles.h0,'ydata');
        data.origVocalT = complex(origVocalTx,origVocalTy);
        data.oldstatex=data.state.x(:,end);
        data.currAxis = 3;
        data.ready2play = 1;
        set(data.handles.hfig,'userdata',data);
        diva_vtdisp(data.handles.hfig,'setslider',data);
    end

    function currAxis = findCurrAxis(currPoint) 
        % Helper function that determines which axis the user clicked on by
        % comparing the location of the pointer to the axes positions
        % currAxis value is based on the axis number: 
        % '1' = vocal tract plot
        % '4' = main articulator bar plot
        % '4b' = glottis articulator bar plot
        % '4c' = constrictor articulator plot
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        xp = currPoint(1);
        yp = currPoint(2);
        mArtPos = data.handles.hax4.Position;
        sArtPos = data.handles.hax4b.Position;
        cArtPos = data.handles.hax4c.Position;
        vCordPos = data.handles.hax1.Position;
        FPos = data.handles.hax3.Position;
        if xp > mArtPos(1) && yp > mArtPos(2) && (xp < (mArtPos(1)+mArtPos(3))) && (yp < (mArtPos(2)+mArtPos(4)))
            currAxis = '4';
        elseif xp > sArtPos(1) && yp > sArtPos(2) && (xp < (sArtPos(1)+sArtPos(3))) && (yp < (sArtPos(2)+sArtPos(4)))
            currAxis = '4b';
        elseif xp > cArtPos(1) && yp > cArtPos(2) && (xp < (cArtPos(1)+cArtPos(3))) && (yp < (cArtPos(2)+cArtPos(4)))
            currAxis = '4c'; 
        elseif xp > FPos(1) && yp > FPos(2) && (xp < (FPos(1)+FPos(3))) && (yp < (FPos(2)+FPos(4)))
            currAxis = '3';
        elseif xp > vCordPos(1) && yp > vCordPos(2) && (xp < (vCordPos(1)+vCordPos(3))) && (yp < (vCordPos(2)+vCordPos(4)))
            currAxis = '1';
        else
            currAxis = '0';
        end
    end

    function resetPushed(PushButton, EventData)
        data.reset = 1;
        data.ready2play = 0;
        set(data.handles.hfig,'userdata',data);
        diva_vtdisp(hfig,'updsliders',[zeros(data.numMainArt,1);0;.5;.5],data);
        diva_vtdisp(data.handles.hfig,'update',[zeros(data.numMainArt,1);0;.5;.5]); % uses 'update' case to initialize default plots
        drawnow;
    end

    function synthPushed(PushButton, EventData)
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata'); 
        if size(data.state.x,2) < 2
            data.state.x=repmat(data.state.x,[1,100]);
        end
        [data.state.s,data.state.fs]=diva_synth(data.state.x,'sound');
        sound(data.state.s,data.state.fs);
        data.ready2play = 0;
        set(data.handles.hfig,'userdata',data);
    end

    function cr8TargetPushed(PushButton, EventData)
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata'); 
        mainFigPos = data.handles.hfig.Position;
        data.handles.cr8Tfig=figure('units','norm','position',[(mainFigPos(1)+mainFigPos(3)) mainFigPos(2) (mainFigPos(3)*0.3) mainFigPos(4)],'menubar','none','name','Create new target','numbertitle','off','color','w','interruptible','on','busyaction','queue');
        data.handles.tNameTxt = uicontrol('Style','text','String','Target name:','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.02,0.96,0.30,0.03], 'Parent', data.handles.cr8Tfig);
        data.handles.tNameBox = uicontrol('Style','edit','String','default_target','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.4,0.96,0.30,0.03], 'Parent', data.handles.cr8Tfig);
        
        labels = diva_vocaltract();
        mArtLabels = labels.Input.Plots_label(2:end);
        mArtHval = 0.92;
        data.handles.mArtTxt = uicontrol('Style','text','String','Motor Articulators:','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.06,0.92,0.60,0.03], 'Parent', data.handles.cr8Tfig);
        mArtHval = mArtHval-0.04;
        for m = 1:data.numMainArt
            data.handles.mArtName(m) = uicontrol('Style','text','String',mArtLabels(m),'Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.02,mArtHval,0.30,0.03], 'Parent', data.handles.cr8Tfig);
            data.handles.mArtMin(m) = uicontrol('Style','edit','String','min','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.34,mArtHval,0.2,0.03], 'Parent', data.handles.cr8Tfig);
            data.handles.mArtBox(m) = uicontrol('Style','edit','String','cur val','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.56,mArtHval,0.20,0.03], 'Parent', data.handles.cr8Tfig);
            data.handles.mArtMax(m) = uicontrol('Style','edit','String','max','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.78,mArtHval,0.20,0.03], 'Parent', data.handles.cr8Tfig);
        mArtHval = mArtHval-0.035;
        end
        
        gArtHval = mArtHval-0.005;
        gArtLabels = {'Tension', 'Pressure', 'Voicing'};
        data.handles.gArtTxt = uicontrol('Style','text','String','Glottis:','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.06,gArtHval,0.60,0.03], 'Parent', data.handles.cr8Tfig);
        gArtHval = gArtHval-0.035;
        for g = 1:(data.numSuppArt-data.numMainArt)
            data.handles.gArtName(g) = uicontrol('Style','text','String',gArtLabels(g),'Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.02,gArtHval,0.30,0.03], 'Parent', data.handles.cr8Tfig);
            data.handles.gArtMin(g) = uicontrol('Style','edit','String','min','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.34,gArtHval,0.2,0.03], 'Parent', data.handles.cr8Tfig);
            data.handles.gArtBox(g) = uicontrol('Style','edit','String','cur val','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.56,gArtHval,0.20,0.03], 'Parent', data.handles.cr8Tfig);
            data.handles.gArtMax(g) = uicontrol('Style','edit','String','max','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.78,gArtHval,0.20,0.03], 'Parent', data.handles.cr8Tfig);
            gArtHval = gArtHval - 0.035;
        end
        
        cArtHval = gArtHval-0.005;
        cArtLabels = labels.Output(2).Plots_label(4:end);
        data.handles.cArtTxt = uicontrol('Style','text','String','Constrictions:','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.06,cArtHval,0.60,0.03], 'Parent', data.handles.cr8Tfig);
        cArtHval = cArtHval-0.035;
        for c = 1:(data.numConstArt-data.numSuppArt)
            data.handles.cArtName(c) = uicontrol('Style','text','String',cArtLabels(g),'Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.02,cArtHval,0.30,0.03], 'Parent', data.handles.cr8Tfig);
            data.handles.cArtMin(c) = uicontrol('Style','edit','String','min','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.34,cArtHval,0.2,0.03], 'Parent', data.handles.cr8Tfig);
            data.handles.cArtBox(c) = uicontrol('Style','edit','String','cur val','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.56,cArtHval,0.20,0.03], 'Parent', data.handles.cr8Tfig);
            data.handles.cArtMax(c) = uicontrol('Style','edit','String','max','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.78,cArtHval,0.20,0.03], 'Parent', data.handles.cr8Tfig);
            cArtHval = cArtHval - 0.035;
        end
        
        formantHval = cArtHval-0.005;
        formantLabels = {'F1','F2','F3'};
        data.handles.formantTxt = uicontrol('Style','text','String','Formants:','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.06,formantHval,0.60,0.03], 'Parent', data.handles.cr8Tfig);
        formantHval = formantHval-0.035;
        for f = 1:3
            data.handles.formantName(f) = uicontrol('Style','text','String',formantLabels(f),'Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.02,formantHval,0.30,0.03], 'Parent', data.handles.cr8Tfig);
            data.handles.formantMin(f) = uicontrol('Style','edit','String','min','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.34,formantHval,0.2,0.03], 'Parent', data.handles.cr8Tfig);
            data.handles.formantBox(f) = uicontrol('Style','edit','String','cur val','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.56,formantHval,0.20,0.03], 'Parent', data.handles.cr8Tfig);
            data.handles.formantMax(f) = uicontrol('Style','edit','String','max','Units','norm','FontUnits','norm','FontSize',0.65,'Position',[0.78,formantHval,0.20,0.03], 'Parent', data.handles.cr8Tfig);
            formantHval = formantHval - 0.035;
        end
        
        
        
        
        set(data.handles.hfig,'userdata',data);
    end


    function downcallback(varargin)
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');  
        if isfield(data, 'curBar')
            data = rmfield(data,'curBar');
        end
        if isfield(data, 'constTarget')
            data = rmfield(data,'constTarget');
        end
        if isfield(data, 'vCordPos')
            data = rmfield(data,'vCordPos'); % remove vCord var so that GUI doesn't always assume you are changing the vocal cord
        end
        if isfield(data, 'newVocalT')
            data = rmfield(data,'newVocalT');
        end
        if isfield(data, 'curFtarget')
            data = rmfield(data,'curFtarget');
        end
        if isfield(data, 'curFpoint')
            data = rmfield(data,'curFpoint');
        end
        set(hfig,'userdata',data);
        currPoint = get(data.handles.hfig,'currentpoint');
        currAxis = findCurrAxis(currPoint);
        mArtPos=get(data.handles.hax4,'currentpoint');  % get current point rel to axes [x y -; x y -] for main articulators
        sArtPos=get(data.handles.hax4b,'currentpoint'); % for glottal articulators
        cArtPos=get(data.handles.hax4c,'currentpoint'); % for constrictor articulators
        FPos=get(data.handles.hax3,'currentpoint'); % for formant plot
        vCordPos=get(data.handles.hax1,'currentpoint'); % for vocal tract
        % Current point 'pos' is structured as such [xfront, yfront, zfront;xback, yback, zback]
        % Instead of looking though fields for specific data var, should
        % just look at the newly implemented 'currAxis'
        if strcmp(currAxis, '4c') % const articulators
            data.curBar = round(cArtPos(1,2));
        elseif strcmp(currAxis, '4b') % supp articulators
            data.curBar = round(sArtPos(1,2));
        elseif  strcmp(currAxis, '4') % main articulators
            data.curBar = round(mArtPos(1,2));
        elseif strcmp(currAxis, '3') % formant plot
            % need to determine which formant clicked
            data.curFval = round(FPos(1));
            data.curFpoint = FPos;
            origF = [str2double(data.handles.f1edit.String);str2double(data.handles.f2edit.String);str2double(data.handles.f3edit.String)];
            [~,data.curFidx] = min(abs(origF-data.curFpoint(1))); % decide which formant to track only when mouse is clicked
            set(data.handles.mousepos2,'xdata',[FPos(1,1) FPos(1,1)],'ydata',[FPos(1,2) FPos(1,2)]);
        elseif strcmp(currAxis, '1') % vocal tract plot
            data.vCordPos = vCordPos(1,1:2);
            set(data.handles.mousepos1,'xdata',[vCordPos(1,1) vCordPos(1,1)],'ydata',[vCordPos(1,2) vCordPos(1,2)]);
        else
        end
        %curBarIdx = round(pos2(1));
        %curBarIdx = round(pos2(1,2));
        %data.curBar = curBarIdx;
        f0 = 100; % may need to derive this based on tension in the future    
        %origF = get(data.handles.hax3,'XTickLabel'); % get original set of formants
        origF = [str2double(data.handles.f1edit.String);str2double(data.handles.f2edit.String);str2double(data.handles.f3edit.String)];
        origF = [f0;str2double(origF(1:3))];
        data.origF = origF;
        % want to store the original position of vocal tract before any
        % dragging
        origVocalTx = get(data.handles.h0,'xdata');
        origVocalTy = get(data.handles.h0,'ydata');
        data.origVocalT = complex(origVocalTx,origVocalTy);
        data.oldstatex=data.state.x(:,end);
        data.currAxis = currAxis;
        data.mouseIsDown = true; % recognizes / saves the fact that the mouse is pressed down
        data.ready2play = false;
        set(data.handles.hfig,'userdata',data);
    end

    function upcallback(varargin)
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        data.mouseIsDown = false;% recognizes / saves the fact that the mous has been let go
        set(hfig,'userdata',data);
        if isfield(data, 'curBar')
            if data.curBar > data.numSuppArt
                data.handles.hplot4c.CData(data.curBar-data.numSuppArt,:) = [0 0.4470 0.7410];
            elseif data.curBar > data.numMainArt
                data.handles.hplot4b.CData(data.curBar-data.numMainArt,:) = [0 0.4470 0.7410];
            else
                 data.handles.hplot4.CData(data.curBar,:) = [0 0.4470 0.7410];
            end
            % NOTE: just doing set(data.handles.hplot4, 'CData', [0 0.4470
            % 0.7410]) will stop indiv bars from haveing their own CData.
            set(data.handles.hfig,'userdata',data);
            drawnow;
        end
        if isfield(data, 'curFpoint')
            set(data.handles.h3F1, 'color', 'k');
            set(data.handles.h3F2, 'color', 'k');
            set(data.handles.h3F3, 'color', 'k');
            set(data.handles.hfig,'userdata',data);
            data = rmfield(data,'curFpoint');
            drawnow;
        end
        % could add a block here to turn the appropriate formant cyan?
        if isfield(data, 'vCordPos')
            data = rmfield(data,'vCordPos'); % remove vCord var so that GUI doesn't always assume you are changing the vocal cord
        end
        set([data.handles.mousepos1,data.handles.mousepos2],'xdata',[],'ydata',[]);
        data.ready2play = true;
        set(data.handles.hfig,'userdata',data);
        diva_vtdisp(data.handles.hfig,'setslider',data);
        % old
        %diva_vtdisp(data.handles.hfig,'setslider',data);
    end

    function overcallback(varargin)    % for when mouse hovers over plot
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        if isfield(data, 'mouseIsDown')
            if data.mouseIsDown
                %p1=get(0,'pointerlocation');    % get mouse location [x y]
                %p2=get(data.hfig,'position');   % get position of figure [x y w h]
                %pos=p1-p2(1:2); % find mouse position relative to figure
                %set(data.hfig,'currentpoint',pos); % not sure
                
                % handling vocal tract plot clicks
                if isfield(data, 'vCordPos')
                    newPos = get(data.handles.hax1,'currentpoint');
                    txdata=[get(data.handles.mousepos1,'xdata') newPos(1,1)];tydata=[get(data.handles.mousepos1,'ydata') newPos(1,2)];set(data.handles.mousepos1,'xdata',txdata([1 end]),'ydata',tydata([1 end]));
                    xdata = data.handles.h0.XData;
                    ydata = data.handles.h0.YData;
                    distances = sqrt((data.vCordPos(1)-xdata).^2+(data.vCordPos(2)-ydata).^2);
                    [minValue, minIndex] = min(distances);
                    %hold on; plot(xdata(minIndex),ydata(minIndex),'ro'); hold off; % plot nearest index point
                    newx = xdata;
                    newy = ydata;
                    newx(minIndex) = newPos(1,1);
                    newy(minIndex) = newPos(1,2);
                    %hold on; plot(newPos(1,1),newPos(1,2),'bo'); hold off; % plot clicked point
                    newVocalT = complex(newx,newy).'; % this is essentially the 'Outline' var or y' I need
                    newVocalT(1:minIndex-1)=nan;
                    newVocalT(minIndex+1:end)=nan;
                    data.newVocalT = newVocalT(1:end-1,:);
                    %data.oldVocalT = [newx(1:end-1) newy(1:end-1)]; % previous point, but during the drag
                    data.oldVocalT = data.origVocalT(1:end-1,:);     % vocalT at the start of the drag
                    data.ready2play = false;
                    set(data.handles.hfig,'userdata',data);
                    diva_vtdisp(data.handles.hfig,'setslider',data);
                end
                
                % handling frequency plot clicks
                if isfield(data, 'curFpoint')
                    newPos = get(data.handles.hax3,'currentpoint');
                    txdata=[get(data.handles.mousepos2,'xdata') newPos(1,1)];tydata=[get(data.handles.mousepos2,'ydata') newPos(1,2)];set(data.handles.mousepos2,'xdata',txdata([1 end]),'ydata',tydata([1 end]));
                    %xdata = data.handles.h3.XData;  % get formant plot data
                    %ydata = data.handles.h3.YData;  % get formant plot data
                    %distances = sqrt((data.curFpoint(1)-xdata).^2+(data.curFpoint(2)-ydata).^2);
                    %[minValue, minIndex] = min(distances);
                    
                    fLim = max(data.handles.hax3.XLim);
                        if newPos(1,1) <= fLim && newPos(1,1) > 0
                            data.curFval = newPos(1,1); % new chosen formant freq val
                            %[pks, locs] = findpeaks(data.handles.h3.YData);
                            %newx = xdata;
                            %newy = ydata;
                            %newx(minIndex) = newPos(1,1);
                            %newy(minIndex) = newPos(1,2);
                            %data.handles.h3.XData = newx; 
                            %data.handles.h3.YData = newy; 
                            
                            %availableF = str2double(data.handles.hax3.XTickLabel);
                            availableF = [str2double(data.handles.f1edit.String);str2double(data.handles.f2edit.String);str2double(data.handles.f3edit.String)];
                            %[~,curFidx] = min(abs(availableF-data.curFpoint(1)));
                            set([data.handles.h3F1,data.handles.h3F2,data.handles.h3F3], 'color', 'k');
                            switch data.curFidx
                                case 1
                                    set(data.handles.h3F1, 'color', 'c');
                                case 2
                                    set(data.handles.h3F2, 'color', 'c');
                                case 3
                                    set(data.handles.h3F3, 'color', 'c');
                            end
                            curFidx = data.curFidx+1; % add 1 to pass f0
                            f0 = 100; % may need to derive this based on tension in the future
                            curFtarget = [f0;availableF(1:3)];
                            curFtarget(1:curFidx-1) = nan;
                            curFtarget(curFidx+1:end) = nan;
                            curFtarget(curFidx) = newPos(1,1);
                            data.curFtarget = curFtarget;               
                            
                            % pass on data to next part of GUI
                            data.ready2play = false;
                            set(data.handles.hfig,'userdata',data);
                            diva_vtdisp(data.handles.hfig,'setslider',data);
                            drawnow;
                        end
                end
                
                % handling articulator plot clicks
                if isfield(data, 'curBar')
                    if data.curBar > data.numSuppArt
                    pos=get(data.handles.hax4c,'currentpoint');
                        data.handles.hplot4c.CData(data.curBar-data.numSuppArt,:) = [0 0.8 0.8];
                        barLim = max(data.handles.hplot4c.XData);
                        if data.curBar <= barLim && data.curBar > data.numSuppArt+0.5 && pos(1) >=-1.005 && pos(1) <=1.005
                            data.curBarVal = pos(1);
                            ydata = data.handles.hplot4c.YData;  % get bar plot y data
                            newY = ydata;
                            newY(data.curBar-data.numSuppArt) = pos(1);
                            %disp(pos2(1,2));
                            data.handles.hplot4c.YData = newY;
                            data.handles.hplot5c.XData = newY;
                            for k = 1:(data.numConstArt - data.numSuppArt)
                                set(data.handles.h4ctext(k),'String', round(newY(k),2,'significant'));
                                if newY(k) > 0
                                    if newY(k) > 0.5
                                        set(data.handles.h4ctext(k),'horiz','right','Position', [newY(k)-0.1,k+data.numSuppArt,0],'Color', 'White');
                                    else
                                        set(data.handles.h4ctext(k),'horiz','left','Position', [newY(k)+0.1,k+data.numSuppArt,0],'Color', 'Black');
                                    end
                                else
                                    if newY(k) < -0.5
                                        set(data.handles.h4ctext(k),'horiz','left','Position', [newY(k)+0.1,k+data.numSuppArt,0],'Color', 'White');
                                    else
                                        set(data.handles.h4ctext(k),'horiz','right','Position', [newY(k)-0.1,k+data.numSuppArt,0],'Color', 'Black');
                                    end
                                end
                            end
                            barIdx = data.curBar-data.numSuppArt;
                            constTarget = [newY data.handles.hplot4b.YData(end-1:end)]; % constrictor vals + last two glottis vals (voicing and pressure)
                            constTarget(1:barIdx-1) = nan;
                            constTarget(barIdx+1:end) = nan;
                            data.constTarget = constTarget';
                            data.ready2play = false;
                            set(data.handles.hfig,'userdata',data);
                            diva_vtdisp(data.handles.hfig,'setslider',data);
                            drawnow;
                        end
                    elseif data.curBar > data.numMainArt
                        pos=get(data.handles.hax4b,'currentpoint');
                        data.handles.hplot4b.CData(data.curBar-data.numMainArt,:) = [0 0.8 0.8];
                        barLim = max(data.handles.hplot4b.XData);
                        if data.curBar <= barLim && data.curBar > data.numMainArt+0.5 && pos(1) >=-1.005 && pos(1) <=1.005
                            %data.curBar = curBarIdx;
                            data.curBarVal = pos(1);
                            ydata = data.handles.hplot4b.YData;  % get bar plot y data
                            newY = ydata;
                            newY(data.curBar-data.numMainArt) = pos(1);
                            %disp(pos2(1,2));
                            data.handles.hplot4b.YData = newY;
                            data.handles.hplot5b.XData = newY;
                            for k = 1:(data.numSuppArt - data.numMainArt)
                                set(data.handles.h4btext(k),'String', round(newY(k),2,'significant'));
                                if newY(k) > 0
                                    if newY(k) > 0.5
                                        set(data.handles.h4btext(k),'horiz','right','Position', [newY(k)-0.1,k+data.numMainArt,0],'Color', 'White');
                                    else
                                        set(data.handles.h4btext(k),'horiz','left','Position', [newY(k)+0.1,k+data.numMainArt,0],'Color', 'Black');
                                    end
                                else
                                    if newY(k) < -0.5
                                        set(data.handles.h4btext(k),'horiz','left','Position', [newY(k)+0.1,k+data.numMainArt,0],'Color', 'White');
                                    else
                                        set(data.handles.h4btext(k),'horiz','right','Position', [newY(k)-0.1,k+data.numMainArt,0],'Color', 'Black');
                                    end
                                end
                            end
                            data.ready2play = false;
                            set(data.handles.hfig,'userdata',data);
                            diva_vtdisp(data.handles.hfig,'setslider',data);
                            drawnow;
                        end
                    else
                        pos=get(data.handles.hax4,'currentpoint'); % get current point rel to axes [x y -; x y -]
                        data.handles.hplot4.CData(data.curBar,:) = [0 0.8 0.8];
                        barLim = max(data.handles.hplot4.XData);
                        %if curBarIdx <= barLim && curBarIdx > 0.5 && pos2(1,2) >= -3 && pos2(1,2) <= 3
                        if data.curBar <= barLim && data.curBar > 0.5 && pos(1) >=-1.005 && pos(1) <=1.005
                            %data.curBar = curBarIdx;
                            data.curBarVal = pos(1);
                            ydata = data.handles.hplot4.YData;
                            newY = ydata;
                            %newY(curBarIdx) = pos2(1,2);
                            newY(data.curBar) = pos(1);
                            %disp(pos2(1,2));
                            data.handles.hplot4.YData = newY;
                            data.handles.hplot5.XData = newY;
                            for k = 1:data.numMainArt
                                set(data.handles.h4text(k),'String', round(newY(k),3,'significant'));
                                if newY(k) > 0
                                    if newY(k) > 0.5
                                        set(data.handles.h4text(k),'horiz','right','Position', [newY(k)-0.1,k,0], 'Color', 'White');
                                    else
                                        set(data.handles.h4text(k),'horiz','left','Position', [newY(k)+0.1,k,0],'Color', 'Black');
                                    end
                                else
                                    if newY(k) < -0.5
                                        set(data.handles.h4text(k),'horiz','left','Position', [newY(k)+0.1,k,0],'Color', 'White');
                                    else
                                        set(data.handles.h4text(k),'horiz','right','Position', [newY(k)-0.1,k,0],'Color', 'Black');
                                    end
                                end
                            end
                            %for k = 1:10
                            %    data.handles.h4text(k).Position = [ newY(k) k 0 ];
                            %end
                            data.ready2play = false;
                            set(data.handles.hfig,'userdata',data);
                            diva_vtdisp(data.handles.hfig,'setslider',data);
                            drawnow;
                        end
                    end
                end
            end
        end
    end
end
