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
        
        
        % memory first (h1 is fill in, h0 is outline) 
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
        
        % setting up supplementary plot for 2D vocal tract
        data.handles.hax1a=axes('units','norm','position',[.36 .3 .12 .65],'color',0.85*[1 1 1],'box','off');
        
        % plotting area function
        data.handles.hax2=axes('units','norm','position',[.1 .1 .3 .15],'color',.85*[1 1 1]);
        data.handles.h2=patch(nan,nan,'k','facecolor',1*[1 1 1],'edgecolor','k','linewidth',2,'parent',data.handles.hax2);
        xlabel(data.handles.hax2,'distance to glottis (cm)'); ylabel(data.handles.hax2,'Area (cm^2)');
        % plotting frequency spectrum
        data.handles.hax3=axes('units','norm','position',[.6 .1 .3 .15],'box','off');
        data.handles.h3=plot(nan,nan,'k','color','k','linewidth',2,'parent',data.handles.hax3);
        xlabel(data.handles.hax3,'Frequency (Hz)');
        ylabel(data.handles.hax3,'VT filter (dB)');
        
        % plotting new 'bar-sliders'
        data.handles.hax4 = axes('units','norm','position',[.525 .325 .45 .625]);
        data.handles.hplot4 = bar(zeros(1,13)); % psst you need to plot the bar first, before changing the axes properties
        data.handles.hax4.YLimMode = 'manual';  % or else it'll just change the Ylim properties to be the default for bar plots!!
        data.handles.hax4.YLim = [-1 1];        % used to be -3 to 3, but that seemed excessive....
        data.handles.hplot4.FaceColor = 'flat';
        %data.handles.hplot4 = bar(-3+(3+3)*rand(1,13));
        
%         % plotting new 'bar-sliders'
%         data.handles.hax4 = axes('units','norm','position',[.525 .325 .45 .625]);
%         data.handles.hplot4 = polarhistogram(data.handles.hax4,zeros(1,13),13); % psst you need to plot the bar first, before changing the axes properties
%         %data.handles.hax4.YLimMode = 'manual';  % or else it'll just change the Ylim properties to be the default for bar plots!!
%         %data.handles.hax4.YLim = [-1 1];        % used to be -3 to 3, but that seemed excessive....
%         %data.handles.hplot4.FaceColor = 'flat';
%         %data.handles.hplot4 = bar(-3+(3+3)*rand(1,13));
        
        set(data.handles.hfig,'WindowButtonDownFcn',@downcallback, 'WindowButtonUpFcn',@upcallback, 'WindowButtonMotionFcn',@overcallback); % callback for when mouse hovers over plot
        
        %for n1=1:13 % this is where the sliders are created, need to replace these with bars (for now)
        %    data.handles.hslider(n1)=uicontrol('units','norm','position',[.6 .90-(n1-1)*.05 .3 .05],'style','slider','min',-3,'max',3,'callback',@(varargin)diva_vtdisp(data.handles.hfig,'setslider',n1));
        %end
        
        % flag for first time setup
        data.setup = 1;
        set(data.handles.hfig,'userdata',data);
        diva_vtdisp_Ricky(data.handles.hfig,'update',[zeros(10,1);0;1;1]); % uses 'update' case to initialize default plots
        drawnow;
        
    case 'setslider' % called when a slider is moved, mouse is released  
        barData = varargin{1};
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        n=[];
        if numel(varargin)>=1, n=varargin{1}; end
        if numel(varargin)>=2, v=varargin{2};
        else
            if isfield(barData, 'curBar') && isfield(barData, 'curBarVal')
                n=barData.curBar;
                v=barData.curBarVal;
            else
                return;
            end
        end
        if isempty(n), n=1:numel(v); end
        try, x=data.state.x(:,end);
        catch, x=zeros(13,1);
        end
        x=repmat(x,[1,100]);
        x(n,:)=[linspace(x(n,1),v,20),repmat(v,1,80)];
        diva_vtdisp_Ricky(hfig,'update',x,barData);
                
    case 'update'
        if numel(varargin)> 1
            barData = varargin{2};
        end
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        data.state.x=varargin{1};
        
        if exist('barData', 'var') == 1
            if barData.ready2play
                %if size(data.state.x,2)>1,
                [data.state.s,data.state.fs]=diva_synth(data.state.x,'sound');
                sound(data.state.s,data.state.fs);
                %end
            end
        end 
       
        d=1.0*.75/10;
        fs=4*11025;
        
        %pay attention here for real-time plot update
        %for n=[1:9:size(data.state.x,2)-1,size(data.state.x,2)]
        n=[1:9:size(data.state.x,2)-1,size(data.state.x,2)];
        n=n(end);
        %n = 100;
        
        %[data.state.Aud,data.state.Som,data.state.Outline,data.state.af,data.state.filt]=diva_synth(data.state.x(:,n)); % this in particular
        [data.state.Aud,data.state.Som,data.state.Outline,data.state.af,data.state.filt]=diva_synth(data.state.x(:,n), 'explicit');
        
        % vocal tract configuration
        x=data.state.Outline;
        x(end+1)=x(1);
        
        if data.setup
            set(data.handles.h0,'xdata',real(x),'ydata',imag(x));
            set(data.handles.h0_memory,'xdata',real(x),'ydata',imag(x));
            data.setup = 0;
        end
                    
        if exist('barData', 'var') == 1
            if barData.ready2play
                % ver 1
                set(data.handles.h0_memory,'xdata',real(x),'ydata',imag(x));
                
                % ver 2
                %set(data.handles.h0,'xdata',real(x),'ydata',imag(x));
            end
        end
        
        % ver 1 
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
        i=find(x(2:end-1)>x(1:end-2)&x(2:end-1)>x(3:end))*fs/numel(data.state.filt)*1e0;
        set(data.handles.h3,'xdata',(0:numel(data.state.filt)-1)*fs/numel(data.state.filt)*1e0,'ydata',x);
        set(data.handles.hax3,'xlim',[0 min(8000,fs/2)]*1e0,'ylim',[-15 max(15,max(x))],'box','off','xtick',i);
        set(data.handles.hax3,'XTickLabelRotation',45); % rotate x-axis label to avoid overlap
        set(data.handles.hfig,'userdata',data);
        %for n1=1:13,set(data.handles.hslider(n1),'value',data.state.x(n1,n));end
        drawnow;
        %end
