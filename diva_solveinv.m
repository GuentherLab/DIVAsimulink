function x = diva_solveinv(style,x,y_target,varargin)
% DIVA_SOLVEINV solves miscellaneous inverse problems
%
% dx = diva_solveinv('error_auditory',x,y_error);
% dx = diva_solveinv('error_somatosensory',x,y_error);
% finds direction of change of articulatory configuration
% x such that the vocal tract auditory/somatosensory error
% decreases
%
% xnew = diva_solveinv('target_outline',x,y_target)
% finds articulatory configuration xnew close to initial
% configuration x, such that the vocal tract outline
% approximates the target configuration y_target
% (note: y_target values with NaN values are disregarded/
% unconstrained in this optimization procedure)
%
% xnew = diva_solveinv('target_formant',x,y_target)
% finds articulatory configuration xnew close to initial
% configuration x, such that the formants
% approximate the target configuration y_target
% (note: y_target values with NaN values are disregarded/
% unconstrained in this optimization procedure)
%
% xnew = diva_solveinv('target_somatosensory',x,y_target)
% finds articulatory configuration xnew close to initial
% configuration x, such that the somatosensory signal
% approximates the target configuration y_target
% (note: y_target values with NaN values are disregarded/
% unconstrained in this optimization procedure)
%
% xnew = diva_solveinv(...,param_name,param_value,...) 
% defines additional solver settings:
% eps           pseudoinverse step-size [.05]
% lambda        pseudoinverse regularization strength [.05]
% beta          null-space relaxation strength [.05]
% maxiter       maximum number of iterations [100]
% maxerr        target error tolerance [.01]
% 
% example 1:
% clf; 
% x=.25*randn(13,1);
% [Aud,Som,Outline]=diva_synth(x,'explicit'); 
% Outline_target=Outline; 
% idx=220; 
% Outline_target(idx)=Outline_target(idx)-10i; % move outline down at idx'th position
% Outline_target(1:idx-1)=nan; 
% Outline_target(idx+1:end)=nan; 
% hold on; plot(Outline,'.-'); plot(Outline(idx),'ko'); hold off; axis equal off;  
% x2=diva_solveinv('target_outline',x,Outline_target); 
% [Aud2,Som2,Outline2]=diva_synth(x2,'explicit'); 
% hold on; plot(Outline2,'.-'); plot(Outline2(idx),'ko'); hold off; axis equal off;
%
% example 2:
% clf; 
% x=.25*randn(13,1);
% [Aud,Som,Outline]=diva_synth(x,'explicit'); 
% Fmt_target=Aud; 
% idx=2; 
% Fmt_target(idx)=Fmt_target(idx)+100; % move idx-th formant up
% Fmt_target(1:idx-1)=nan; 
% Fmt_target(idx+1:end)=nan; 
% hold on; plot(Aud,'.-'); plot(idx,Aud(idx),'ko'); hold off; 
% x2=diva_solveinv('target_formant',x,Fmt_target); 
% [Aud2,Som2,Outline2]=diva_synth(x2,'explicit'); 
% hold on; plot(Aud2,'.-'); plot(idx,Aud2(idx),'ko'); hold off;
%
params=struct('eps',.10,...      % pseudoinverse step-size
    'lambda',.05,...             % pseudoinverse regularization strength
    'maxiter',16,...             % if number of iterations above this, stop
    'maxerr',.01,...             % if error below this, stop
    'stepiter',1,...             % iteration step size
    'center',[],...              % center position (for regularization)
    'bounded_motor',true,...     % bounds motor dimensions to -1:1 range
    'constrained_motor',[],...   % index to motor dimensions that are constrained (cannot change position)
    'constrained_open',false,... % constrain solutions to always result in an open vocal cavity (no closure)
    'dodisp',false); 
for n1=1:2:numel(varargin)-1, if ~isfield(params,lower(varargin{n1})), error('unknown option %s',lower(varargin{n1})); else params.(lower(varargin{n1}))=varargin{n1+1}; end; end

