function diva_mixer(block)

% Level-2 M file S-Function.
  setup(block);  
end

%% Initialization   
function setup(block)

%   % Register number of dialog parameters   
  block.NumDialogPrms = 5;
  block.DialogPrmsTunable = repmat({'Nontunable'},1,5);

  % Register number of input and output ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 1;

  % Setup functional port properties to dynamically inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = -1;
  block.InputPort(1).DirectFeedthrough = true;
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
    end
end

function SetInputSampling(block, port, dm)
    block.InputPort(port).SamplingMode= dm;
    if port==1
        block.OutputPort(1).SamplingMode= dm;
    end
end


function DoPostPropSetup(block)
  % Setup Dwork
  block.NumDworks = 1;
  block.Dwork(1).Name = 'Input'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = false;
end

function InitConditions(block)
     block.Dwork(1).Data=0;
end



%% Output & Update equations   
function Output(block)
  DT=.005; % SIM sampling rate (s)
  SAMPLE=block.Dwork(1).Data;
  % system output
  SignalAmplitude=block.DialogPrm(1).Data;
  GaussianNoiseAmplitude=block.DialogPrm(2).Data;
  SineNoiseAmplitude=block.DialogPrm(3).Data;
  SineNoisePhase=block.DialogPrm(4).Data;
  SineNoiseFrequency=block.DialogPrm(5).Data;
  if 1, %any(block.InputPort(1).Data>EPS) % loads input
      x=block.InputPort(1).Data;
      y=SignalAmplitude.*x + ...
        GaussianNoiseAmplitude.*randn(size(x)) + ...
        SineNoiseAmplitude.*sin(SineNoisePhase/180*pi + 2*pi*SineNoiseFrequency*SAMPLE*DT);
  end
  block.Dwork(1).Data = block.Dwork(1).Data + 1;
  block.OutputPort(1).Data = y;                   % output
end


