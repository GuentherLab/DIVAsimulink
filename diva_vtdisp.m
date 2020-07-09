function varargout=diva_vtdisp(option,varargin)

if ~nargin||isempty(option), option='init'; end
hfig=[];
if ishandle(option), hfig=option; option=varargin{1}; varargin=varargin(2:end); end

switch(lower(option))
    case 'init'
        %data.state.x=zeros(13,1);
        %[data.state.y,data.state.z,data.state.Outline]=diva_synth(data.state.x);

        data.handles.hfig=figure('units','norm','position',[.3 .5 .4 .4],'menubar','none','name','DIVA vocal tract display','numbertitle','off','color','w');
        data.handles.hax1=axes('units','norm','position',[.05 .3 .45 .65],'color',1*[1 1 1]);
        data.handles.h1=patch(nan,nan,'k','facecolor',.85*[1 1 1],'edgecolor','none','linewidth',2,'parent',data.handles.hax1);
        hold(data.handles.hax1,'on'); data.handles.h0=plot(nan,nan,'k','linewidth',2,'parent',data.handles.hax1); hold(data.handles.hax1,'off'); 
        axis(data.handles.hax1,'equal','tight');
        set(data.handles.hax1,'xcolor','w','ycolor','w','xtick',[],'ytick',[],'xdir','reverse');
        %set(data.handles.h1,'xdata',real(data.state.Outline),'ydata',imag(data.state.Outline));
        data.handles.hax2=axes('units','norm','position',[.1 .1 .3 .15],'color',.85*[1 1 1]);
        data.handles.h2=patch(nan,nan,'k','facecolor',1*[1 1 1],'edgecolor','k','linewidth',2,'parent',data.handles.hax2);
        xlabel(data.handles.hax2,'distance to glottis (cm)'); ylabel(data.handles.hax2,'Area (cm^2)');
        data.handles.hax3=axes('units','norm','position',[.6 .1 .3 .15],'box','off');
        data.handles.h3=plot(nan,nan,'k','color','k','linewidth',2,'parent',data.handles.hax3);
        xlabel(data.handles.hax3,'Frequency (Hz)');
        ylabel(data.handles.hax3,'VT filter (dB)');
        for n1=1:13,
            data.handles.hslider(n1)=uicontrol('units','norm','position',[.6 .90-(n1-1)*.05 .3 .05],'style','slider','min',-3,'max',3,'callback',@(varargin)diva_vtdisp(data.handles.hfig,'setslider',n1));
        end
        set(data.handles.hfig,'userdata',data);
        diva_vtdisp(data.handles.hfig,'play',[zeros(10,1);0;1;1]);
        drawnow;
        
    case 'setslider'
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        n=[];
        if numel(varargin)>=1, n=varargin{1}; end
        if numel(varargin)>=2, v=varargin{2}; 
        else v=get(data.handles.hslider(n),'value');
        end
        if isempty(n), n=1:numel(v); end
        try, x=data.state.x(:,end);
        catch, x=zeros(13,1);
        end
        x=repmat(x,[1,100]);
        x(n,:)=[linspace(x(n,1),v,20),repmat(v,1,80)];
        diva_vtdisp(hfig,'play',x);
        
    case 'play'
        if isempty(hfig), hfig=gcf; end
        data=get(hfig,'userdata');
        data.state.x=varargin{1};
        if size(data.state.x,2)>1, 
            [data.state.s,data.state.fs]=diva_synth(data.state.x,'sound');
            sound(data.state.s,data.state.fs);
        end
        d=1.0*.75/10;
        fs=4*11025;
        for n=[1:9:size(data.state.x,2)-1,size(data.state.x,2)]
            [data.state.Aud,data.state.Som,data.state.Outline,data.state.af,data.state.filt]=diva_synth(data.state.x(:,n),'explicit');
            % vocal tract configuration
            x=data.state.Outline; 
            x(end+1)=x(1);
            set(data.handles.h0,'xdata',real(x),'ydata',imag(x));
            %x([353,354])=[160+1i*imag(x(352)), 160+1i*imag(x(355))];
            set(data.handles.h1,'xdata',real(x),'ydata',imag(x));
            %set(data.handles.hax1,'xlim',[-10 175]);
            % area function
            set(data.handles.h2,'xdata',d*[1:numel(data.state.af) numel(data.state.af):-1:1],'ydata',[max(0,data.state.af(:))'/2, -fliplr(max(0,data.state.af(:))')/2]);
            set(data.handles.hax2,'xlim',d*[.5 numel(data.state.af)+.5],'ylim',max(8,max(data.state.af)/2)*[-1 1]);
            % frequency spectrum
            x=10*log10(abs(data.state.filt));
            i=find(x(2:end-1)>x(1:end-2)&x(2:end-1)>x(3:end))*fs/numel(data.state.filt)*1e0;
            set(data.handles.h3,'xdata',(0:numel(data.state.filt)-1)*fs/numel(data.state.filt)*1e0,'ydata',x);
            set(data.handles.hax3,'xlim',[0 min(8000,fs/2)]*1e0,'ylim',[-15 max(15,max(x))],'box','off','xtick',i);
            set(data.handles.hfig,'userdata',data);
            for n1=1:13,set(data.handles.hslider(n1),'value',data.state.x(n1,n));end
            drawnow;
        end
end
end