switch(lower(style))
    case {'error_auditory','error_somatosensory'} % pseudo-inverse solution to target error
        isaud=strcmpi(style,'error_auditory');
        nout = regexprep(style,'^error_','');
        dy=y_target;
        N=numel(x);
        M=numel(dy);
        %Ix=eye(N);
        %Iy=eye(M);
        DY=zeros([M,N]); % direction of auditory/somatosensory change
        [y,p0]=diva_vocaltract(nout,x);
        %[Aud,Som,Outline,p0]=diva_synth(x);
        %if isaud, y=Aud;
        %else y=Som;
        %end
        for ndim=1:N, % computes jacobian
            xt=x;
            xt(ndim)=x(ndim)+params.eps;
            %[Aud,Som,Outline]=diva_synth(xt);
            %if isaud, yt=Aud;
            %else yt=Som;
            %end
            %DY(:,ndim)=yt-y;
            DY(:,ndim)=diva_vocaltract(nout,xt)-y;
        end
        dx =  pseudoinv_fromjacobian(DY,dy,params.eps,params.lambda,params.constrained_motor);
        if isempty(p0), p0=1; end
        x=-min(1,p0/.1)*dx;
        
    case {'target_outline','target_formant','target_somatosensory'}  % iterative pseudo-inverse solution to target position
        isaud=strcmpi(style,'target_formant');
        issom=strcmpi(style,'target_somatosensory');
        valid = ~isnan(y_target); % only care about these dimensions
        if ~isempty(params.center), 
            x=params.center; 
        end            
        x0=x;
        h=[];
        if params.constrained_open&&isaud
            [y,p0]=diva_vocaltract('formant&aperture',x,[],false);
            h=y(end); 
            y=y(1:end-1);
        elseif params.constrained_open&&issom
            [y,p0]=diva_vocaltract('somatosensory&aperture',x,[],true);
            h=y(end); 
            y=y(1:end-1);
        elseif isaud, 
            [y,p0]=diva_vocaltract('formant',x,[],false);
        elseif issom
            [y,p0]=diva_vocaltract('somatosensory',x,[],true);
        else
            Outline = diva_synth(x,'outline');
            y=[real(Outline);imag(Outline)];
            y_target=[real(y_target);imag(y_target)];
            valid=[valid; valid];
            p0=[];
        end
        
        %[Aud,Som,Outline,af,filt]=diva_synth(x,'explicit'); y=Outline...Aud;
        N=numel(x);
        M=numel(y);
        Iy=eye(M);

        for niter=1:params.maxiter
            dy=y_target-y;
            %dy(~valid)=0.5*dy(~valid);
            dy(~valid)=0;
            if ~isempty(h), dh=0-h; end
            err=mean(abs(dy(valid)));
            if err<params.maxerr, break; end
            if params.dodisp, disp(err); end
            
            DY=zeros([M,N]); % direction of auditory/somatosensory change
            DH=zeros([1,N]); % direction of aperture change
            for ndim=1:N, % computes jacobian
                xt=x;
                xt(ndim)=x(ndim)+params.eps;
                if params.constrained_open&&isaud
                    yt=diva_vocaltract('formant&aperture',xt,[],true);
                    ht=yt(end);
                    yt=yt(1:end-1);
                elseif params.constrained_open&&issom
                    yt=diva_vocaltract('somatosensory&aperture',xt,[],true);
                    ht=yt(end);
                    yt=yt(1:end-1);
                elseif isaud, 
                    yt=diva_vocaltract('formant',xt,[],false);
                elseif issom
                    yt=diva_vocaltract('somatosensory',xt,[],true);
                else
                    outline = diva_synth(xt,'outline');
                    yt=[real(outline);imag(outline)];
                end
                %ty=Compute(tx);
                DY(:,ndim)=yt-y;
                if ~isempty(h), DH(:,ndim)=ht-h; end
            end
            if params.constrained_open&&(isaud||issom), dx=pseudoinv_fromjacobian(DY, dy, params.eps, params.lambda,params.constrained_motor, DH, dh, 1e2);
            else dx=pseudoinv_fromjacobian(DY, dy, params.eps, params.lambda,params.constrained_motor);
            end
            if isempty(p0), p0=1; end
            x=x+min(1,p0/.1)*params.stepiter*dx;
            if params.bounded_motor, x=max(-1,min(1,x)); end
            if params.constrained_open&&isaud
                [y,p0]=diva_vocaltract('formant&aperture',x,[],false);
                h=y(end);
                y=y(1:end-1);
            elseif params.constrained_open&&issom
                [y,p0]=diva_vocaltract('somatosensory&aperture',x,[],true);
                h=y(end);
                y=y(1:end-1);
            elseif isaud, 
                [y,p0]=diva_vocaltract('formant',x,[],false);
                %y=diva_synth(x);
            elseif issom, 
                [y,p0]=diva_vocaltract('somatosensory',x,[],true);
            else
                outline = diva_synth(x,'outline');
                y=[real(outline);imag(outline)];
            end
        end
        %disp(niter);
        %if ~isempty(p0), x=x*p0+x0*(1-p0); end
    otherwise
        error('unknown option %s',style)
end
end

function dx = pseudoinv_fromjacobian(DY,dy,EPS,LAMBDA,IDX_CONSTRAINED, DH,dh,LAMBDAh)
N=size(DY,2);
CX=eye(N)*sqrt(LAMBDA)*EPS;
if ~isempty(IDX_CONSTRAINED), CX(1+(IDX_CONSTRAINED-1)*(N+1))=1e3*EPS; end
if nargin>6&&~isempty(DH), dx=EPS*([DY; LAMBDAh*DH; CX]\[dy; LAMBDAh*dh; zeros(N,1)]);
else dx=EPS*([DY; CX]\[dy; zeros(N,1)]);
end
if ~isempty(IDX_CONSTRAINED), dx(IDX_CONSTRAINED)=0; end
% (reference pseudoinverse computation, slower)
%     JJ=DY*DY';
%     iJ=EPS*DY'*pinv(JJ+LAMBDA*EPS^2*eye(size(JJ,1))); 
%     dx=iJ*dy;
end


