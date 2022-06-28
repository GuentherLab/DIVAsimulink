function varargout=diva_vocaltract(block,varargin)
global DIVA_x
DIVA_x.debug=0;

  if ~nargin,
      if ~DIVA_x.debug
          Nart=13;
          Input=struct(...
              'Name','Articulatory',...
              'Dimensions',Nart,...
              'Range',repmat([-1,1],[Nart,1]),...
              'Scale',ones(Nart,1),...
              'Default',[repmat([-1,1],[10,1]);-1,1;-1,1;-1,1],...
              'DefaultSilence',[repmat([-1,1],[10,1]);-1,1;-1,-.5;-1,1],...
              'DefaultSound',[repmat([-1,1],[10,1]);-1,1;0,1;-1,1],...
              'BlockDiagonal',bsxfun(@eq,[ones(1,10),2,3,4],[ones(1,10),2,3,4]'),...
              'Plots_dim',{[{1:10},num2cell(1:10),{11:13},num2cell(11:13)]},...
              'Plots_label',{[{'VocalTract'},{'Jaw','Lip_opening','Lip_protrusion','Soft_palate','Larynx_height','Tongue_1','Tongue_2','Tongue_3','Tongue_4','Tongue_5','Glottis','Testion','Pressure','Voicing'}]} );
          Output1=struct(...
              'Name','Auditory',...
              'Dimensions',4,...
              'Range',[0,200;0,1000;0*500,3000;0*2000,4000],...
              'Scale',[100,500,1500,3000]',...
              'Default',[0,200;0,1000;0*500,3000;0*2000,4000],...
              'DefaultSilence',[0,200;0,1000;0*500,3000;0*2000,4000],...
              'DefaultSound',[0,200;0,1000;500,3000;2000,4000],...
              'Plots_dim',{{2:4,1,2,3,4}},...ls
              'Plots_label',{{'Formants','F0','F1','F2','F3'}} );
          if diva_synth('artinsom') % adds afferent copy of Articulatory INPUT dimensions to Somatosensory OUTPUT representation
              Output2=struct(...
                  'Name','Somatosensory',...
                  'Dimensions',6+Nart,...
                  'Range',repmat([-1,1],[6+Nart,1]),...
                  'Scale',ones(6+Nart,1),...
                  'Default',[repmat([-1,-.10],[6,1]);repmat([-1,1],[10,1]);-1,1;.75,1;.75,1],...
                  'DefaultSilence',[repmat([-1,1],[6,1]);repmat([-1,1],[10,1]);-1,1;-1,-.5;-1,1],...
                  'DefaultSound',[repmat([-1,-.10],[6,1]);repmat([-1,1],[10,1]);-1,1;.75,1;.75,1],...
                  'Plots_dim',{[{1:6,6+(1:Nart)},num2cell(1:6+Nart)]},...
                  'Plots_label',{[{'PlaceofArt','Articulators','PA_pharyngeal','PA_uvular','PA_velar','PA_palatal','PA_alveolardental','PA_labial'}, regexprep(Input.Plots_label([1+(1:10),12+(1:3)]),'.*','ART_$0')]} );
              
              % note: how to convert old target .mat files 
%               if 0
%                   load(filename,'timeseries');
%                   timeseries.Som_min=[timeseries.Som_min(:,1:6), repmat(-1,size(timeseries.Som_min,1),Nart-2), timeseries.Som_min(:,7:8)];
%                   timeseries.Som_max=[timeseries.Som_max(:,1:6), repmat(1,size(timeseries.Som_max,1),Nart-2), timeseries.Som_max(:,7:8)];
%                   save(filename,'timeseries');
%               end
          else
              Output2=struct(...
                  'Name','Somatosensory',...
                  'Dimensions',8,...
                  'Range',repmat([-1,1],[8,1]),...
                  'Scale',ones(8,1),...
                  'Default',[repmat([-1,-.10],[6,1]);.75,1;.75,1],...
                  'DefaultSilence',[repmat([-1,1],[6,1]);-1,-.5;-1,1],...
                  'DefaultSound',[repmat([-1,-.10],[6,1]);.75,1;.75,1],...
                  'Plots_dim',{{1:6,7,8,1,2,3,4,5,6}},...
                  'Plots_label',{{'PlaceofArt','pressure','voicing','PA_pharyngeal','PA_uvular','PA_velar','PA_palatal','PA_alveolardental','PA_labial'}} );
          end
          varargout{1}=struct(...
              'dosound',1,...
              'Input',Input,... %;arrayfun(@(n)sprintf('vt%d',n),1:10,'uni',0),{'tension','pressure','voicing'}]} ),...
              'Output',[...
                Output1,...
                Output2]);
              
      else
          Nart=4;
          varargout{1}=struct(...
              'dosound',0,...
              'Input',struct(...
              'Name','Motor',... %'Articulatory',...
              'Dimensions',Nart,...
              'Range',repmat([-2,2],[Nart,1]),...
              'Scale',ones(Nart,1),...
              'Plots_dim',{cat(2,{1:Nart},mat2cell(1:Nart,1,ones(1,Nart)))},...
              'Plots_label',{cat(1,{'Motor'},cellstr([repmat('motor_',[Nart,1]),num2str((1:Nart)')]))} ),...
              'Output',[...
              struct(...
              'Name','Spatial',...
              'Dimensions',2,...
              'Range',repmat([-5,5],[2,1]),...
              'Scale',ones(2,1),...
              'Default',repmat([-5,5],[2,1]),...
              'Plots_dim',{{1:2,1,2}},...
              'Plots_label',{{'Spatial','spatial_x','spatial_y'}} ),...
              struct(...
              'Name','Somatosensory',...
              'Dimensions',Nart,...
              'Range',repmat([-5,5],[Nart,1]),...
              'Scale',ones(Nart,1),...
              'Default',repmat([-5,5],[Nart,1]),...
              'Plots_dim',{cat(2,{1:Nart},mat2cell(1:Nart,1,ones(1,Nart)))},...
              'Plots_label',{cat(1,{'Somatosensory'},cellstr([repmat('somatosensory_',[Nart,1]),num2str((1:Nart)')]))} )]);
      end
  elseif ischar(block)
      switch(lower(block)),
          case 'auditory'
              if numel(varargin)>=3, varargin{3}=false; end
              [varargout{1},nill,varargout{2}]=diva_vocaltractcompute(varargin{:});
          case 'somatosensory'
              if numel(varargin)>=3, varargin{3}=true; end
              [nill,varargout{1},varargout{2}]=diva_vocaltractcompute(varargin{:});
          case 'somatosensory&aperture'
              if numel(varargin)>=3, varargin{3}=true; end
              [nill,out{1},out{2}]=diva_vocaltractcompute(varargin{:});
              ht=max(-out{1}(1:6)); % note: assumes first 6 som variables are PA_*
              ht=max(0,ht./(1-exp(-32*ht))); % ~max(0,ht) but smooth around 0
              varargout={cat(1,out{1},ht),out{2}};
          case 'auditory&somatosensory'
              if numel(varargin)>=3, varargin{3}=true; end
              [out{1},out{2},out{3}]=diva_vocaltractcompute(varargin{:});
              varargout={cat(1,out{1:2}),out{3}};
          case 'auditory&aperture'
              if numel(varargin)>=3, varargin{3}=true; end
              [out{1},out{2},out{3}]=diva_vocaltractcompute(varargin{:});
              ht=max(-out{2}(1:6)); % note: assumes first 6 som variables are PA_*
              ht=max(0,ht./(1-exp(-32*ht))); % ~max(0,ht) but smooth around 0
              varargout={cat(1,out{1},ht),out{3}};
          case 'formant'
              if numel(varargin)>=3, varargin{3}=false; end
              [varargout{1},nill,varargout{2}]=diva_vocaltractcompute(varargin{:});
              varargout{1}=varargout{1}.*DIVA_x.params.Output(1).Scale;
          case 'formant&somatosensory'
              if numel(varargin)>=3, varargin{3}=true; end
              [out{1},out{2},out{3}]=diva_vocaltractcompute(varargin{:});
              out{1}=out{1}.*DIVA_x.params.Output(1).Scale;
              out{2}=out{2}.*DIVA_x.params.Output(2).Scale;
              varargout={cat(1,out{1:2}),out{3}};
          case 'formant&aperture'
              if numel(varargin)>=3, varargin{3}=true; end
              [out{1},out{2},out{3}]=diva_vocaltractcompute(varargin{:});
              out{1}=out{1}.*DIVA_x.params.Output(1).Scale;
              ht=max(-out{2}(1:6)); % note: assumes first 6 som variables are PA_*
              ht=max(0,ht./(1-exp(-32*ht))); % ~max(0,ht) but smooth around 0
              varargout={cat(1,out{1},ht),out{3}};
          case 'output'
              [varargout{1:nargout}]=diva_vocaltractcompute(varargin{:});
          case 'base'
              varargout{1}=eye(DIVA_x.params.Input.Dimensions);
%               Q=randn(DIVA_x.params.Input.Dimensions);
%               if isfield(DIVA_x.params.Input,'BlockDiagonal')
%                   Q=Q.*DIVA_x.params.Input.BlockDiagonal;
%               end
%               varargout{1}=orth(Q);
          case 'pseudoinv'
              varargout{1}=diva_vocaltractpseudoinv(varargin{:});
          otherwise
              error(['unrecognized option ',lower(block)]);
              
      end
  else
      % Level-2 M file S-Function.
      setup(block);
  end
end

%% Initialization   
function setup(block)

  params=diva_vocaltract;
%   % Register number of dialog parameters   
%   block.NumDialogPrms = 4;
%   block.DialogPrmsTunable = {'Nontunable','Nontunable','Nontunable','Nontunable'};

  % Register number of input and output ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 2;

  % Setup functional port properties to dynamically inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = params.Input.Dimensions;
  block.InputPort(1).DirectFeedthrough = true;
  block.OutputPort(1).Dimensions       = params.Output(1).Dimensions;
  block.OutputPort(2).Dimensions       = params.Output(2).Dimensions;
  
  % Set block sample time to discrete
  block.SampleTimes = [-1 0];
  
  % Register methods
  block.RegBlockMethod('SetInputPortSamplingMode',@SetInputSampling);
  %block.RegBlockMethod('SetInputPortDimensions',  @SetInputDims);
  block.RegBlockMethod('Outputs',                 @Output);  
  
end


function SetInputSampling(block, port, dm)
    block.InputPort(port).SamplingMode= dm;
    block.OutputPort(1).SamplingMode= dm;
    block.OutputPort(2).SamplingMode= dm;
end
% function SetInputDims(block, port, dm)
%     block.InputPort(port).Dimensions = dm;
%     %if port==1, block.OutputPort(1).Dimensions = dm; end
% end



%% Output & Update equations   
function Output(block)
persistent t lastx
if isempty(t),t=0;end
t=t+1;

  % system output
  x=block.InputPort(1).Data;
  %if all(x==0)&~isempty(lastx), x=lastx; end
  [y,z]=diva_vocaltractcompute(x,rem(t,10)==1);
  lastx=x;

  block.OutputPort(1).Data = y;
  block.OutputPort(2).Data = z;

end


function [y,z,p0]=diva_vocaltractcompute(x,dodisp,needsom)
global DIVA_x;
if nargin<2||isempty(dodisp), dodisp=0; end
if nargin<3||isempty(needsom), needsom=true; end
dodisp=false; % note: removed real-time vt display
  if ~DIVA_x.debug
      x=x.*DIVA_x.params.Input.Scale;
      if needsom, 
          [y,z,Outline,p0]=diva_synth(x);
      else
          [y,z,Outline,p0]=diva_synth(x,'aud');
      end
      y=y./DIVA_x.params.Output(1).Scale;
      if ~isempty(z), z=z./DIVA_x.params.Output(2).Scale; end
%       if nargout==1&&~dodisp
%           y=diva_synth(x);
%           y=y./DIVA_x.params.Output(1).Scale;
%       else
%           [y,z,Outline]=diva_synth(x);
%           y=y./DIVA_x.params.Output(1).Scale;
%           z=z./DIVA_x.params.Output(2).Scale;
%       end
      
      if DIVA_x.gui&&nargin>1&&dodisp % display vt
          if dodisp==-1, % initialize display
              DIVA_x.figure.handles.h1=plot(nan,nan,'k','color',.75*DIVA_x.color(2,:),'linewidth',3);
              %hold on; DIVA_x.figure.handles.h1=[plot(nan,nan,'k','color',.75*DIVA_x.color(2,:),'linewidth',4);plot(nan,nan,'w-','linewidth',2)]; hold off
              axis equal; 
              set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[],'xdir','reverse');
          end
          Outline([353 354])=nan;
          set(DIVA_x.figure.handles.h1,'xdata',real([Outline;Outline(1)]),'ydata',imag([Outline;Outline(1)]));
          drawnow;
      end
  else
      L=ones(1,numel(x))*4/max(1,sum(sin(linspace(0,pi,numel(x)))));
      %L=(numel(x):-1:1)/numel(x);L=L*4/sum(L.*sin(linspace(0,pi,numel(x))));
      %L=[1,1];for n1=3:numel(x),L(n1)=L(n1-2)+L(n1-1);end;L=fliplr(L);L=L*sqrt(2*4^2)/sum(L);
      %L=ones(1,numel(x))*sqrt(2*5^2)/numel(x);
      ang=cumsum(x)'+linspace(0,pi,numel(x));
      px=[0,cumsum(cos(ang).*L)]+0;
      py=[0,cumsum(sin(ang).*L)]-0*4;
      yz_x=px(end);
      yz_y=py(end);
      
      y = [yz_x;yz_y];
      z = x(:);
      
      if DIVA_x.gui&&nargin>1&&dodisp % display vt
          if dodisp==-1, % initialize display
              DIVA_x.figure.data.x0=diag([1,.3])*[-.2,1.2,1.2,-.2;-.5,-.5,.5,.5];%[.5+.6*cos(linspace(0,2*pi,64));sin(linspace(0,2*pi,64))];
              for n1=1:numel(ang),DIVA_x.figure.handles.h1(n1)=patch(nan,nan,'k','edgecolor','k','facecolor','w'); hold on; end
              DIVA_x.figure.handles.h2=plot(nan,nan,'ko','markersize',4,'markeredgecolor','k','markerfacecolor','k');
              DIVA_x.figure.handles.h3=plot(nan,nan,'k-','color',1*[0,0,1],'linewidth',2);
              hold off;
              set(gca,'xlim',[-5,5],'ylim',[-5,5]);
              set(gca,'xcolor','w','ycolor','w','xtick',[],'ytick',[]);
          end
          for n1=1:numel(ang),set(DIVA_x.figure.handles.h1(n1),'xdata',px(n1)+L(n1)*[cos(ang(n1)),-sin(ang(n1))]*DIVA_x.figure.data.x0,'ydata',py(n1)+L(n1)*[sin(ang(n1)),cos(ang(n1))]*DIVA_x.figure.data.x0);end
          set(DIVA_x.figure.handles.h2,'xdata',px,'ydata',py);
          set(DIVA_x.figure.handles.h3,'xdata',[get(DIVA_x.figure.handles.h3,'xdata'),px(end)],'ydata',[get(DIVA_x.figure.handles.h3,'ydata'),py(end)]);
          drawnow;
      end
  end
end





