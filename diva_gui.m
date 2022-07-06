function diva_gui(option,varargin)
global DIVA_x;
if ~nargin, option='init'; end
%if ~isfield(DIVA_x,'guiinit'),DIVA_x.guiinit=1;end

switch(lower(option)),
    case {'init','simulation','initgui'}
        if strcmp(lower(option),'simulation')&&DIVA_x.changed&&~strcmp(DIVA_x.production,'new@default')&&~strcmp(DIVA_x.production,'new@random')
            answ=questdlg({'Exiting the ''Targets'' tab without saving first will disregard','any unsaved edits to the current target','','Do you want to continue without saving?'},'','Yes (continue without saving)','No (save before continuing)','No (save before continuing)');
            if strcmp(answ,'No (save before continuing)')
                try, diva_gui targetsgui_save;
                catch, diva_gui save;
                end
            end
        end
        DIVA_x.gui=1;
        DIVA_x.model=gcs;
        idx=find(DIVA_x.model=='/');
        if ~isempty(idx),DIVA_x.model=DIVA_x.model(1:idx(1)-1);end
        if ~strncmpi(DIVA_x.model,'diva',4)
            if strcmpi(option,'initgui'), open diva;
            else load_system diva; % hide SIMULINK GUI            
            end 
            %open diva; 
            %if ~strcmpi(option,'initgui'),set_param('diva', 'Open', 'off');end % hide SIMULINK GUI            
            DIVA_x.model='diva';
        end
        DIVA_x.params=diva_vocaltract;
        DIVA_x.color=[.37,.74,1;1,1,1];
        DIVA_x.guioptions.editableduration=false;
        DIVA_x.production_list=diva_targets('list');
        if ~isfield(DIVA_x,'production'), DIVA_x.production='new@random'; end
        if ~isfield(DIVA_x,'cycles'),DIVA_x.cycles=1; end
        if ~isfield(DIVA_x,'dosound'), DIVA_x.dosound=1; end
        DIVA_x.changed=0;

        if ~isfield(DIVA_x,'figure')||isempty(DIVA_x.figure.handles.figure)||~ishandle(DIVA_x.figure.handles.figure),
            DIVA_x.figure.handles.figure=figure('units','norm','position',[.1,.55,.8,.4],'menubar','none','name',['DIVA simulation (model: ',DIVA_x.model,')'],'numbertitle','off','color',DIVA_x.color(2,:),'tag','diva_gui','closerequestfcn','diva_gui(''close'')');
        else
            figure(DIVA_x.figure.handles.figure);
            clf;
        end
        
        % gui initialization
        uicontrol('units','norm','position',[0,.9,1,.1],'style','frame','backgroundcolor',DIVA_x.color(1,:),'foregroundcolor',DIVA_x.color(1,:));
        uicontrol('units','norm','position',[0,0,1,.1],'style','frame','backgroundcolor',DIVA_x.color(1,:),'foregroundcolor',DIVA_x.color(1,:));
        DIVA_x.figure.handles.button1=uicontrol('units','norm','position',[.1,.9,.15,.05],'style','pushbutton','string','simulation','value',1,'backgroundcolor','w','foregroundcolor','k','fontweight','bold','callback','diva_gui(''simulation'')');
        DIVA_x.figure.handles.button2=uicontrol('units','norm','position',[.25,.9,.15,.05],'style','pushbutton','string','targets','value',0,'backgroundcolor',DIVA_x.color(1,:),'foregroundcolor','k','fontweight','normal','callback','diva_gui(''targets'')');
        DIVA_x.figure.handles.list1=uicontrol('units','norm','position',[.75,.8,.175,.07],'style','popupmenu','string',{'Auditory/Som State','Auditory/Som Errors'},'foregroundcolor',.75*DIVA_x.color(2,:),'backgroundcolor',DIVA_x.color(2,:),'callback','diva_gui(''update_inputoutputplots'')');
        DIVA_x.figure.handles.list2=uicontrol('units','norm','position',[.1,.8,.175,.07],'style','popupmenu','string',{'Motor Command','FeedForward Command','FeedBack Command'},'foregroundcolor',.75*DIVA_x.color(2,:),'backgroundcolor',DIVA_x.color(2,:),'fontweight','normal','callback','diva_gui(''update_inputoutputplots'')');
        DIVA_x.figure.handles.buttonlist1=uicontrol('units','norm','position',[.75+.175,.8,.025,.07],'style','pushbutton','string','+','foregroundcolor',.75*DIVA_x.color(2,:),'backgroundcolor',DIVA_x.color(2,:),'fontweight','normal','callback','diva_gui(''extend_outputplots'')');
        DIVA_x.figure.handles.buttonlist2=uicontrol('units','norm','position',[.1+.175,.8,.025,.07],'style','pushbutton','string','+','foregroundcolor',.75*DIVA_x.color(2,:),'backgroundcolor',DIVA_x.color(2,:),'fontweight','normal','callback','diva_gui(''extend_inputplots'')');
        
        DIVA_x.figure.handles.button4=uicontrol('units','norm','position',[.5,.01,.07,.08],'style','pushbutton','string','Start','foregroundcolor','k','backgroundcolor',1-.5*(1-DIVA_x.color(1,:)),'fontweight','bold','callback','diva_gui(''start'')','tooltipstring','start/stop simulation');
        DIVA_x.figure.handles.field1=uicontrol('units','norm','position',[.59,.05,.07,.045],'style','edit','string',num2str(DIVA_x.cycles),'backgroundcolor',DIVA_x.color(1,:),'tooltipstring','number of repetitions');
        DIVA_x.figure.handles.text1=uicontrol('units','norm','position',[.66,.05,.1,.045],'style','text','string','repetitions','backgroundcolor',DIVA_x.color(1,:),'foregroundcolor','k','horizontalalignment','left');
        DIVA_x.figure.handles.field2=uicontrol('units','norm','position',[.59,.01,.07,.045],'style','edit','string','1000','backgroundcolor',DIVA_x.color(1,:),'tooltipstring','duration of each repetition/simulation in milliseconds');
        DIVA_x.figure.handles.text2=uicontrol('units','norm','position',[.66,.01,.1,.045],'style','text','string','duration (ms)','backgroundcolor',DIVA_x.color(1,:),'foregroundcolor','k','horizontalalignment','left');
        list=cat(1,{'new@default';'new@random'},DIVA_x.production_list);
        idxvalue=strmatch(DIVA_x.production,list,'exact'); if isempty(idxvalue), idxvalue=1; DIVA_x.production=list{1}; end
        DIVA_x.figure.handles.list3=uicontrol('units','norm','position',[.05,.02,.15,.06],'style','popupmenu','string',list,'value',idxvalue,'backgroundcolor',DIVA_x.color(1,:),'callback','diva_gui(''load'')','tooltipstring','load selected target');
        DIVA_x.figure.handles.button5=uicontrol('units','norm','position',[.21,.02,.09,.06],'style','pushbutton','string','Save FF command','foregroundcolor','k','backgroundcolor',1-.5*(1-DIVA_x.color(1,:)),'fontweight','normal','callback','diva_gui(''save'')','enable','off','tooltipstring','save current target definition (and learned feedforward command if applicable)');
        DIVA_x.figure.handles.button7=uicontrol('units','norm','position',[.31,.02,.09,.06],'style','pushbutton','string','Reset FF command','foregroundcolor','k','backgroundcolor',1-.5*(1-DIVA_x.color(1,:)),'fontweight','normal','callback','diva_gui(''reset'')','tooltipstring','reset learned feedforward command to last saved state or to zero (initial state, no learning)');
        DIVA_x.figure.handles.button6=uicontrol('units','norm','position',[.82,.05,.15,.045],'style','checkbox','string','Enable sound','foregroundcolor','k','backgroundcolor',DIVA_x.color(1,:),'fontweight','normal','callback','diva_gui(''soundonoff'')','value',DIVA_x.dosound,'tooltipstring','enable/disable sound reproduction after each simulation');
        DIVA_x.figure.handles.button8=uicontrol('units','norm','position',[.82,.005,.15,.045],'style','pushbutton','string','Replay last production','foregroundcolor','k','backgroundcolor',DIVA_x.color(1,:),'fontweight','normal','callback','diva_gui(''replay'')','tooltipstring','replay last simulation (with no learning)');
        
        % center plot
        DIVA_x.figure.handles.ax1=[];%axes('units','norm','position',[.35,.2,.15,.4],'color',DIVA_x.color(2,:)); % note: removed real-time vt display
        %diva_vocaltract('output',zeros(DIVA_x.params.Input.Dimensions,1),-1); 
        DIVA_x.figure.handles.ax0=axes('units','norm','position',[.40,.41,.20,.26],'color',DIVA_x.color(2,:));
        DIVA_x.figure.handles.pl0=plot([1,2],[0,0],'-','color',.75*[0,0,1]);%axis off;
        hold on; DIVA_x.figure.handles.pl3=plot([nan,nan],2*[-1,1],'k--'); hold off
        set(DIVA_x.figure.handles.ax0,'xcolor',.75*DIVA_x.color(2,:),'ycolor',.75*DIVA_x.color(2,:),'box','off','fontsize',8);
        xlabel('time (ms)');
        DIVA_x.figure.handles.slider=uicontrol('units','norm','position',[.40,.20,.20,.05],'style','slider','min',0,'max',1,'SliderStep',[.01 .1],'callback','diva_gui(''replay_slider'')','visible','off');
        DIVA_x.figure.handles.slider_text=uicontrol('units','norm','position',[.40,.155,.20,.045],'style','text','string','','horizontalalignment','center','backgroundcolor','w','visible','off');
        try, addlistener(DIVA_x.figure.handles.slider, 'ContinuousValueChange',@(varargin)diva_gui('replay_slider')); end

        % Input/Output plots
        DIVA_x.params.Plots.Output={1,[]};%{1:numel(DIVA_x.params.Output(1).Plots_dim),[]};
        DIVA_x.params.Plots.Input={1};%{1:numel(DIVA_x.params.Input.Plots_dim)};
        diva_gui('init_inputoutputplots');
        if isfield(DIVA_x,'production'),
            diva_gui('load',DIVA_x.production);
        end
        diva_vtdisp init;
        figure(DIVA_x.figure.handles.figure);

    case 'init_inputoutputplots',
        Vars={'Output','Input'};
        Coords={.75, .1};
        if nargin<2, vars=1:2; else vars=varargin{1}; end
        if nargin<3, ylim=[]; else ylim=varargin{2}; end
        extendinfo=isequal(vars,1);
        for nvar=vars,
            var=Vars{nvar};
            if extendinfo, coords=.45;
            else coords=Coords{nvar};
            end
            
            cs=[];N0=[];N1=[];
            for n0=1:numel(DIVA_x.params.Plots.(var)),
                for n1=1:numel(DIVA_x.params.Plots.(var){n0}),
                    cs=[cs,numel(DIVA_x.params.(var)(n0).Plots_dim{DIVA_x.params.Plots.(var){n0}(n1)})];
                    N0=[N0,n0];
                    N1=[N1,DIVA_x.params.Plots.(var){n0}(n1)];
                end
            end
            DIVA_x.params.Plots_.(var).setindex=N0;
            DIVA_x.params.Plots_.(var).plotindex=N1;
            tcs=[0,cumsum(cs)/sum(cs)];
            if isfield(DIVA_x.figure.handles,'ax2')&&numel(DIVA_x.figure.handles.ax2)>=nvar&&any(ishandle(DIVA_x.figure.handles.ax2{nvar})),
                delete(DIVA_x.figure.handles.ax2{nvar}(ishandle(DIVA_x.figure.handles.ax2{nvar})));
                delete(DIVA_x.figure.handles.ax3{nvar}(ishandle(DIVA_x.figure.handles.ax3{nvar})));
            end
            if numel(N0)>0
                for n2=1:numel(N0),
                    n0=N0(n2);
                    n1=N1(n2);
                    m0=cs(n2);
                    idxdims=DIVA_x.params.(var)(n0).Plots_dim{n1};
                    DIVA_x.figure.handles.ax3{nvar}(n2)=axes('units','norm','position',[coords-.07,.175+.55*(1-.3*extendinfo)*tcs(n2),.03,.5*(1-.3*extendinfo)*(tcs(n2+1)-tcs(n2))],'color',DIVA_x.color(2,:),'fontsize',8,'visible','off');
                    DIVA_x.figure.handles.ax2{nvar}(n2)=axes('units','norm','position',[coords,.175+.55*(1-.3*extendinfo)*tcs(n2),.2*(1+extendinfo),.5*(1-.3*extendinfo)*(tcs(n2+1)-tcs(n2))],'fontsize',8,'color',DIVA_x.color(2,:));
                    set(gca,'xcolor',.75*DIVA_x.color(2,:),'ycolor',.75*DIVA_x.color(2,:));
                    if ~isempty(ylim)&&isfield(DIVA_x.params.(var)(n0),'Range'), set(gca,'ylim',[min(DIVA_x.params.(var)(n0).Range(idxdims,1)),max(DIVA_x.params.(var)(n0).Range(idxdims,2))]); end
                    if 0&&m0==1, ylabel(DIVA_x.params.(var)(n0).Plots_label{n1},'rotation',0,'horizontalalignment','right','interpreter','none'); end
                    if n2>1,set(gca,'xticklabel',[]);
                    else xlabel('time (ms)'); end
                    if 0&&m0==1, delete(DIVA_x.figure.handles.ax3{nvar}(n2));
                    else
                        idx=arrayfun(@(n)max([0 find(cellfun(@(x)isequal(x,n),DIVA_x.params.(var)(n0).Plots_dim))]),DIVA_x.params.(var)(n0).Plots_dim{n1});
                        axes(DIVA_x.figure.handles.ax3{nvar}(n2)); 
                        tc=get(gca,'ColorOrder');
                        for n3=1:m0, text(1,n3,DIVA_x.params.(var)(n0).Plots_label{idx(n3)},'color',tc(1+rem(n3-1,size(tc,1)),:),'horizontalalignment','right','interpreter','none','fontsize',8); end
                        set(DIVA_x.figure.handles.ax3{nvar}(n2),'xlim',[0 1],'ylim',[1-2 m0+2]);
                        axis(DIVA_x.figure.handles.ax3{nvar}(n2),'off');
                    end
                end
            end
        end
            
    case 'update_inputoutputplots',
        for n2=1:numel(DIVA_x.params.Plots_.Output.plotindex),
            axes(DIVA_x.figure.handles.ax2{1}(n2));cla;
            hold on;
            n0=DIVA_x.params.Plots_.Output.setindex(n2);
            n1=DIVA_x.params.Plots_.Output.plotindex(n2);
            idxdims=DIVA_x.params.Output(n0).Plots_dim{n1};
            if n0>1, idxdims=idxdims+sum(cat(2,DIVA_x.params.Output(1:n0-1).Dimensions)); end
            plottype=get(DIVA_x.figure.handles.list1,'value');
            scale=cat(1,DIVA_x.params.Output(:).Scale);
            switch(plottype)
                case 1,
                    for n3=1:numel(idxdims),
                        patch([DIVA_x.logs.time;flipud(DIVA_x.logs.time)]*1000,[DIVA_x.logs.AuditorySomatosensoryTargetMax(:,idxdims(n3))*scale(idxdims(n3));flipud(DIVA_x.logs.AuditorySomatosensoryTargetMin(:,idxdims(n3))*scale(idxdims(n3)))],'k','facecolor',.9*[1,1,1],'edgecolor',.8*[1,1,1]);
                    end
                    plot(DIVA_x.logs.time*1000,DIVA_x.logs.AuditorySomatosensoryState(:,idxdims)*diag(scale(idxdims)),'-','linewidth',2);
                case 2,
                    plot(DIVA_x.logs.time*1000,DIVA_x.logs.AuditorySomatosensoryError(:,idxdims)*diag(scale(idxdims)),'-','linewidth',2);
            end
            if ~isempty(DIVA_x.logs.time)&&DIVA_x.logs.time(end)>0, set(gca,'xlim',[0,DIVA_x.logs.time(end)*1000]); end
            hold off;
            grid on;
            axis tight;
            hold on; DIVA_x.figure.handles.pl2{1}(n2)=plot([nan nan],get(gca,'ylim'),'k--'); hold off;
        end
        
        for n2=1:numel(DIVA_x.params.Plots_.Input.plotindex),
            axes(DIVA_x.figure.handles.ax2{2}(n2));cla;
            hold on;
            n0=DIVA_x.params.Plots_.Input.setindex(n2);
            n1=DIVA_x.params.Plots_.Input.plotindex(n2);
            idxdims=DIVA_x.params.Input(n0).Plots_dim{n1};
            if n0>1, idxdims=idxdims+sum(cat(2,DIVA_x.params.Input(1:n0-1).Dimensions)); end
            plottype=get(DIVA_x.figure.handles.list2,'value');
            scale=cat(1,DIVA_x.params.Input(:).Scale);
            switch(plottype)
                case 1,
                    plot(DIVA_x.logs.time*1000,DIVA_x.logs.ArticulatoryPosition(:,idxdims)*diag(scale(idxdims)),'-','linewidth',1);
                case 2,
                    plot(DIVA_x.logs.time*1000,DIVA_x.logs.FeedForwardMotorCommand(:,idxdims)*diag(scale(idxdims)),'-','linewidth',1);
                case 3,
                    plot(DIVA_x.logs.time*1000,DIVA_x.logs.FeedBackMotorCommand(:,idxdims)*diag(scale(idxdims)),'-','linewidth',1);
            end
            set(gca,'xlim',[0,DIVA_x.logs.time(end)*1000]);
            hold off;
            grid on;
            axis tight;
            hold on; DIVA_x.figure.handles.pl2{2}(n2)=plot([nan nan],get(gca,'ylim'),'k--'); hold off;
        end
        drawnow

    case 'extend_outputplots'
        txt=cat(2,reshape(DIVA_x.params.Output(1).Plots_label,1,[]),reshape(DIVA_x.params.Output(2).Plots_label,1,[]));
        idx=cat(2,1+zeros(1,numel(DIVA_x.params.Output(1).Plots_label)),2+zeros(1,numel(DIVA_x.params.Output(2).Plots_label)));
        value=zeros(size(idx));
        value(DIVA_x.params.Plots.Output{1})=1;
        value(numel(DIVA_x.params.Output(1).Plots_label)+DIVA_x.params.Plots.Output{2})=1;
        [s,ok]=listdlg('PromptString','Select signals to display:','SelectionMode','multiple','ListString',txt,'listsize',[150,200],'initialvalue',find(value));
        if ok,%&&~isempty(s),
            value(:)=0;
            value(s)=1;
            DIVA_x.params.Plots.Output={find(value(idx==1)),find(value(idx==2))};
        end
        diva_gui('init_inputoutputplots');
        diva_gui('update_inputoutputplots');
        
    case 'extend_inputplots'
        txt=reshape(DIVA_x.params.Input(1).Plots_label,1,[]);
        idx=1+zeros(1,numel(DIVA_x.params.Input(1).Plots_label));
        value=zeros(size(idx));
        value(DIVA_x.params.Plots.Input{1})=1;
        [s,ok]=listdlg('PromptString','Select signals to display:','SelectionMode','multiple','ListString',txt,'listsize',[150,200],'initialvalue',find(value));
        if ok,%&&~isempty(s),
            value(:)=0;
            value(s)=1;
            DIVA_x.params.Plots.Input={find(value(idx==1))};
        end
        diva_gui('init_inputoutputplots');
        diva_gui('update_inputoutputplots');

    case 'soundonoff'
        DIVA_x.dosound=get(DIVA_x.figure.handles.button6,'value');

    case 'softinit'
        DIVA_x.gui=1;
        if ~isfield(DIVA_x,'figure')||isempty(DIVA_x.figure.handles.figure)||~ishandle(DIVA_x.figure.handles.figure),
            diva_gui('init');
        else
            figure(DIVA_x.figure.handles.figure);
            if DIVA_x.debug
                set(DIVA_x.figure.handles.h3,'xdata',[],'ydata',[]);
            end
        end
        
    case 'close'
        if DIVA_x.changed&&~strcmp(DIVA_x.production,'new@default')&&~strcmp(DIVA_x.production,'new@random')
            answ=questdlg({'Closing this tab without saving first will disregard','any unsaved changes','','Do you want to continue without saving?'},'','Yes (close without saving)','No (save before closing)','No (save before closing)');
            if strcmp(answ,'No (save before closing)')
                diva_gui save
            end
        end
        diva_vtdisp close;
        DIVA_x.gui=0;
        delete(gcbf);
        
    case 'start'
        nruns=str2double(get(DIVA_x.figure.handles.field1,'string'));
        DIVA_x.cycles=nruns;
        DIVA_x.changed=1;
        time=str2double(get(DIVA_x.figure.handles.field2,'string')); 
        etime=time/1000+.060+.100;
        set_param(DIVA_x.model,'StopTime',num2str(etime));
        
        try, t=DIVA_x.production_art.time/DIVA_x.production_art.time(end)*time/1000;
        catch, t=0:.005:time/1000;
        end
        DT=.005; Target_duration=[];for t1=DT*(0:ceil(etime/DT)), Target_duration=[Target_duration; t1 t(min(numel(t),sum(t<=t1)+1))-t(sum(min(numel(t),sum(t<=t1)+1)-1))]; end
        assignin('base','Target_duration',Target_duration);
        %Target_duration=[0,time/1000]; % time&values
        %assignin('base','Target_duration',Target_duration);
        
        set(DIVA_x.figure.handles.button4,'string','Stop','callback','diva_gui(''stop'')');
        set([DIVA_x.figure.handles.button2,DIVA_x.figure.handles.field1,DIVA_x.figure.handles.field2,DIVA_x.figure.handles.list3,DIVA_x.figure.handles.button5,DIVA_x.figure.handles.button7,DIVA_x.figure.handles.button8],'enable','off');
        set([DIVA_x.figure.handles.slider DIVA_x.figure.handles.slider_text],'visible','off');
        evalin('base','global DIVA_x');
        for nrun=1:nruns
            DIVA_x.simopt=simset('OutputVariables','t');
            simout=evalin('base','sim(DIVA_x.model,[],DIVA_x.simopt)');
            if simout(end)<time/1000 || ~strcmp(get(DIVA_x.figure.handles.button4,'string'),'Stop'), break; end
        end
        set(DIVA_x.figure.handles.button4,'string','Start','callback','diva_gui(''start'')');
        set([DIVA_x.figure.handles.button2,DIVA_x.figure.handles.field1,DIVA_x.figure.handles.field2,DIVA_x.figure.handles.list3,DIVA_x.figure.handles.button5,DIVA_x.figure.handles.button7,DIVA_x.figure.handles.button8],'enable','on');
        set(DIVA_x.figure.handles.slider,'visible','on','sliderstep',min(1,[1,10]/max(1,size(DIVA_x.logs.ArticulatoryPosition,1))));
        
    case 'stop'
        set(DIVA_x.figure.handles.button4,'string','Start','callback','diva_gui(''start'')');
        set([DIVA_x.figure.handles.button2,DIVA_x.figure.handles.field1,DIVA_x.figure.handles.field2,DIVA_x.figure.handles.list3,DIVA_x.figure.handles.button5,DIVA_x.figure.handles.button7,DIVA_x.figure.handles.button8],'enable','on');
        set(DIVA_x.figure.handles.slider,'visible','on','sliderstep',min(1,[1,10]/max(1,size(DIVA_x.logs.ArticulatoryPosition,1))));
        set_param(DIVA_x.model,'simulationcommand','stop') ;

    case 'replay_slider'
        n=get(DIVA_x.figure.handles.slider,'val');
        n=max(1,min(size(DIVA_x.logs.ArticulatoryPosition,1), round(1+(size(DIVA_x.logs.ArticulatoryPosition,1)-1)*n)));
        %diva_vocaltract('output',diag(DIVA_x.params.Input.Scale)*DIVA_x.logs.ActualArticulatoryPosition(n,:)',1);
        set(DIVA_x.figure.handles.slider_text,'visible','on','string',sprintf('time = %d ms',round(1000*DIVA_x.logs.time(n))));
        for n2=1:numel(DIVA_x.params.Plots_.Output.plotindex),set(DIVA_x.figure.handles.pl2{1}(n2),'xdata',DIVA_x.logs.time(n)*1000*[1 1]);end
        for n2=1:numel(DIVA_x.params.Plots_.Input.plotindex),set(DIVA_x.figure.handles.pl2{2}(n2),'xdata',DIVA_x.logs.time(n)*1000*[1 1]);end
        set(DIVA_x.figure.handles.pl3,'xdata',DIVA_x.logs.time(n)*1000*[1 1],'visible','on');
        try, diva_vtdisp('set',diag(DIVA_x.params.Input.Scale)*DIVA_x.logs.ActualArticulatoryPosition(n,:)'); end
        
    case 'replay'
        diva_callback_stopfcn;
        %for n=1:size(DIVA_x.logs.ArticulatoryPosition,1), 
        %    diva_vocaltract('output',diag(DIVA_x.params.Input.Scale)*DIVA_x.logs.ArticulatoryPosition(n,:)',1); 
        %end
        
    case 'savemovie'
        hfig=findobj(0,'tag','diva_vtdisp');
        if isempty(hfig), return; end
        videoformats={'*.avi','Motion JPEG AVI (*.avi)';'*.mj2','Motion JPEG 2000 (*.mj2)';'*.mp4;*.m4v','MPEG-4 (*.mp4;*.m4v)';'*.avi','Uncompressed AVI (*.avi)'; '*.avi','Indexed AVI (*.avi)'; '*.avi','Grayscale AVI (*.avi)'};
        [filename, pathname,filterindex]=uiputfile(videoformats,'Save video as','diva_video01.mp4');
        if isequal(filename,0), return; end
        defs_videowriteframerate=200; % fps
        objvideo = VideoWriter(fullfile(pathname,filename),regexprep(videoformats{filterindex,2},'\s*\(.*$',''));
        set(objvideo,'FrameRate',defs_videowriteframerate);
        open(objvideo);
        DT=.005;
        for n=1:size(DIVA_x.logs.ActualArticulatoryPosition,1)
            val=(n-1)/(size(DIVA_x.logs.ArticulatoryPosition,1)-1);
            set(DIVA_x.figure.handles.slider,'val',val);
            diva_gui replay_slider;
            currFrame=getframe(hfig);
            writeVideo(objvideo,currFrame);
        end
        close(objvideo);
        fprintf('File %s created',fullfile(pathname,filename));
        
        
    case {'load','noload'}
        if strcmp(lower(option),'load')
            if nargin>1,
                DIVA_x.production=varargin{1};
            else
                str=get(DIVA_x.figure.handles.list3,'string');
                value=get(DIVA_x.figure.handles.list3,'value');
                DIVA_x.production=str{value};
            end
            if strcmp(DIVA_x.production,'new@default')
                DIVA_x.production_info=diva_targets('new','txt');
                DIVA_x.production_art=[];
            elseif strcmp(DIVA_x.production,'new@random')
                DIVA_x.production_info=diva_targets('random','txt');
                DIVA_x.production_art=[];
            else
                DIVA_x.production_info=diva_targets('load','txt',DIVA_x.production);
                DIVA_x.production_art=[];
                try, DIVA_x.production_art=diva_targets('load','mat',DIVA_x.production); end
                if ~isfield(DIVA_x.production_info,'wrapper'), DIVA_x.production_info.wrapper=0; end
            end
            DIVA_x.changed=0;
            set(DIVA_x.figure.handles.button5,'enable','off');
            if ishandle(DIVA_x.figure.handles.button8), set(DIVA_x.figure.handles.button8,'enable','off'); end
        end
        timeseries=diva_preparesimulation(DIVA_x.production_info,DIVA_x.production_art);
        maxt=max(timeseries.time)/1000;
        %DT=min(diff(timeseries.time))*1000;
        etime=maxt+.060+.100;
        set_param(DIVA_x.model,'StopTime',num2str(etime));%.15+DT*size(Wart,1)));

        try
            t=DIVA_x.production_art.time/DIVA_x.production_art.time(end)*maxt;
            DT=.005; Target_duration=[];for t1=DT*(0:ceil(etime/DT)), Target_duration=[Target_duration; t1 t(min(numel(t),sum(t<=t1)+1))-t(sum(min(numel(t),sum(t<=t1)+1)-1))]; end
            assignin('base','Target_duration',Target_duration);
        end
        %Target_duration=[0,maxt]; % time&values
        %assignin('base','Target_duration',Target_duration);
        DIVA_x.logs.time=timeseries.time/1000;
        DIVA_x.logs.AuditorySomatosensoryTargetMax=cat(2,timeseries.Aud_max*diag(1./DIVA_x.params.Output(1).Scale),timeseries.Som_max*diag(1./DIVA_x.params.Output(2).Scale));
        DIVA_x.logs.AuditorySomatosensoryTargetMin=cat(2,timeseries.Aud_min*diag(1./DIVA_x.params.Output(1).Scale),timeseries.Som_min*diag(1./DIVA_x.params.Output(2).Scale));
        DIVA_x.logs.AuditorySomatosensoryState=nan(size(DIVA_x.logs.AuditorySomatosensoryTargetMax));
        DIVA_x.logs.AuditorySomatosensoryError=nan(size(DIVA_x.logs.AuditorySomatosensoryTargetMax));
        DIVA_x.logs.FeedForwardMotorCommand=timeseries.Art*diag(1./DIVA_x.params.Input(1).Scale);
        DIVA_x.logs.ArticulatoryPosition=nan(size(DIVA_x.logs.FeedForwardMotorCommand));
        DIVA_x.logs.ActualArticulatoryPosition=nan(size(DIVA_x.logs.FeedForwardMotorCommand));
        DIVA_x.logs.FeedBackMotorCommand=nan(size(DIVA_x.logs.FeedForwardMotorCommand));
        %set(DIVA_x.figure.handles.list1,'value',1);
        %set(DIVA_x.figure.handles.list2,'value',2);
        if ishandle(DIVA_x.figure.handles.field2)
            set(DIVA_x.figure.handles.field2,'string',num2str(1000*maxt));
            set(DIVA_x.figure.handles.slider,'visible','off');
            diva_gui update_inputoutputplots;
        end
        
    case 'save'
        Art=diva_weightsadaptive('weights','diva_weights_SSM2FF.mat');
        if ~isempty(Art)
            if strcmpi(DIVA_x.production,'new@default')||strcmpi(DIVA_x.production,'new@random'),
                answ=inputdlg('Enter new target name','',1,{''});
                if isempty(answ), return;  end
                DIVA_x.production=answ{1};
                diva_targets('save','txt',DIVA_x.production,DIVA_x.production_info);
                diva_targets('save','mat',DIVA_x.production,DIVA_x.production_info,1);
                clear diva_weightsadaptive;
                reload=1;
            else reload=0; end
            diva_targets('save','art',DIVA_x.production,Art,DIVA_x.production_info);
            DIVA_x.production_list=diva_targets('list');
            list=cat(1,{'new@default';'new@random'},DIVA_x.production_list);
            idxvalue=strmatch(DIVA_x.production,list,'exact'); if isempty(idxvalue), idxvalue=1; DIVA_x.production=list{1}; end
            set(DIVA_x.figure.handles.list3,'string',list,'value',idxvalue);
            if reload diva_gui load; end
        else 
            disp(['warning: weight matrix not loaded yet. Run simulation first']);
        end
        DIVA_x.changed=0;
        
    case 'reset'
        answ=questdlg('Reset target to:','','last saved state','initial state','initial state');
        if isempty(answ), return; end
        if strcmp(answ,'initial state')
            DIVA_x.production_art=diva_targets('reset',DIVA_x.production_info);
            diva_gui noload;
        else
            diva_gui load;
        end
        %DIVA_x.changed=1;
        
    case 'targets'
        if DIVA_x.changed&&~strcmp(DIVA_x.production,'new@default')&&~strcmp(DIVA_x.production,'new@random')
            answ=questdlg({'Exiting the ''Simulation'' tab without saving first will disregard','any unsaved changes to the learned feedforward weights','','Do you want to continue without saving?'},'','Yes (continue without saving)','No (save before continuing)','No (save before continuing)');
            if strcmp(answ,'No (save before continuing)')
                diva_gui save
            end
        end
        % gui initialization
        figure(DIVA_x.figure.handles.figure);
        idxremove=[DIVA_x.figure.handles.list1,DIVA_x.figure.handles.list2,DIVA_x.figure.handles.buttonlist1,DIVA_x.figure.handles.buttonlist2,DIVA_x.figure.handles.button4,DIVA_x.figure.handles.field1,DIVA_x.figure.handles.field2,DIVA_x.figure.handles.ax1,DIVA_x.figure.handles.ax0,DIVA_x.figure.handles.pl0,DIVA_x.figure.handles.pl3,DIVA_x.figure.handles.ax2{2},DIVA_x.figure.handles.ax3{2},DIVA_x.figure.handles.text1,DIVA_x.figure.handles.text2,DIVA_x.figure.handles.button6,DIVA_x.figure.handles.button8,DIVA_x.figure.handles.slider];
        delete(idxremove(ishandle(idxremove)));
        if isfield(DIVA_x.figure,'thandles')
            idxremove={DIVA_x.figure.thandles.button6,DIVA_x.figure.thandles.button9,DIVA_x.figure.thandles.text1,DIVA_x.figure.thandles.field1,DIVA_x.figure.thandles.text2,DIVA_x.figure.thandles.field2,DIVA_x.figure.thandles.text3,DIVA_x.figure.thandles.field3,DIVA_x.figure.thandles.text4,DIVA_x.figure.thandles.field4,DIVA_x.figure.thandles.text5,DIVA_x.figure.thandles.field5,DIVA_x.figure.thandles.buttonfield5,DIVA_x.figure.thandles.text6,DIVA_x.figure.thandles.field6,DIVA_x.figure.thandles.text7,DIVA_x.figure.thandles.field7,DIVA_x.figure.thandles.text9,DIVA_x.figure.thandles.field9,DIVA_x.figure.thandles.button2field5,DIVA_x.figure.thandles.text8,DIVA_x.figure.thandles.field8,DIVA_x.figure.thandles.frame8};
            for n1=1:numel(idxremove), delete(idxremove{n1}(ishandle(idxremove{n1}))); end
        end
        %if ~isfield(DIVA_x,'resetff'), DIVA_x.resetff=1; end
        set(DIVA_x.figure.handles.button1,'backgroundcolor',DIVA_x.color(1,:),'foregroundcolor','k','fontweight','normal','foregroundcolor','k');
        set(DIVA_x.figure.handles.button2,'backgroundcolor','w','foregroundcolor','k','fontweight','bold','foregroundcolor','k');
        DIVA_x.production_list=diva_targets('list');
        value=DIVA_x.production;
        list=cat(1,{'new@default';'new@random'},DIVA_x.production_list);
        idxvalue=strmatch(value,list,'exact'); if isempty(idxvalue), idxvalue=1; else idxvalue=idxvalue(1); end
        set(DIVA_x.figure.handles.list3,'callback','diva_gui(''targetsgui_load'')','string',list,'value',idxvalue);
        set(DIVA_x.figure.handles.button5,'callback','diva_gui(''targetsgui_save'')','string','Save target');
        set(DIVA_x.figure.handles.button7,'callback','diva_gui(''targetsgui_reset'')','string','Reset target');
        DIVA_x.figure.thandles.button6=uicontrol('units','norm','position',[.41,.02,.09,.06],'style','pushbutton','string','Delete target','foregroundcolor','k','backgroundcolor',1-.5*(1-DIVA_x.color(1,:)),'fontweight','normal','callback','diva_gui(''targetsgui_delete'')');
        DIVA_x.figure.thandles.button9=uicontrol('units','norm','position',[.51,.02,.09,.06],'style','pushbutton','string','Combine target','foregroundcolor','k','backgroundcolor',1-.5*(1-DIVA_x.color(1,:)),'fontweight','normal','callback','diva_gui(''targetsgui_combine'')','tooltipstring','concatenates two targets');
        %DIVA_x.figure.handles.button7=uicontrol('units','norm','position',[.31,.02,.09,.06],'style','pushbutton','string','Reset target','foregroundcolor','k','backgroundcolor',1-.5*(1-DIVA_x.color(1,:)),'fontweight','normal','callback','diva_gui(''targetsgui_reset'')','tooltipstring','reset learned feedforward command to zero');
        
        DIVA_x.figure.thandles.text1=uicontrol('units','norm','position',[.025,.8,.125,.05],'style','text','string','Target name','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left');
        DIVA_x.figure.thandles.field1=uicontrol('units','norm','position',[.025,.75,.125,.05],'style','edit','string','','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','callback','diva_gui(''update_targetdown'');');
        DIVA_x.figure.thandles.text2=uicontrol('units','norm','position',[.025,.65,.125,.05],'style','text','string','Target duration (ms)','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left');
        DIVA_x.figure.thandles.field2=uicontrol('units','norm','position',[.025,.60,.125,.05],'style','edit','string','','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','callback','diva_gui(''update_targetdown'');');
        if ~DIVA_x.guioptions.editableduration, set(DIVA_x.figure.thandles.field2,'enable','off'); end
        DIVA_x.figure.thandles.text2b=[];%uicontrol('units','norm','position',[.05,.5,.1,.05],'style','text','string','Wrapper (ms)','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left');
        DIVA_x.figure.thandles.field2b=[];%uicontrol('units','norm','position',[.05,.45,.1,.05],'style','edit','string','','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','callback','diva_gui(''update_targetdown'');');
        DIVA_x.figure.thandles.text3=uicontrol('units','norm','position',[.025,.35,.125,.05],'style','text','string','Interpolation','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left');
        DIVA_x.figure.thandles.field3=uicontrol('units','norm','position',[.025,.30,.125,.05],'style','popupmenu','string',{'nearest','linear','spline'},'value',2,'backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','callback','diva_gui(''update_targetdown'');','tooltipstring','select method to interpolate target values outside or between control points (only applicable for dynamic targets)');
        DIVA_x.figure.thandles.text8=uicontrol('units','norm','position',[.025,.50,.125,.05],'style','text','string','Sampling','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left');
        DIVA_x.figure.thandles.field8=uicontrol('units','norm','position',[.025,.45,.125,.05],'style','popupmenu','string',{'sparse','fixed rate'},'value',1,'backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','callback','diva_gui(''update_targetdown'');','tooltipstring','select method to sample&learn targets ("sparse" defines&learns one target per segment; "fixed rate" defines&learns one target per 5ms window)');

        str={};fieldidx=[];value=[];
        for n0=1:numel(DIVA_x.params.Output),
            for n1=1:numel(DIVA_x.params.Output(n0).Plots_label),
                if numel(DIVA_x.params.Output(n0).Plots_dim{n1})==1
                    str{end+1}=DIVA_x.params.Output(n0).Plots_label{n1};
                    value(end+1)=(n0==1 & any(DIVA_x.params.Output(n0).Plots_dim{1}==DIVA_x.params.Output(n0).Plots_dim{n1})); %default to first plot in auditory representation
                    fieldidx=cat(2,fieldidx,[n0;DIVA_x.params.Output(n0).Plots_dim{n1}]);
                end
            end
        end
        DIVA_x.figure.thandles.text4=uicontrol('units','norm','position',[.2,.8,.1,.05],'style','text','string','Target field(s)','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left');
        DIVA_x.figure.thandles.field4=uicontrol('units','norm','position',[.2,.15,.1,.65],'style','listbox','string',str,'value',find(value),'backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','max',2,'callback','diva_gui(''update_targetup'');');
        
        DIVA_x.figure.thandles.text5=[];%uicontrol('units','norm','position',[.35,.8,.15,.05],'style','text','string','Control points (ms)','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','visible','off');
        DIVA_x.figure.thandles.field5=[];%uicontrol('units','norm','position',[.50,.8,.10,.05],'style','edit','string','','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','callback','diva_gui(''update_targetdown'');','tooltipstring','<HTML>Enter time (in ms) of one or several control points<br/> - enter a single value for static targets, or multiple values for dynamic targets<br/> - for each control point define the minimum and maximum target values for the selected field</HTML>','visible','off');
        DIVA_x.figure.thandles.buttonfield5=[];
        DIVA_x.figure.thandles.text6=[];%uicontrol('units','norm','position',[.35,.65,.25,.05],'style','text','string','Minimum value within target (for each control point)','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','visible','off');
        DIVA_x.figure.thandles.field6=[];%uicontrol('units','norm','position',[.35,.45,.25,.2],'style','edit','string','','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','max',2,'callback','diva_gui(''update_targetdown'');','visible','off');
        DIVA_x.figure.thandles.text7=[];%uicontrol('units','norm','position',[.35,.35,.25,.05],'style','text','string','Maximum value within target (for each control point)','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','visible','off');
        DIVA_x.figure.thandles.field7=[];%uicontrol('units','norm','position',[.35,.15,.25,.2],'style','edit','string','','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','max',2,'callback','diva_gui(''update_targetdown'');','visible','off');
        DIVA_x.figure.thandles.button2field5=[];
        DIVA_x.figure.thandles.frame8=[];
        DIVA_x.figure.thandles.text9=[];
        DIVA_x.figure.thandles.field9=[];
        
        if ~isfield(DIVA_x,'production'), DIVA_x.production='new@default'; end
        diva_gui('targetsgui_load',DIVA_x.production);
        
    case 'targetsgui_load'
        if nargin>1,
            DIVA_x.production=varargin{1};
            str=get(DIVA_x.figure.handles.list3,'string');
            idxvalue=strmatch(DIVA_x.production,str,'exact'); if isempty(idxvalue), idxvalue=1; end
            set(DIVA_x.figure.handles.list3,'value',idxvalue);
        else
            figure(DIVA_x.figure.handles.figure);
            str=get(DIVA_x.figure.handles.list3,'string');
            value=get(DIVA_x.figure.handles.list3,'value');
            DIVA_x.production=str{value};
        end
        if strcmp(DIVA_x.production,'new@default')
            DIVA_x.production_info=diva_targets('new','txt');
            names=get(DIVA_x.figure.thandles.field3,'string');
            DIVA_x.production_info.interpolation=names{get(DIVA_x.figure.thandles.field3,'value')};
            names=get(DIVA_x.figure.thandles.field8,'string');
            DIVA_x.production_info.sampling=names{get(DIVA_x.figure.thandles.field8,'value')};
            if isequal(DIVA_x.production_info.sampling,'sparse'), set(DIVA_x.figure.thandles.field3,'value',2,'enable','off'); else set(DIVA_x.figure.thandles.field3,'enable','on'); end
            set(DIVA_x.figure.thandles.button6,'enable','off');
        elseif strcmp(DIVA_x.production,'new@random')
            DIVA_x.production_info=diva_targets('random','txt');
            names=get(DIVA_x.figure.thandles.field3,'string');
            DIVA_x.production_info.interpolation=names{get(DIVA_x.figure.thandles.field3,'value')};
            names=get(DIVA_x.figure.thandles.field8,'string');
            DIVA_x.production_info.sampling=names{get(DIVA_x.figure.thandles.field8,'value')};
            if isequal(DIVA_x.production_info.sampling,'sparse'), set(DIVA_x.figure.thandles.field3,'value',2,'enable','off'); else set(DIVA_x.figure.thandles.field3,'enable','on'); end
            set(DIVA_x.figure.thandles.button6,'enable','off');
        else
            DIVA_x.production_info=diva_targets('load','txt',DIVA_x.production);
            DIVA_x.production_art=[];
            try, DIVA_x.production_art=diva_targets('load','mat',DIVA_x.production); end
            if ~isfield(DIVA_x.production_info,'wrapper'), DIVA_x.production_info.wrapper=0; end
            set(DIVA_x.figure.thandles.button6,'enable','on');
        end
        diva_gui update_targetup;
        DIVA_x.changed=0;
        
    case {'targetsgui_save','targetsgui_reset'}
        production_name=get(DIVA_x.figure.thandles.field1,'string');
        overwrite=strcmp(lower(option),'targetsgui_reset');
        if overwrite,
            answ=questdlg('Reset target to:','','last saved state','initial state','initial state');
            if isempty(answ), return; end
            if strcmp(answ,'last saved state')
                diva_gui targetsgui_load;
                return
            end
        end
        if isempty(production_name), errordlg('Enter production name field',''); return; end
        %DIVA_x.resetff=get(DIVA_x.figure.handles.button7,'value');
        diva_targets('save','txt',production_name,DIVA_x.production_info);
        diva_targets('save','mat',production_name,DIVA_x.production_info,overwrite);%,DIVA_x.resetff);
        try, if ~overwrite&~isempty(DIVA_x.production_art), diva_targets('save','art',production_name,DIVA_x.production_art.Art,DIVA_x.production_info); end; end
        DIVA_x.production_list=diva_targets('list');
        DIVA_x.production=production_name;
        value=DIVA_x.production;
        idxvalue=strmatch(value,DIVA_x.production_list,'exact'); if isempty(idxvalue), idxvalue=1; else idxvalue=idxvalue+2; end
        list=cat(1,{'new@default';'new@random'},DIVA_x.production_list);
        set(DIVA_x.figure.handles.list3,'string',list,'value',idxvalue);
        set(DIVA_x.figure.thandles.button6,'enable','on');
        DIVA_x.changed=0;
        
    case 'targetsgui_combine'
        hfig=figure('units','norm','position',[.4 .4 .3 .2],'menubar','none','numbertitle','off','name','Combine current target with new target','color','w');
        thandles.text1=uicontrol('units','norm','position',[.1,.8,.5,.1],'style','text','string','Transition duration (ms) :','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left');
        thandles.field1=uicontrol('units','norm','position',[.6,.8,.3,.1],'style','edit','string','40','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left');
        thandles.text2=uicontrol('units','norm','position',[.1,.6,.5,.1],'style','text','string','New Target name :','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left');
        thandles.field2=uicontrol('units','norm','position',[.6,.6,.3,.1],'style','popupmenu','string',DIVA_x.production_list,'backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left');
        thandles.text3=uicontrol('units','norm','position',[.1,.4,.5,.1],'style','text','string','New Target duration (ms) :','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left');
        thandles.field3=uicontrol('units','norm','position',[.6,.4,.3,.1],'style','edit','string','','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left');
        thandles.button1=uicontrol('units','norm','position',[.5,.05,.4,.2],'style','pushbutton','string','Add target','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','left','callback','uiresume(gcbf)');
        set(thandles.field2,'callback','str=get(gcbo,''string''); val=get(gcbo,''value''); h=get(gcbo,''userdata''); info=diva_targets(''load'',''txt'',str{val}); set(h,''string'',num2str(info.length));','userdata',thandles.field3);
        if ~isempty(DIVA_x.production_list), set(thandles.field3,'string',num2str(getfield(diva_targets('load','txt',DIVA_x.production_list{1}),'length'))); end
        uiwait(hfig);
        if ishandle(hfig)
            duration_transition=str2num(get(thandles.field1,'string'));
            production2=DIVA_x.production_list{get(thandles.field2,'value')};
            duration2=str2num(get(thandles.field3,'string'));
            production_info2=diva_targets('load','txt',production2);
            production_art1=[];
            try, production_art1=DIVA_x.production_art; end
            production_art2=[];
            try, production_art2=diva_targets('load','mat',production2); end
            [production_info,timeseries]=diva_targets('combine',DIVA_x.production_info,production_info2,duration_transition,duration2,production_art1,production_art2);
            production_info.name=[DIVA_x.production,'-',production2];
            DIVA_x.production_info=production_info;
            DIVA_x.production=production_info.name;
            DIVA_x.production_art=timeseries;
            delete(hfig);
            %diva_targets('save','txt',DIVA_x.production,DIVA_x.production_info);
            %diva_targets('save','mat',DIVA_x.production,DIVA_x.production_info,true);
            %try, diva_targets('save','art',DIVA_x.production,DIVA_x.production_art.Art,DIVA_x.production_info); end
            %DIVA_x.production_list=diva_targets('list');
            %list=cat(1,{'new@default';'new@random'},DIVA_x.production_list);
            %idxvalue=strmatch(DIVA_x.production,list,'exact'); if isempty(idxvalue), idxvalue=1; DIVA_x.production=list{1}; end
            %set(DIVA_x.figure.handles.list3,'string',list,'value',idxvalue);
            %set(DIVA_x.figure.thandles.button6,'enable','on');
            diva_gui update_targetup;
            DIVA_x.changed=1;
        end
        
    case 'targetsgui_refresh'
        DIVA_x.production_list=diva_targets('list');
        list=cat(1,{'new@default';'new@random'},DIVA_x.production_list);
        set(DIVA_x.figure.handles.list3,'string',list,'value',min(numel(list),get(DIVA_x.figure.handles.list3,'value')));
        diva_gui targetsgui_load
        
    case 'targetsgui_delete'
        diva_targets('delete',DIVA_x.production);
        DIVA_x.production_list=diva_targets('list');
        list=cat(1,{'new@default';'new@random'},DIVA_x.production_list);
        set(DIVA_x.figure.handles.list3,'string',list,'value',min(numel(list),get(DIVA_x.figure.handles.list3,'value')));
        diva_gui targetsgui_load
        
    case 'update_targetup'
        set(DIVA_x.figure.thandles.field1,'string',DIVA_x.production_info.name);
        set(DIVA_x.figure.thandles.field2,'string',num2str(DIVA_x.production_info.length));
        %set(DIVA_x.figure.thandles.field2b,'string',num2str(DIVA_x.production_info.wrapper));
        set(DIVA_x.figure.thandles.field3,'value',strmatch(DIVA_x.production_info.interpolation,get(DIVA_x.figure.thandles.field3,'string'),'exact'));
        if ~isfield(DIVA_x.production_info,'sampling'), DIVA_x.production_info.sampling='sparse'; end
        set(DIVA_x.figure.thandles.field8,'value',strmatch(DIVA_x.production_info.sampling,get(DIVA_x.figure.thandles.field8,'string'),'exact'));
        if isequal(DIVA_x.production_info.sampling,'sparse'), set(DIVA_x.figure.thandles.field3,'value',2,'enable','off'); else set(DIVA_x.figure.thandles.field3,'enable','on'); end
        fieldnames=get(DIVA_x.figure.thandles.field4,'string');
        fieldname={fieldnames{get(DIVA_x.figure.thandles.field4,'value')}};
        set(DIVA_x.figure.thandles.field5,'foregroundcolor','k');
        set(DIVA_x.figure.thandles.field6,'foregroundcolor','k');
        set(DIVA_x.figure.thandles.field7,'foregroundcolor','k');
        a=[]; b={}; c={}; ok=true(1,numel(fieldname));
        for n1=1:numel(fieldname)
            if n1==1, a=DIVA_x.production_info.([fieldname{n1},'_control']);
            elseif ~isequal(a,DIVA_x.production_info.([fieldname{n1},'_control'])), 
                if all(ok), disp(['warning: unequal control points across fields, displaying control points for first field only']); end
                ok(n1)=false; 
            end
            if ok(n1)
                b{end+1}=DIVA_x.production_info.([fieldname{n1},'_min']);
                c{end+1}=DIVA_x.production_info.([fieldname{n1},'_max']);
            end
            %b{end+1}=regexprep(num2str(DIVA_x.production_info.([fieldname{n1},'_min'])),'NaN','X');
            %c{end+1}=regexprep(num2str(DIVA_x.production_info.([fieldname{n1},'_max'])),'NaN','X');
            %if size(DIVA_x.production_info.([fieldname{n1},'_min']),2)~=size(a,2), set(DIVA_x.figure.thandles.field6,'foregroundcolor','r'); end
            %if size(DIVA_x.production_info.([fieldname{n1},'_max']),2)~=size(a,2), set(DIVA_x.figure.thandles.field7,'foregroundcolor','r'); end
        end
        if any(~ok), 
            fieldname=fieldname(ok);
            set(DIVA_x.figure.thandles.field4,'value',find(ismember(fieldnames,fieldname)));
            ok=ok(ok);
        end
        b=cat(1,b{:});
        c=cat(1,c{:});
        [b,c]=deal(abs(c-b)/2,(b+c)/2); % from (b,c) = (min,max) to (b,c) = (range,center)
        delete(DIVA_x.figure.thandles.field5(ishandle(DIVA_x.figure.thandles.field5)));DIVA_x.figure.thandles.field5=[]; 
        delete(DIVA_x.figure.thandles.buttonfield5(ishandle(DIVA_x.figure.thandles.buttonfield5)));DIVA_x.figure.thandles.buttonfield5=[]; 
        delete(DIVA_x.figure.thandles.field6(ishandle(DIVA_x.figure.thandles.field6)));DIVA_x.figure.thandles.field6=[]; 
        delete(DIVA_x.figure.thandles.field7(ishandle(DIVA_x.figure.thandles.field7)));DIVA_x.figure.thandles.field7=[]; 
        delete(DIVA_x.figure.thandles.text5(ishandle(DIVA_x.figure.thandles.text5)));DIVA_x.figure.thandles.text5=[]; 
        delete(DIVA_x.figure.thandles.text6(ishandle(DIVA_x.figure.thandles.text6)));DIVA_x.figure.thandles.text6=[]; 
        delete(DIVA_x.figure.thandles.text7(ishandle(DIVA_x.figure.thandles.text7)));DIVA_x.figure.thandles.text7=[]; 
        delete(DIVA_x.figure.thandles.frame8(ishandle(DIVA_x.figure.thandles.frame8)));DIVA_x.figure.thandles.frame8=[]; 
        delete(DIVA_x.figure.thandles.button2field5(ishandle(DIVA_x.figure.thandles.button2field5)));DIVA_x.figure.thandles.button2field5=[]; 
        delete(DIVA_x.figure.thandles.field9(ishandle(DIVA_x.figure.thandles.field9)));DIVA_x.figure.thandles.field9=[]; 
        delete(DIVA_x.figure.thandles.text9(ishandle(DIVA_x.figure.thandles.text9)));DIVA_x.figure.thandles.text9=[]; 
        DIVA_x.figure.thandles.button2field5collapsed=false(1,numel(a)-1);
        %if ~any(a<=0), a=[0 a]; b=[b(:,1) b]; c=[c(:,1) c]; end
        %if ~any(a>=DIVA_x.production_info.length), a=[a DIVA_x.production_info.length]; b=[b b(:,end)]; c=[c c(:,end)]; end
        DIVA_x.figure.thandles.text5=uicontrol('units','norm','position',[.31,.70,.13,.05],'style','text','string','segment duration (ms)','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','right');
        for n1=1:numel(a)-1
            DIVA_x.figure.thandles.field5(n1)=uicontrol('units','norm','position',[.45+.40*(n1-.5)/numel(a),.70,.40/numel(a),.05],'style','edit','string',num2str(a(n1+1)-a(n1)),'backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','center','callback',@(varargin)diva_gui('update_newduration',n1),'tooltipstring','<HTML>Duration (in ms) of each segment<br/> - enter 0 (or leave empty) to remove this segment<br/> - enter multiple duration values to partition this segment into multiple segments<br/> - note: changes in duration values will typically affect the total duration of the target</HTML>');
            DIVA_x.figure.thandles.button2field5(n1)=uicontrol('units','norm','position',[.45+.40*(n1)/numel(a)-0.01/2,.85,.01,.03],'style','pushbutton','string','-','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','center','callback',@(varargin)diva_gui('update_expandcollapse',n1),'tooltipstring','<HTML>expand/collapse control points</HTML>'); 
            %if ~isequalwithequalnans(b(:,n1+1),b(:,n1))||~isequalwithequalnans(c(:,n1+1),c(:,n1))||(n1>1&&DIVA_x.figure.thandles.button2field5collapsed(n1-1)), set(DIVA_x.figure.thandles.button2field5(n1),'visible','off'); 
            %elseif n1<=1||~DIVA_x.figure.thandles.button2field5collapsed(n1-1), DIVA_x.figure.thandles.button2field5collapsed(n1)=true;
            %end
        end
        if true||~DIVA_x.guioptions.editableduration, DIVA_x.figure.thandles.buttonfield5=uicontrol('units','norm','position',[.45+.40*(numel(a)-.5)/numel(a),.70,2*min(.02,1/2*.40/numel(a)),.05],'style','pushbutton','string','new','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','center','callback','diva_gui(''update_newsegment'');','tooltipstring','<HTML>Add a new segment after the last segment, extending the duration of this target<br/> - note: the new segment will be created for the selected target field(s) only, other fields will extend their last segment to accomodate the new total target duration</HTML>'); end
        DIVA_x.figure.thandles.text7=uicontrol('units','norm','position',[.31,.80,.13,.05],'style','text','string','target field(s) value','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','right');
        DIVA_x.figure.thandles.text6=uicontrol('units','norm','position',[.31,.75,.13,.05],'style','text','string','target field(s) range','backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','right');
        DIVA_x.figure.thandles.text9=uicontrol('units','norm','position',[.31,.65,.13,.05],'style','text','string','absolute time (ms)','backgroundcolor',DIVA_x.color(2,:),'foregroundcolor',.5*[1 1 1],'horizontalalignment','right');
        for n1=1:numel(a)
            DIVA_x.figure.thandles.field7(n1)=uicontrol('units','norm','position',[.45+.40*(n1-1)/numel(a)+.05/2*.40/numel(a),.80,.95*.40/numel(a),.05],'style','edit','string',regexprep(num2str(c(:,n1)'),{'NaN','\s+'},{'X',' '}),'backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','center','max',1,'callback','diva_gui(''update_targetdown'');','tooltipstring','<HTML>Enter the point target value of the target field(s) during each segment<br/> - enter X to indicate the entire range of this parameter</HTML>');
            DIVA_x.figure.thandles.field6(n1)=uicontrol('units','norm','position',[.45+.40*(n1-1)/numel(a)+.05/2*.40/numel(a),.75,.95*.40/numel(a),.05],'style','edit','string',regexprep(num2str(b(:,n1)'),{'NaN','\s+'},{'X',' '}),'backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','center','max',1,'callback','diva_gui(''update_targetdown'');','tooltipstring','<HTML>Enter the tolerance/range of the target field(s) during each segment (valid target values would range between value-range to value+range)<br/></HTML>');
            DIVA_x.figure.thandles.field9(n1)=uicontrol('units','norm','position',[.45+.40*(n1-.5)/numel(a)-min(.02,.95/2*.40/numel(a)),.65,2*min(.02,.95/2*.40/numel(a)),.05],'style','edit','string',num2str(a(n1)),'backgroundcolor',DIVA_x.color(2,:),'foregroundcolor',.5*[1 1 1],'horizontalalignment','center','max',1,'callback','diva_gui(''update_newtime'');','tooltipstring','<HTML>Absolute time (ms) of each boundary between two adjacent segments<br/> - leave empty to remove this boundary (merge the two corresponding adjacent segments)<br/> - note: changes in these values do not typically affect the total duration of the target</HTML>');
            if n1==1||n1==numel(a), set(DIVA_x.figure.thandles.field9(n1),'enable','off'); end
            %DIVA_x.figure.thandles.field9(n1)=uicontrol('units','norm','position',[.45+.40*a(n1)/max(a)-.02,.11,.04,.05],'style','edit','string',num2str(a(n1)),'backgroundcolor',DIVA_x.color(2,:),'horizontalalignment','center','max',1,'callback','diva_gui(''update_targetdown_control'');');
        end
        
        %set(DIVA_x.figure.thandles.field5,'string',num2str(a));
        %set(DIVA_x.figure.thandles.field6,'string',b);
        %set(DIVA_x.figure.thandles.field7,'string',c);
        if ok, 
            DIVA_x.params.Plots.Output={[],[]};
            DIVA_x.params.Plots.Input={[]};
            dims=cell(1,numel(DIVA_x.params.Output)); ndims=dims;
            for n2=1:numel(DIVA_x.params.Output),
                ndims{n2}=cellfun('length',DIVA_x.params.Output(n2).Plots_dim);
                dims{n2}=zeros([numel(fieldname),numel(DIVA_x.params.Output(n2).Plots_dim)]);
                for n1=1:numel(fieldname)
                    idx=strmatch(fieldname{n1},DIVA_x.params.Output(n2).Plots_label,'exact');
                    if ~isempty(idx), 
                        idx=idx(1);
                        dimsidx=DIVA_x.params.Output(n2).Plots_dim{idx};
                        for n3=1:numel(DIVA_x.params.Output(n2).Plots_dim),
                            if all(ismember(dimsidx,DIVA_x.params.Output(n2).Plots_dim{n3})),
                                dims{n2}(n1,n3)=1;
                            end
                        end
                    end
                end
                mdims=(ndims{n2}==sum(dims{n2},1));
                [sndims,idx]=sort(ndims{n2}.*mdims,'descend');
                for n1=1:numel(idx),
                    if mdims(idx(n1)),
                        DIVA_x.params.Plots.Output{n2}=cat(2,DIVA_x.params.Plots.Output{n2},idx(n1)); 
                        dims{n2}(dims{n2}(:,idx(n1))>0,:)=0;
                        mdims=(ndims{n2}==sum(dims{n2},1));
                    end
                end
            end
            diva_gui update_expandcollapse
            diva_gui('init_inputoutputplots',1,'ylim');
            diva_gui update_targetplot; 
        end
        DIVA_x.figure.thandles.frame8=axes('units','norm','position',[.45,.175,.40,.475]);
        plot([((1:numel(a))-.5)/numel(a);a/max(a);a/max(a)],repmat([1;.8;0],1,numel(a)),'k-','linewidth',2,'parent',DIVA_x.figure.thandles.frame8);
        set(DIVA_x.figure.thandles.frame8,'visible','off','xlim',[0,1],'ylim',[0,1]);
        DIVA_x.changed=1;
        if isempty(DIVA_x.production_info.name), set([DIVA_x.figure.handles.button5,DIVA_x.figure.handles.button7],'enable','off'); else set([DIVA_x.figure.handles.button5,DIVA_x.figure.handles.button7],'enable','on'); end

    case 'update_expandcollapse'
        na=numel(DIVA_x.figure.thandles.field7);
        if numel(varargin)>0, DIVA_x.figure.thandles.button2field5collapsed(varargin{1})=~DIVA_x.figure.thandles.button2field5collapsed(varargin{1}); 
        else
            for n1=1:na-1
                b1=get(DIVA_x.figure.thandles.field7(n1),'string');
                c1=get(DIVA_x.figure.thandles.field6(n1),'string');
                b2=get(DIVA_x.figure.thandles.field7(n1+1),'string');
                c2=get(DIVA_x.figure.thandles.field6(n1+1),'string');
                if ~isequal(b2,b1)||~isequal(c2,c1)||(n1>1&&DIVA_x.figure.thandles.button2field5collapsed(n1-1)), DIVA_x.figure.thandles.button2field5collapsed(n1)=false; set(DIVA_x.figure.thandles.button2field5(n1),'visible','off');
                elseif n1<=1||~DIVA_x.figure.thandles.button2field5collapsed(n1-1), DIVA_x.figure.thandles.button2field5collapsed(n1)=true; set(DIVA_x.figure.thandles.button2field5(n1),'visible','on');
                elseif DIVA_x.figure.thandles.button2field5collapsed(n1), set(DIVA_x.figure.thandles.button2field5(n1),'visible','on');
                else set(DIVA_x.figure.thandles.button2field5(n1),'visible','off');
                end
            end
        end
        for n1=1:na
            if n1<=length(DIVA_x.figure.thandles.button2field5collapsed)
                if DIVA_x.figure.thandles.button2field5collapsed(n1), set(DIVA_x.figure.thandles.button2field5(n1),'string','+');
                else set(DIVA_x.figure.thandles.button2field5(n1),'string','-');
                end
            end
            if n1<=length(DIVA_x.figure.thandles.button2field5collapsed)&&DIVA_x.figure.thandles.button2field5collapsed(n1) % collapsed (show centered-right)
                set(DIVA_x.figure.thandles.field7(n1),'position',[.45+.40*(n1-.5)/na,.80,.40/na,.05],'visible','on');
                set(DIVA_x.figure.thandles.field6(n1),'position',[.45+.40*(n1-.5)/na,.75,.40/na,.05],'visible','on');
            elseif n1>1&&DIVA_x.figure.thandles.button2field5collapsed(n1-1) % collapsed (not shown)
                set(DIVA_x.figure.thandles.field7(n1),'position',[.45+.40*(n1-1)/na+.05/2*.40/na,.80,.95*.40/na,.05],'visible','off');
                set(DIVA_x.figure.thandles.field6(n1),'position',[.45+.40*(n1-1)/na+.05/2*.40/na,.75,.95*.40/na,.05],'visible','off');
            else % do not collapse
                set(DIVA_x.figure.thandles.field7(n1),'position',[.45+.40*(n1-1)/na+.05/2*.40/na,.80,.95*.40/na,.05],'visible','on');
                set(DIVA_x.figure.thandles.field6(n1),'position',[.45+.40*(n1-1)/na+.05/2*.40/na,.75,.95*.40/na,.05],'visible','on');
            end
        end
        
    case {'update_targetdown','update_newsegment','update_newduration','update_newtime'}
        DIVA_x.production_info.name=get(DIVA_x.figure.thandles.field1,'string');
        doextend=true;
        if DIVA_x.guioptions.editableduration, 
            value=str2num(get(DIVA_x.figure.thandles.field2,'string')); 
            if value~=DIVA_x.production_info.length, doextend=false; end
        else value=[];
        end
        if isempty(value), value=DIVA_x.production_info.length; set(DIVA_x.figure.thandles.field2,'string',num2str(value)); end
        DIVA_x.production_info.length=value;
        %value=str2num(get(DIVA_x.figure.thandles.field2b,'string')); if isempty(value), value=DIVA_x.production_info.wrapper; set(DIVA_x.figure.thandles.field2b,'string',num2str(value)); end
        %DIVA_x.production_info.wrapper=value;
        names=get(DIVA_x.figure.thandles.field3,'string');
        DIVA_x.production_info.interpolation=names{get(DIVA_x.figure.thandles.field3,'value')};
        names=get(DIVA_x.figure.thandles.field8,'string');
        DIVA_x.production_info.sampling=names{get(DIVA_x.figure.thandles.field8,'value')};
        if isequal(DIVA_x.production_info.sampling,'sparse'), set(DIVA_x.figure.thandles.field3,'value',2,'enable','off'); else set(DIVA_x.figure.thandles.field3,'enable','on'); end
        fieldnames=get(DIVA_x.figure.thandles.field4,'string');
        selectedfields=get(DIVA_x.figure.thandles.field4,'value');
        fieldname={fieldnames{selectedfields}};
        ok=1;
        fixedtime=false;%DIVA_x.guioptions.editableduration||numel(selectedfields)<numel(fieldnames);
        forcerefresh=false;
        onset=0;
        a=onset;
        if strcmpi(option,'update_newsegment')
            a=DIVA_x.production_info.([fieldname{1},'_control']);
            i0=[1:numel(a) numel(a)];
            a(end+1)=DIVA_x.production_info.length+40;
            for n1=1:numel(fieldname),
                DIVA_x.production_info.([fieldname{n1},'_control'])=a;
                DIVA_x.production_info.([fieldname{n1},'_min'])=DIVA_x.production_info.([fieldname{n1},'_min'])(:,i0);
                DIVA_x.production_info.([fieldname{n1},'_max'])=DIVA_x.production_info.([fieldname{n1},'_max'])(:,i0);
            end
            doextend=false; 
        elseif strcmpi(option,'update_newtime')
            a0=[]; i0=[]; a=[];
            set(DIVA_x.figure.thandles.field9,'foregroundcolor',.5*[1 1 1]);
            for nval=1:numel(DIVA_x.figure.thandles.field9)
                temp=char(get(DIVA_x.figure.thandles.field9(nval),'string'));
                doffset=min(DIVA_x.production_info.length,max(0,str2num(temp)));
                if isempty(temp)&&nval>1, doffset=a0(end);
                elseif isempty(temp), doffset=0;
                elseif numel(doffset)~=1, ok=0;set(DIVA_x.figure.thandles.field9(nval),'foregroundcolor','r');
                end
                a0=[a0 doffset(:)'];
                i0=[i0 repmat(nval,1,numel(doffset))];
                a=[a max(doffset)];
            end
            if ok
                if all(diff(a)>0)
                    DIVA_x.production_info=diva_targets('resampletime',DIVA_x.production_info,DIVA_x.production_info.([fieldname{1},'_control']),a);
                else
                    for n1=1:numel(fieldname),
                        DIVA_x.production_info.([fieldname{n1},'_control'])=a;
                    end
                    for n1=1:numel(fieldname),
                        DIVA_x.production_info.([fieldname{n1},'_control'])=a0;
                        DIVA_x.production_info.([fieldname{n1},'_min'])=DIVA_x.production_info.([fieldname{n1},'_min'])(:,i0);
                        DIVA_x.production_info.([fieldname{n1},'_max'])=DIVA_x.production_info.([fieldname{n1},'_max'])(:,i0);
                    end
                end
                forcerefresh=true;
            end
        elseif strcmpi(option,'update_newduration')
            a0=0; i0=1;
            set(DIVA_x.figure.thandles.field5,'foregroundcolor','k');
            for nval=2:numel(DIVA_x.figure.thandles.field6)
                temp=char(get(DIVA_x.figure.thandles.field5(nval-1),'string'));
                doffset=max(0,str2num(temp));
                if isempty(temp), doffset=0;
                elseif isempty(doffset), ok=0;set(DIVA_x.figure.thandles.field5(nval-1),'foregroundcolor','r');
                end
                a0=[a0 onset+cumsum(doffset(:)')];
                i0=[i0 repmat(nval,1,numel(doffset))];
                onset=onset+sum(doffset);
                a=[a onset];
            end
            if ok
                DIVA_x.production_info=diva_targets('resampletime',DIVA_x.production_info,DIVA_x.production_info.([fieldname{1},'_control']),a);
                if numel(a0)~=numel(a)
                    for n1=1:numel(fieldname),
                        DIVA_x.production_info.([fieldname{n1},'_control'])=a0;
                        DIVA_x.production_info.([fieldname{n1},'_min'])=DIVA_x.production_info.([fieldname{n1},'_min'])(:,i0);
                        DIVA_x.production_info.([fieldname{n1},'_max'])=DIVA_x.production_info.([fieldname{n1},'_max'])(:,i0);
                    end
                    a=a0;
                end
                forcerefresh=true;
            end
        else
            for nval=1:numel(DIVA_x.figure.thandles.field6)
                if nval>1,
                    doffset=str2num(char(get(DIVA_x.figure.thandles.field5(nval-1),'string')));
                    tonset=onset+doffset;
                    if fixedtime
                        if strcmpi(option,'update_newsegment')&&nval==numel(DIVA_x.figure.thandles.field6), tonset=.5*onset+.5*DIVA_x.production_info.length; % adds new control point
                        elseif doffset==0, doextend=false; % removes control point (while fixing total length)
                        elseif tonset>=DIVA_x.production_info.length, forcerefresh=true; tonset=onset+nval/numel(DIVA_x.figure.thandles.field6)*(DIVA_x.production_info.length-onset); % control point beyond target duration
                        elseif tonset<DIVA_x.production_info.length&&nval==numel(DIVA_x.figure.thandles.field6), forcerefresh=true; tonset=DIVA_x.production_info.length; % control points end short of target duration
                        end
                    end
                    onset=tonset;
                    a=[a onset];
                end
                valuec=str2num(char(regexprep(get(DIVA_x.figure.thandles.field7(nval),'string'),'X','NaN')));
                valueb=str2num(char(regexprep(get(DIVA_x.figure.thandles.field6(nval),'string'),'X','NaN')));
                valueb(isnan(valueb))=0;
                [valueb,valuec]=deal(valuec-valueb,valuec+valueb); % from (b,c) = (range,center) to (b,c) = (min,max)
                minvalue=min(valueb,valuec);
                maxvalue=max(valueb,valuec);
                minvalue(isnan(valueb))=nan;
                maxvalue(isnan(valuec))=nan;
                valueb=minvalue;
                valuec=maxvalue;
                if isempty(onset),
                    ok=0;set(DIVA_x.figure.thandles.field5(nval-1),'foregroundcolor','r');
                else
                    if nval>1, set(DIVA_x.figure.thandles.field5(nval-1),'foregroundcolor','k'); end
                    for n1=1:numel(fieldname),
                        DIVA_x.production_info.([fieldname{n1},'_control'])(nval)=onset;
                    end
                end
                if isempty(valueb)||numel(valueb)~=numel(fieldname),
                    ok=0;set(DIVA_x.figure.thandles.field6(nval),'foregroundcolor','r');
                else
                    set(DIVA_x.figure.thandles.field6(nval),'foregroundcolor','k');
                    if (nval<=length(DIVA_x.figure.thandles.button2field5collapsed)&&DIVA_x.figure.thandles.button2field5collapsed(nval))||~(nval>1&&DIVA_x.figure.thandles.button2field5collapsed(nval-1))
                        for n1=1:numel(fieldname),
                            DIVA_x.production_info.([fieldname{n1},'_min'])(nval)=valueb(n1);
                            if nval<=length(DIVA_x.figure.thandles.button2field5collapsed)&&DIVA_x.figure.thandles.button2field5collapsed(nval) % collapsed (show centered-right)
                                DIVA_x.production_info.([fieldname{n1},'_min'])(nval+1)=valueb(n1);
                            end
                        end
                    end
                end
                if isempty(valuec)||numel(valuec)~=numel(fieldname),
                    ok=0;set(DIVA_x.figure.thandles.field7,'foregroundcolor','r');
                else
                    set(DIVA_x.figure.thandles.field7,'foregroundcolor','k');
                    if (nval<=length(DIVA_x.figure.thandles.button2field5collapsed)&&DIVA_x.figure.thandles.button2field5collapsed(nval))||~(nval>1&&DIVA_x.figure.thandles.button2field5collapsed(nval-1))
                        for n1=1:numel(fieldname),
                            DIVA_x.production_info.([fieldname{n1},'_max'])(nval)=valuec(n1);
                            if nval<=length(DIVA_x.figure.thandles.button2field5collapsed)&&DIVA_x.figure.thandles.button2field5collapsed(nval) % collapsed (show centered-right)
                                DIVA_x.production_info.([fieldname{n1},'_max'])(nval+1)=valuec(n1);
                            end
                        end
                    end
                end
                if ok
                    [valueb,valuec]=deal((valuec-valueb)/2,(valuec+valueb)/2); % from (b,c) = (min,max) to (b,c) = (range,center)
                    set(DIVA_x.figure.thandles.field6(nval),'string',regexprep(num2str(valueb(:)'),{'NaN','\s+'},{'X',' '}));
                    set(DIVA_x.figure.thandles.field7(nval),'string',regexprep(num2str(valuec(:)'),{'NaN','\s+'},{'X',' '}));
                    if nval<=length(DIVA_x.figure.thandles.button2field5collapsed)&&DIVA_x.figure.thandles.button2field5collapsed(nval) % collapsed (show centered-right)
                        set(DIVA_x.figure.thandles.field6(nval+1),'string',regexprep(num2str(valueb(:)'),{'NaN','\s+'},{'X',' '}));
                        set(DIVA_x.figure.thandles.field7(nval+1),'string',regexprep(num2str(valuec(:)'),{'NaN','\s+'},{'X',' '}));
                    end
                end
            end
        end
        if ok            
            if ~fixedtime,
            	if 0&&strcmpi(option,'update_newsegment'), DIVA_x.production_info.length=DIVA_x.production_info.length+40; % add new segment to all target variables
                else, DIVA_x.production_info.length=max(a); % adapts total duration
                end
            end
            bak=DIVA_x.production_info;
            DIVA_x.production_info=diva_targets('format',DIVA_x.production_info,doextend);
            if forcerefresh||~isequalwithequalnans(DIVA_x.production_info,bak)
                diva_gui update_targetup;
            else
                %DIVA_x.production_info.length=max(a);
                %set(DIVA_x.figure.thandles.field2,'string',num2str(DIVA_x.production_info.length));
                diva_gui update_expandcollapse
                diva_gui update_targetplot;
                if ~isempty(DIVA_x.figure.thandles.frame8)&&ishandle(DIVA_x.figure.thandles.frame8),
                    cla(DIVA_x.figure.thandles.frame8);
                    plot([((1:numel(a))-.5)/numel(a);a/max(a);a/max(a)],repmat([1;.8;0],1,numel(a)),'k-','linewidth',2,'parent',DIVA_x.figure.thandles.frame8);
                    set(DIVA_x.figure.thandles.frame8,'visible','off','xlim',[0,1],'ylim',[0,1]);
                end
            end
            %drawnow
        end
        DIVA_x.changed=1;
        if isempty(DIVA_x.production_info.name), set([DIVA_x.figure.handles.button5,DIVA_x.figure.handles.button7],'enable','off'); else set([DIVA_x.figure.handles.button5,DIVA_x.figure.handles.button7],'enable','on'); end

    case 'update_targetplot'
        [timeseries,time]=diva_targets('timeseries',DIVA_x.production_info);
        timeseries.AudSom_min=cat(2,timeseries.Aud_min,timeseries.Som_min);
        timeseries.AudSom_max=cat(2,timeseries.Aud_max,timeseries.Som_max);
        for n2=1:numel(DIVA_x.params.Plots_.Output.plotindex),
            cla(DIVA_x.figure.handles.ax2{1}(n2));
            hold(DIVA_x.figure.handles.ax2{1}(n2),'on');
            n0=DIVA_x.params.Plots_.Output.setindex(n2);
            n1=DIVA_x.params.Plots_.Output.plotindex(n2);
            idxdims=DIVA_x.params.Output(n0).Plots_dim{n1};
            if n0>1, idxdims=idxdims+sum(cat(2,DIVA_x.params.Output(1:n0-1).Dimensions)); end
            for n3=1:numel(idxdims),
                patch([timeseries.time;flipud(timeseries.time)],[timeseries.AudSom_max(:,idxdims(n3));flipud(timeseries.AudSom_min(:,idxdims(n3)))],'k','facecolor',.9*[1,1,1],'edgecolor',.8*[1,1,1],'parent',DIVA_x.figure.handles.ax2{1}(n2));
            end
            if ~isempty(timeseries.time)&&timeseries.time(end)>0, set(DIVA_x.figure.handles.ax2{1}(n2),'xlim',[0,timeseries.time(end)]); end
            if 1, plot(repmat(time(:)',2,1),repmat(get(DIVA_x.figure.handles.ax2{1}(n2),'ylim')',1,numel(time)),'k:','color',.5*[1 1 1],'linewidth',2,'parent',DIVA_x.figure.handles.ax2{1}(n2)); end
            hold(DIVA_x.figure.handles.ax2{1}(n2),'off');
        end
        
end
        
        
end