end

    function downcallback(varargin)
        pos2=get(data.handles.hax4,'currentpoint'); % get current point rel to axes [x y -; x y -]
        curBarIdx = round(pos2(1));
        data.curBar = curBarIdx;
        data.mouseIsDown = true; % recognizes / saves the fact that the mouse is pressed down
        data.ready2play = false;
    end

    function upcallback(varargin)
        data.mouseIsDown = false;% recognizes / saves the fact that the mous has been let go
        if isfield(data, 'curBar')
             data.handles.hplot4.CData(data.curBar,:) = [0 0.4470 0.7410];
            drawnow;
        end
        data.ready2play = true;
        diva_vtdisp_Ricky(data.handles.hfig,'setslider',data);
        % old
        %diva_vtdisp_Ricky(data.handles.hfig,'setslider',data);
    end

    function overcallback(varargin)    % for when mouse hovers over plot
        if isfield(data, 'mouseIsDown')
            if data.mouseIsDown
                %p1=get(0,'pointerlocation');    % get mouse location [x y]
                %p2=get(data.hfig,'position');   % get position of figure [x y w h]
                %pos=p1-p2(1:2); % find mouse position relative to figure
                %set(data.hfig,'currentpoint',pos); % not sure
                
                pos2=get(data.handles.hax4,'currentpoint'); % get current point rel to axes [x y -; x y -]
                
                %curBarIdx = round(pos2(1));
                %data.handles.hplot4.CData(curBarIdx,:) = [0 0.8 0.8];
                
                data.handles.hplot4.CData(data.curBar,:) = [0 0.8 0.8];
                barLim = max(data.handles.hplot4.XData);
                %if curBarIdx <= barLim && curBarIdx > 0.5 && pos2(1,2) >= -3 && pos2(1,2) <= 3
                if data.curBar <= barLim && data.curBar > 0.5 && pos2(1,2) >= -3 && pos2(1,2) <= 3
                    %data.curBar = curBarIdx;
                    data.curBarVal = pos2(1,2);
                    ydata = data.handles.hplot4.YData;  % get bar plot y data
                    newY = ydata;
                    %newY(curBarIdx) = pos2(1,2);
                    newY(data.curBar) = pos2(1,2);
                    %disp(pos2(1,2));
                    data.handles.hplot4.YData = newY;
                    
                    data.ready2play = false;
                    diva_vtdisp_Ricky(data.handles.hfig,'setslider',data);
                    drawnow;
                end
            end
        end
    end

end
