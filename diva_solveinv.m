function x = diva_solveinv(x,y_target,style,varargin)
% DIVA_SOLVEINV solves miscellaneous inverse problems
%
% xnew = diva_solveinv(x,y_target,'outline')
% finds articulatory configuration xnew close to initial
% configuration x, such that the vocal tract outline
% approximates the target configuration y_target
% (note: y_target values with NaN values are disregarded/
% unconstrained in this optimization procedure)
%
% xnew = diva_solveinv(x,y_target,'outline',param_name,param_value,...) 
% defines additional solver settings:
% eps           pseudoinverse step-size [.05]
% lambda        pseudoinverse regularization strength [.05]
% beta          null-space relaxation strength [.05]
% maxiter       maximum number of iterations [100]
% maxerr        target error tolerance [.01]
% 
% example:
% clf; 
% x=.25*randn(13,1);
% [Aud,Som,Outline]=diva_synth(x,'explicit'); 
% Outline_target=Outline; 
% idx=220; 
% Outline_target(idx)=Outline_target(idx)-10i; % move outline down at idx'th position
% Outline_target(1:idx-1)=nan; 
% Outline_target(idx+1:end)=nan; 
% hold on; plot(Outline,'.-'); plot(Outline(idx),'ko'); hold off; axis equal off;  
% x2=diva_solveinv(x,Outline_target,'outline'); 
% [Aud2,Som2,Outline2]=diva_synth(x2,'explicit'); 
% hold on; plot(Outline2,'.-'); plot(Outline2(idx),'ko'); hold off; axis equal off;
%

params=struct('eps',.05,...     % pseudoinverse step-size
    'lambda',.05,...            % pseudoinverse regularization strength
    'maxiter',100,...           % if number of iterations above this, stop
    'maxerr',.01,...0           % if error below this, stop
    'center',[],...              % center position (for regularization)
    'dodisp',false); 
for n1=1:2:numel(varargin)-1, if ~isfield(params,lower(varargin{n1})), error('unknown option %s',lower(varargin{n1})); else params.(lower(varargin{n1}))=varargin{n1+1}; end; end

switch(lower(style))
    case 'outline'  % iterative pseudo-inverse solution to target outline
        valid = ~isnan(y_target); % only care about these dimensions
        y_target=[real(y_target);imag(y_target)];
        valid=[valid; valid];
        
        %[Aud,Som,Outline,af,filt]=diva_synth(x,'explicit'); y=Outline;
        y=ComputeOutline(x);
        if ~isempty(params.center), y_target(~valid)=params.center(~valid); 
        else y_target(~valid)=y(~valid); 
        end            
        N=numel(x);
        M=numel(y);
        Iy=eye(M);

        for niter=1:params.maxiter
            dy=y_target-y;
            %dy(~valid)=0.5*dy(~valid);
            %dy(~valid)=0;
            err=mean(abs(dy(valid)));
            if err<params.maxerr, break; end
            if params.dodisp, disp(err); end
            
            DY=zeros([M,N]); % direction of auditory/somatosensory change
            for ndim=1:N, % computes jacobian
                tx=x;
                tx(ndim)=x(ndim)+params.eps;
                ty=ComputeOutline(tx);
                DY(:,ndim)=ty-y;
            end
            if 0||params.lambda==0, % slower
                JJ=DY'*DY;
                iJ=params.eps*pinv(JJ+params.lambda*params.eps^2*Iy)*DY'; % computes pseudoinverse
                dx=iJ*dy;
            else % faster
                dx=params.eps*([DY; eye(N)*sqrt(params.lambda)*params.eps]\[dy; zeros(N,1)]);
            end
            x=x+dx;
            y=ComputeOutline(x);
        end
    otherwise
        error('unknown option %s',style)
end

end

function outline = ComputeOutline(Art)
% computes vocal tract configuration
persistent vt fmfit;
if isempty(vt)
    [filepath,filename]=fileparts(mfilename);
    load(fullfile(filepath,'diva_synth.mat'),'vt','fmfit');
end
idx=1:10;
x=vt.Scale(idx).*Art(idx);
outline=vt.Average+vt.Base(:,idx)*x;
outline=[real(outline);imag(outline)];
end
