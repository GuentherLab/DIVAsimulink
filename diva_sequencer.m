function diva_sequencer(block)

% Level-2 M file S-Function.
  setup(block);  
end

%% Initialization   
function setup(block)

%   % Register number of dialog parameters   
  %block.NumDialogPrms = 1;
  %block.DialogPrmsTunable = {'Nontunable'};

  % Register number of input and output ports
  block.NumInputPorts  = 2;
  block.NumOutputPorts = 1;%2;

  % Setup functional port properties to dynamically inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = -1;
  block.InputPort(1).DirectFeedthrough = true;
  block.InputPort(2).Dimensions        = -1;
  block.InputPort(2).DirectFeedthrough = true;
  block.OutputPort(1).Dimensions       = -1;
  %block.OutputPort(2).Dimensions       = -1;
  
  % Set block sample time to discrete
  block.SampleTimes = [-1 0];
  
  % Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('SetInputPortDimensions',  @SetInputDims);
  block.RegBlockMethod('SetInputPortSamplingMode',@SetInputSampling);
  block.RegBlockMethod('Outputs',                 @Output);  
%   block.RegBlockMethod('Update',                  @Update);  
  
end


function SetInputDims(block, port, dm)
    block.InputPort(port).Dimensions = dm;
    if port==1, 
        block.OutputPort(1).Dimensions = dm; 
        %block.OutputPort(2).Dimensions = dm; 
    end
end

function SetInputSampling(block, port, dm)
    block.InputPort(port).SamplingMode= dm;
    if port==1
        block.OutputPort(1).SamplingMode= dm;
        %block.OutputPort(2).SamplingMode= dm;
    end
end


function DoPostPropSetup(block)
  % Setup Dwork
  block.NumDworks = 4;
  block.Dwork(1).Name = 'Input'; 
  block.Dwork(1).Dimensions      = block.InputPort(1).Dimensions;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = false;
  block.Dwork(2).Name = 'Sample'; 
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;
  block.Dwork(2).Complexity      = 'Real';
  block.Dwork(2).UsedAsDiscState = false;
  block.Dwork(3).Name = 'LastOutput'; 
  block.Dwork(3).Dimensions      = block.InputPort(1).Dimensions;
  block.Dwork(3).DatatypeID      = 0;
  block.Dwork(3).Complexity      = 'Real';
  block.Dwork(3).UsedAsDiscState = false;
  block.Dwork(4).Name = 'NSegments'; 
  block.Dwork(4).Dimensions      = block.InputPort(1).Dimensions;
  block.Dwork(4).DatatypeID      = 0;
  block.Dwork(4).Complexity      = 'Real';
  block.Dwork(4).UsedAsDiscState = false;
end

function InitConditions(block)
    block.Dwork(1).Data=zeros(block.Dwork(1).Dimensions,1);
    block.Dwork(2).Data=0;
    block.Dwork(3).Data=zeros(block.Dwork(1).Dimensions,1);;
    block.Dwork(4).Data=zeros(block.Dwork(1).Dimensions,1);;
end



%% Output & Update equations   
function Output(block)

  % system output
    EPS=.01;
    DT=.005; % SIM sampling rate (s)
    N=block.Dwork(1).Dimensions;
    out=zeros(N,1);
    if any(block.InputPort(1).Data>EPS) % loads input 
        idx=find(block.InputPort(1).Data>EPS);
        segment=cumsum([1;diff(idx)>1]); % if multiple non-adjacent segments
        soffset=accumarray(segment,idx,[],@min);
        slength=accumarray(segment,1);
        time=(idx-soffset(segment));%./max(eps,slength(segment)-1);
        block.Dwork(1).Data=cat(1,idx,zeros(N-numel(idx),1)); % index to active input cells (sweep over these)
        block.Dwork(2).Data=1; % sample time (1-inf)
        block.Dwork(3).Data=cat(1,time,zeros(N-numel(idx),1)); % when to active each cell
        block.Dwork(4).Data=cat(1,slength(segment)-1, zeros(N-numel(idx),1));
    end
    if block.InputPort(2).Data>EPS&&block.Dwork(2).Data>0, % outputs input sequentially
        idx=block.Dwork(1).Data;
        time=block.Dwork(2).Data-1; % note: switch to vector of times per segment
        times=block.Dwork(3).Data;
        ntimes=block.Dwork(4).Data;
        mtimes=max(times);
%         n=block.Dwork(2).Data;
%         %if n==1,n=n+block.InputPort(2).Data; end % add sub-sample jitter
%         n0=floor(n);
%         n1=n-n0;
        
        if time>mtimes, %n0>N||~idx(n0), % end of sequence
            block.Dwork(2).Data=0;
        else               % new sample point
            if time<=0, 
                n0=find(times==0);
                out(idx(n0))=1;
            else
                n0=find(times<time&[times(2:end)>=time;false]);
                n1=(time-times(n0))./(times(n0+1)-times(n0));
                out(idx(n0))=1-n1;
                out(idx(n0+1))=n1;
            end
%             if n0<1, out(idx(1))=1;
%             elseif n0+1>N||~idx(n0+1)
%                 out(idx(n0))=double(n1==0); % note: do not interpolate beyond end of sequence
%             else
%                 out(idx(n0))=1-n1;
%                 out(idx(n0+1))=n1;
%             end
            block.Dwork(2).Data=time+block.InputPort(2).Data*DT+1;
        end
    else
        %out(1)=1;
        %disp('no input to diva_sequencer');
    end
    block.OutputPort(1).Data = out;                   % output
end


