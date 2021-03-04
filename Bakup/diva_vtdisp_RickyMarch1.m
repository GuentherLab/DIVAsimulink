function varargout=diva_vtdisp_Ricky(option,varargin)

if ~nargin||isempty(option), option='init'; end
hfig=[];
if ishandle(option), hfig=option; option=varargin{1}; varargin=varargin(2:end); end

switch(lower(option))
    case 'init'
        %data.state.x=zeros(13,1);
        %[data.state.y,data.state.z,data.state.Outline]=diva_synth(data.state.x);
        
        % setting up figure
        data.handles.hfig=figure('units','norm','position',[.3 .5 .4 .4],'menubar','none','name','DIVA vocal tract display','numbertitle','off','color','w');
        
        % setting up 2D vocal tract
        %data.handles.hax1=axes('units','norm','position',[.05 .3 .45 .65],'color',1*[1 1 1]);
        data.handles.hax1=axes('units','norm','position',[0 .3 .45 .65],'color',1*[1 1 1]);
        
        % memory first (h0 is outline, h1 is fill)
        % ver1 solid moving, dotted fixed
        % ver2 is the opposite
        data.handles.h1_memory=patch(nan,nan,'k','facecolor',.85*[1 1 1],'linestyle','--','edgecolor','none','linewidth',2,'parent',data.handles.hax1);
        % regular 2D representation
        data.handles.h1=patch(nan,nan,'k','facecolor',.85*[1 1 1],'edgecolor','none','linewidth',2,'parent',data.handles.hax1);
        hold(data.handles.hax1,'on'); data.handles.h0=plot(nan,nan,'k','linewidth',2,'parent',data.handles.hax1); hold(data.handles.hax1,'off');
        hold(data.handles.hax1,'on'); data.handles.h0_memory=plot(nan,nan,'k','linestyle',':','linewidth',2,'parent',data.handles.hax1); hold(data.handles.hax1,'off');
        
        axis(data.handles.hax1,'equal','tight');
        set(data.handles.hax1,'xcolor','w','ycolor','w','xtick',[],'ytick',[],'xdir','reverse');
        %set(data.handles.h1,'xdata',real(data.state.Outline),'ydata',imag(data.state.Outline));
        
        % setting up supplementary plots for 2D vocal tract vocalization
        data.handles.hax1a=axes('units','norm','position',[.36 .3 .04 .65]);
        data.handles.hax1b=axes('units','norm','position',[.40 .3 .04 .65]);
        data.handles.hax1c=axes('units','norm','position',[.44 .3 .04 .65]);
        % arc plot data
        t = linspace(150, 210, 100); t2 = linspace(135, 225, 100); t3 = linspace(120, 240, 100);
        x  = 3 * cosd(t);y  = 3 * sind(t);x2 = 4 * cosd(t2);y2 = 4 * sind(t2);x3 = 5 * cosd(t3);y3 = 5 * sind(t3);
        data.handles.h1a = plot(-x+2, -y, 'k-', 'LineWidth', 4, 'parent', data.handles.hax1a,'visible', 'on');
        data.handles.h1b = plot(-x2, -y2, 'k-', 'LineWidth', 4, 'parent', data.handles.hax1b,'visible', 'off');
        data.handles.h1c = plot(-x3, -y3, 'k-', 'LineWidth', 4, 'parent', data.handles.hax1c,'visible', 'off');
        set(data.handles.hax1a, 'YLim', [-4 4], 'XLim', [4.5 5]); set(data.handles.hax1b, 'YLim', [-4 4], 'XLim', [3.3 4]); set(data.handles.hax1c, 'YLim', [-6 6], 'XLim', [3.0 5]);
        set(data.handles.hax1a,'box','off','xtick',[],'ytick',[], 'visible', 'off'); set(data.handles.hax1b,'box','off','xtick',[],'ytick',[], 'visible', 'off'); set(data.handles.hax1c,'box','off','xtick',[],'ytick',[], 'visible', 'off');
        
        % plotting area function
        data.handles.hax2=axes('units','norm','position',[.1 .1 .3 .15],'color',.85*[1 1 1]);
        data.handles.h2=patch(nan,nan,'k','facecolor',1*[1 1 1],'edgecolor','k','linewidth',2,'parent',data.handles.hax2);
        xlabel(data.handles.hax2,'distance to glottis (cm)'); ylabel(data.handles.hax2,'Area (cm^2)');
        % plotting frequency spectrum
        data.handles.hax3=axes('units','norm','position',[.6 .1 .3 .15],'box','off');
        data.handles.h3=plot(nan,nan,'k','color','k','linewidth',2,'parent',data.handles.hax3);
        %hold on; data.handles.h6=plot(nan,nan,'co','markerfacecolor','c'); hold off; If I wanted to add cyan markers on the plot 
        xlabel(data.handles.hax3,'Frequency (Hz)');
        ylabel(data.handles.hax3,'VT filter (dB)');
        
        % plotting vert 'bar-sliders'
        %data.handles.hax4 = axes('units','norm','position',[.525 .325 .45 .625]);
        %data.handles.hplot4 = bar(zeros(1,13)); % psst you need to plot the bar first, before changing the axes properties
        %data.handles.hax4.YLimMode = 'manual';  % or else it'll just change the Ylim properties to be the default for bar plots!!
        %data.handles.hax4.YLim = [-1 1];        % used to be -3 to 3, but that seemed excessive....
        %data.handles.hplot4.FaceColor = 'flat';
        %data.handles.hplot4 = bar(-3+(3+3)*rand(1,13));
        
        % plotting new horizontal  'bar-sliders'
        % main articulators (1-10)
        %data.handles.hax4 = axes('units','norm','position',[.525 .325 .45 .625]);
        data.handles.hax4 = axes('units','norm','position',[.525 .325 .25 .625]);
        data.handles.hplot4 = barh(zeros(1,10), 'BarWidth', 0.8); % psst you need to plot the bar first, before changing the axes properties
        hold on; data.handles.hplot5=plot(zeros(10,1),1:10,'ko','markerfacecolor','k'); hold off
        labels = diva_vocaltract();
        data.handles.hplot4.FaceColor = 'flat';
        set(data.handles.hax4, 'YLimMode', 'manual', 'YLim', [0.5 10.5], 'XLimMode', 'manual', 'XLim', [-1 1], 'YDir', 'reverse');
        set(data.handles.hax4, 'YTickLabel', labels.Input.Plots_label(2:11));
        %set(data.handles.hax4,'ButtonDownFcn',@mArtdowncallback);
        %set(data.handles.hax4, 'YAxisLocation', 'origin');
        
        % extra articulators (11-13)
        data.handles.hax4b = axes('units','norm','position',[.825 .325 .15 .625]);
        data.handles.hplot4b = bar([11:1:13],[0 .5 .5], 'BarWidth', 0.7); % psst you need to plot the bar first, before changing the axes properties
        hold on; data.handles.hplot5b=plot(11:13,[0 .5 .5],'ko','markerfacecolor','k'); hold off
        data.handles.hplot4b.FaceColor = 'flat';
        set(data.handles.hax4b, 'YLimMode', 'manual', 'YLim', [-1 1], 'XLimMode', 'manual', 'XLim', [10.5 13.5], 'XTickMode', 'manual', 'XTickLabel', {'tension','pressure','voicing'}, 'XTickLabelRotation',45);
        
        set(data.handles.hfig,'WindowButtonDownFcn',@downcallback, 'WindowButtonUpFcn',@upcallback, 'WindowButtonMotionFcn',@overcallback); % callback for when mouse hovers over plot
        
        %for n1=1:13 % this is where the sliders are created, need to replace these with bars (for now)
        %    data.handles.hslider(n1)=uicontrol('units','norm','position',[.6 .90-(n1-1)*.05 .3 .05],'style','slider','min',-3,'max',3,'callback',@(varargin)diva_vtdisp(data.handles.hfig,'setslider',n1));
        %end
        
        % flag for first time setup
        data.setup = 1;
        set(data.handles.hfig,'userdata',data);
        diva_vtdisp_Ricky(data.handles.hfig,'update',[zeros(10,1);0;.5;.5]); % uses 'update' case to initialize default plots
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
        catch, x=zeros(13,1);
        end
        
        if isfield(data, 'newVocalT')
            x=diva_solveinv(x,data.newVocalT,'outline','lambda',0.02,'center',data.oldVocalT);
            x=max(-1,min(1,x));
            %diva_vtdisp_Ricky(hfig,'test',x,stateData);
            diva_vtdisp_Ricky(hfig,'updsliders',x,data);
            data = rmfield(data,'newVocalT'); % remove vCord var so that GUI doesn't always assume you are changing the vocal cord
        end
        if isfield(data, 'curFtarget')
            x=diva_solveinv(x,data.curFtarget,'formant','lambda',0.02);
            %x=diva_solveinv(x,data.curFtarget,'formant','center',data.origF);
            x=max(-1,min(1,x));
            %diva_vtdisp_Ricky(hfig,'test',x,stateData);
            diva_vtdisp_Ricky(hfig,'updsliders',x,data);
            data = rmfield(data,'curFtarget'); % remove vCord var so that GUI doesn't always assume you are changing the vocal cord
        end
        x=repmat(x,[1,100]);
        if (data.currAxis == '4') | (data.currAxis == '4b')
            x(n,:)=[linspace(x(n,1),v,20),repmat(v,1,80)]; % for cases where articulator slides are being changed
        end 
        diva_vtdisp_Ricky(hfig,'update',x,data);
        
        %     case 'test'
        %         %clf;
        %         data=get(hfig,'userdata');
        %         [Aud,Som,Outline]=diva_synth(varargin{1},'explicit');
        %         set(data.handles.h1,'xdata',real(Outline),'ydata',imag(Outline));
        %         hold on; plot(Outline,'.-'); hold off; axis equal off;
        
    case 'updsliders'
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        %stateData = varargin{2};
        %x = varargin{1};
        newVals = varargin{1}';
        % for main articulators
        set(data.handles.hplot4, 'YData', newVals(1:10));
        set(data.handles.hplot5, 'XData', newVals(1:10));
        % for supp articulators
        set(data.handles.hplot4b, 'YData', newVals(11:13));
        set(data.handles.hplot5b, 'YData', newVals(11:13));
        set(data.handles.hfig,'userdata',data);
        
    case 'update'
        %if numel(varargin)> 1
        %    stateData = varargin{2};
        %end
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        data.state.x=varargin{1};
        
        % vocalization display
        if exist('data', 'var') == 1 && isfield(data, 'curBar')
            if data.curBar == 13
                if data.curBarVal >= 0.6
                    set(data.handles.h1a, 'visible', 'on');
                    set(data.handles.h1b, 'visible', 'on');
                    set(data.handles.h1c, 'visible', 'on');
                    set(data.handles.hfig,'userdata',data);
                elseif data.curBarVal >= 0.3
                    set(data.handles.h1a, 'visible', 'on');
                    set(data.handles.h1b, 'visible', 'on');
                    set(data.handles.h1c, 'visible', 'off');
                    set(data.handles.hfig,'userdata',data);
                elseif data.curBarVal >= 0
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
        
        d=1.0*.75/10;
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
         if sum(data.state.filt) == 0 % if this is 0, this is a configuration which results in no sound
             disp('reached breaking point')
             return
         end
        
        % vocal tract configuration
        x=data.state.Outline;
        x(end+1)=x(1);
        
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
        set(data.handles.h1,'xdata',real(x),'ydata',imag(x));
        % ver 2
        %set(data.handles.h0_memory,'xdata',real(x),'ydata',imag(x));
        %set(data.handles.h1_memory,'xdata',real(x),'ydata',imag(x));
        
        
        % area function
        set(data.handles.h2,'xdata',d*[1:numel(data.state.af) numel(data.state.af):-1:1],'ydata',[max(0,data.state.af(:))'/2, -fliplr(max(0,data.state.af(:))')/2]);
        set(data.handles.hax2,'xlim',d*[.5 numel(data.state.af)+.5],'ylim',max(8,max(data.state.af)/2)*[-1 1]);
        
        % frequency spectrum
        x=10*log10(abs(data.state.filt));
        calcPeaks = find(x(2:end-1)>x(1:end-2)&x(2:end-1)>x(3:end))*fs/numel(data.state.filt)*1e0; % calc freq peaks
        audPeaks = round(data.state.Aud(2:end,:));
        combPeaks = [audPeaks;calcPeaks(4:end)];
        h3xdata = (0:numel(data.state.filt)-1)*fs/numel(data.state.filt)*1e0;
        set(data.handles.h3,'xdata',h3xdata,'ydata',x);
        peakIdx = find(x(2:end-1)>x(1:end-2)&x(2:end-1)>x(3:end));
        peakVals = x(peakIdx+1);
        %f0box = annotation('textbox',[.5,.5,.5,.5],'String',peakVals(1), 'FitBoxToText','on');
        %set(data.handles.h3,'xdata',(0:numel(data.state.filt)-1)*fs/numel(data.state.filt)*1e0,'ydata',x);
        set(data.handles.hax3,'xlim',[0 min(8000,fs/2)]*1e0,'ylim',[-15 max(15,max(x))],'box','off','xtick',combPeaks);
        %set(data.handles.h6, 'XData', i, 'YData', peakVals); If I wanted to add markers on each peak
        % figure out position of each Formant txt box       
        Fpos = cell(3);
        for j = 1:3
            Fpos{j} = [(0.58+(peakIdx(j)*0.3/800)),0.065,0.038,0.03];       
        end
        if data.setup
            data.handles.f0txt = uicontrol('Style','edit','Tag','f0txt','String',string(audPeaks(1)),'Units','normalized','Position', Fpos{1},'Callback', @FboxEdited); 
            data.handles.f1txt = uicontrol('Style','edit','Tag','f1txt','String',string(audPeaks(2)),'Units','normalized','Position', Fpos{2},'Callback', @FboxEdited);
            data.handles.f2txt = uicontrol('Style','edit','Tag','f2txt','String',string(audPeaks(3)),'Units','normalized','Position', Fpos{3},'Callback', @FboxEdited);
            %data.handles.f3txt = uicontrol('Style','edit','Tag','f3txt','String',string(i(4)),'Units','normalized','Position', Fpos{4},'Callback', @FboxEdited);
            data.setup = 0;
            set(data.handles.hfig,'userdata',data);
        else
            set(data.handles.f0txt,'String',string(audPeaks(1)),'Position',Fpos{1});
            set(data.handles.f1txt,'String',string(audPeaks(2)),'Position',Fpos{2});
            set(data.handles.f2txt,'String',string(audPeaks(3)),'Position',Fpos{3});
            %set(data.handles.f3txt,'String',string(i(4)),'Position',Fpos{4}); 
        end
        
        if exist('data', 'var') == 1 && isfield(data, 'ready2play')
            if data.ready2play
                %if size(data.state.x,2)>1,
                [data.state.s,data.state.fs]=diva_synth(data.state.x,'sound');
                sound(data.state.s,data.state.fs);
                %end
            end
        end
        
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
    end

    function FboxEdited(ObjH, EventData)
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        % ObjH is the button handle
        sprintf('%s text box was edited to have %s value',ObjH.Tag,ObjH.String)
        %F0 Limits 257 - 841 (limits work), but based on default as starting ponit
        %turns out the limitsare variable bc it depends on the solveinv
        %output.
        switch ObjH.Tag
            case 'f0txt'
                currFidx = 2;
            case 'f1txt'
                currFidx = 3;
            case 'f2txt'
                currFidx = 4;
           %case 'f3txt'
           %currFidx = 4;
        end
        allF = str2double(data.handles.hax3.XTickLabel);
        f0 = 100; % may need to derive this based on tension in the future
        data.origF = [f0;allF(1:3)];
        curFtarget = [f0;allF(1:3)];
        curFtarget(currFidx) = str2double(ObjH.String);
        curFtarget(1:currFidx-1) = nan;
        curFtarget(currFidx+1:end) = nan;
        data.curFtarget = curFtarget;
        data.currAxis = 3;
        data.ready2play = 1;
        set(data.handles.hfig,'userdata',data);
        diva_vtdisp_Ricky(data.handles.hfig,'setslider',data);
    end

    function currAxis = findCurrAxis(currPoint) 
        % Helper function that determines which axis the user clicked on by
        % comparing the location of the pointer to the axes positions
        % currAxis value is based on the axis number: 
        % '1' = vocal tract plot
        % '4' = main articulator bar plot
        % '4b' = supplementary articulator bar plot
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        xp = currPoint(1);
        yp = currPoint(2);
        mArtPos = data.handles.hax4.Position;
        sArtPos = data.handles.hax4b.Position;
        vCordPos = data.handles.hax1.Position;
        FPos = data.handles.hax3.Position;
        if xp > mArtPos(1) && yp > mArtPos(2) && (xp < (mArtPos(1)+mArtPos(3))) && (yp < (mArtPos(2)+mArtPos(4)))
            currAxis = '4';
        elseif xp > sArtPos(1) && yp > sArtPos(2) && (xp < (sArtPos(1)+sArtPos(3))) && (yp < (sArtPos(2)+sArtPos(4)))
            currAxis = '4b';
        elseif xp > FPos(1) && yp > FPos(2) && (xp < (FPos(1)+FPos(3))) && (yp < (FPos(2)+FPos(4)))
            currAxis = '3';
        elseif xp > vCordPos(1) && yp > vCordPos(2) && (xp < (vCordPos(1)+vCordPos(3))) && (yp < (vCordPos(2)+vCordPos(4)))
            currAxis = '1';
        else
            currAxis = '0';
        end
    end

    function downcallback(varargin)
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');  
        currPoint = get(data.handles.hfig,'currentpoint');
        currAxis = findCurrAxis(currPoint);
        mArtPos=get(data.handles.hax4,'currentpoint');  % get current point rel to axes [x y -; x y -] for main articulators
        sArtPos=get(data.handles.hax4b,'currentpoint'); % for additional articulators
        FPos=get(data.handles.hax3,'currentpoint'); % for formant plot
        vCordPos=get(data.handles.hax1,'currentpoint'); % for vocal tract
        % Current point 'pos' is structured as such [xfront, yfront, zfront;xback, yback, zback]
        % Instead of looking though fields for specific data var, should
        % just look at the newly implemented 'currAxis'
        if strcmp(currAxis, '4b')
            %curBarIdx = round(sArtPos(1));
            data.curBar = round(sArtPos(1));
            if isfield(data, 'vCordPos')
                data = rmfield(data,'vCordPos'); % remove vCord var so that GUI doesn't always assume you are changing the vocal cord
            end
            if isfield(data, 'newVocalT')
                data = rmfield(data,'newVocalT'); 
            end
            if isfield(data, 'curFtarget')
                data = rmfield(data,'curFtarget'); 
            end
        elseif  strcmp(currAxis, '4')
            %curBarIdx = round(mArtPos(1,2));
            data.curBar = round(mArtPos(1,2));
            if isfield(data, 'vCordPos')
                data = rmfield(data,'vCordPos'); % remove vCord var so that GUI doesn't always assume you are changing the vocal cord
            end
            if isfield(data, 'newVocalT')
                data = rmfield(data,'newVocalT'); 
            end
            if isfield(data, 'curFtarget')
                data = rmfield(data,'curFtarget'); 
            end
        elseif strcmp(currAxis, '3')
            % need to determine which formant clicked
            data.curFval = round(FPos(1));
            data.curFpoint = FPos;
            if isfield(data, 'vCordPos')
                data = rmfield(data,'vCordPos'); % remove vCord var so that GUI doesn't always assume you are changing the vocal cord
            end
            if isfield(data, 'curBar')
                data = rmfield(data,'curBar'); 
            end
            if isfield(data, 'newVocalT')
                data = rmfield(data,'newVocalT'); 
            end  
        elseif strcmp(currAxis, '1')
            data.vCordPos = vCordPos(1,1:2);
            if isfield(data, 'curBar')
                data = rmfield(data,'curBar'); 
            end
            if isfield(data, 'curFtarget')
                data = rmfield(data,'curFtarget'); 
            end
        else
        end
        %curBarIdx = round(pos2(1));
        %curBarIdx = round(pos2(1,2));
        %data.curBar = curBarIdx;
        f0 = 100; % may need to derive this based on tension in the future    
        origF = get(data.handles.hax3,'XTickLabel'); % get original set of formants
        origF = [f0;str2double(origF(1:3))];
        data.origF = origF;
        % want to store the original position of vocal tract before any
        % dragging
        origVocalTx = get(data.handles.h0,'xdata');
        origVocalTy = get(data.handles.h0,'ydata');
        data.origVocalT = complex(origVocalTx,origVocalTy);
        data.currAxis = currAxis;
        data.mouseIsDown = true; % recognizes / saves the fact that the mouse is pressed down
        data.ready2play = false;
        set(data.handles.hfig,'userdata',data);
    end

    function upcallback(varargin)
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        data.mouseIsDown = false;% recognizes / saves the fact that the mous has been let go
        if isfield(data, 'curBar')
            if data.curBar > 10
                data.handles.hplot4b.CData(data.curBar-10,:) = [0 0.4470 0.7410];
            else
                data.handles.hplot4.CData(data.curBar,:) = [0 0.4470 0.7410];
            end
            set(data.handles.hfig,'userdata',data);
            drawnow;
        end
        % could add a block here to turn the appropriate formant cyan?
        if isfield(data, 'vCordPos')
            data = rmfield(data,'vCordPos'); % remove vCord var so that GUI doesn't always assume you are changing the vocal cord
        end
        data.ready2play = true;
        set(data.handles.hfig,'userdata',data);
        diva_vtdisp_Ricky(data.handles.hfig,'setslider',data);
        % old
        %diva_vtdisp_Ricky(data.handles.hfig,'setslider',data);
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
                    diva_vtdisp_Ricky(data.handles.hfig,'setslider',data);
                end
                
                % handling frequency plot clicks
                if isfield(data, 'curFpoint')
                    newPos = get(data.handles.hax3,'currentpoint');
                    %xdata = data.handles.h3.XData;  % get formant plot data
                    %ydata = data.handles.h3.YData;  % get formant plot data
                    %distances = sqrt((data.curFpoint(1)-xdata).^2+(data.curFpoint(2)-ydata).^2);
                    %[minValue, minIndex] = min(distances);
                    
                    fLim = max(data.handles.hax3.XLim);
                        if data.curFval <= fLim && data.curFval > 0
                            data.curFval = newPos(1,1); % new chosen formant freq val
                            %[pks, locs] = findpeaks(data.handles.h3.YData);
                            %newx = xdata;
                            %newy = ydata;
                            %newx(minIndex) = newPos(1,1);
                            %newy(minIndex) = newPos(1,2);
                            %data.handles.h3.XData = newx; 
                            %data.handles.h3.YData = newy; 
                            
                            availableF = str2double(data.handles.hax3.XTickLabel);
                            [~,curFidx] = min(abs(availableF-data.curFpoint(1)));
                            curFidx = curFidx+1; % add 1 to pass f0
                            f0 = 100; % may need to derive this based on tension in the future
                            curFtarget = [f0;availableF(1:3)];
                            curFtarget(1:curFidx-1) = nan;
                            curFtarget(curFidx+1:end) = nan;
                            curFtarget(curFidx) = newPos(1,1);
                            data.curFtarget = curFtarget;               
                            
                            % pass on data to next part of GUI
                            data.ready2play = false;
                            set(data.handles.hfig,'userdata',data);
                            diva_vtdisp_Ricky(data.handles.hfig,'setslider',data);
                            drawnow;
                        end
                end
                
                % handling articulator plot clicks
                if isfield(data, 'curBar')
                    if data.curBar > 10
                        pos=get(data.handles.hax4b,'currentpoint');
                        data.handles.hplot4b.CData(data.curBar-10,:) = [0 0.8 0.8];
                        barLim = max(data.handles.hplot4b.XData);
                        if data.curBar <= barLim && data.curBar > 10.5
                            %data.curBar = curBarIdx;
                            data.curBarVal = pos(1,2);
                            ydata = data.handles.hplot4b.YData;  % get bar plot y data
                            newY = ydata;
                            newY(data.curBar-10) = pos(1,2);
                            %disp(pos2(1,2));
                            data.handles.hplot4b.YData = newY;
                            data.handles.hplot5b.YData = newY;
                            
                            data.ready2play = false;
                            set(data.handles.hfig,'userdata',data);
                            diva_vtdisp_Ricky(data.handles.hfig,'setslider',data);
                            drawnow;
                        end
                    else
                        pos=get(data.handles.hax4,'currentpoint'); % get current point rel to axes [x y -; x y -]
                        data.handles.hplot4.CData(data.curBar,:) = [0 0.8 0.8];
                        barLim = max(data.handles.hplot4.XData);
                        
                        %if curBarIdx <= barLim && curBarIdx > 0.5 && pos2(1,2) >= -3 && pos2(1,2) <= 3
                        if data.curBar <= barLim && data.curBar > 0.5
                            %data.curBar = curBarIdx;
                            data.curBarVal = pos(1);
                            ydata = data.handles.hplot4.YData;
                            newY = ydata;
                            %newY(curBarIdx) = pos2(1,2);
                            newY(data.curBar) = pos(1);
                            %disp(pos2(1,2));
                            data.handles.hplot4.YData = newY;
                            data.handles.hplot5.XData = newY;
                            
                            data.ready2play = false;
                            set(data.handles.hfig,'userdata',data);
                            diva_vtdisp_Ricky(data.handles.hfig,'setslider',data);
                            drawnow;
                        end
                    end
                end
            end
        end
    end
end