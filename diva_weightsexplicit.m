% Level-2 M file S-Function.
function diva_weightsexplicit(block)
setup(block);
end

%% Initialization
function setup(block)

% Register number of dialog parameters
block.NumDialogPrms = 3;
block.DialogPrmsTunable = {'Nontunable','Nontunable','Nontunable'};

% Register number of input and output ports
block.NumInputPorts  = 2;
block.NumOutputPorts = 1;

% Setup functional port properties to dynamically inherited.
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

block.InputPort(1).Dimensions        = -1;
block.InputPort(1).DirectFeedthrough = true;
block.InputPort(2).Dimensions        = -1;
block.InputPort(2).DirectFeedthrough = true;
block.OutputPort(1).Dimensions       = -1;

% Set block sample time to discrete
block.SampleTimes = [-1 0];

% Register methods
block.RegBlockMethod('SetInputPortDimensions',  @SetInputDims);
block.RegBlockMethod('Outputs',                 @Output);

end


function SetInputDims(block, port, dm)
block.InputPort(port).Dimensions = dm;
if port==2, block.OutputPort(1).Dimensions = dm; end
end

%% Output & Update equations
function Output(block)

dy=block.InputPort(1).Data;
x=block.InputPort(2).Data;
nout=block.DialogPrm(1).Data;
%     switch(nout)
%         case 1, nout='auditory';
%         case 2, nout='somatosensory';
%     end
%     switch(lower(nout)),
%         case 'auditory', nout=1;
%         case 'somatosensory', nout=2;
%     end
EPS=block.DialogPrm(2).Data;
LAMBDA=block.DialogPrm(3).Data;
dx=diva_solveinv(['error_',nout], x, dy, 'eps',EPS,'lambda',LAMBDA);
block.OutputPort(1).Data = dx;
%     K=.05;
%     dx0=-K*(Ix-iJ*DY*Q'/EPS)*x;
%     block.OutputPort(1).Data = dx+dx0;

end


