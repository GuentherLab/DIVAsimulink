function [FPV, gname]=diva_glottalsystem_forwardmodel(ART)
% FPV=diva_glottalsystem_forwardmodel(ART)
% converts glottal articulatory dimensions to F0/Pressure/Voicing dimensions
%    ART : [Nx1] vector of glottal articulatory dimensions
%    FPV : [3x1] vector of Liljencrants-Fant equivalent model F0/Pressure/Voicing values (values ranging from -1 to 1)
%
% [n,name]=diva_glottalsystem_forwardmodel;
% returns number of glottal articulatory dimensions (N)
% and name of glottal model
%

gname='LF'; % name of glottal model used by default

switch(gname) % note: to add new glottal model add a new 'case' below with its details
    case 'LF'
        Ndims=3;    % number of dimensions of glottal model
        if nargin<1||isempty(ART), FPV=Ndims; return; end
        FPV=ART(end-Ndims+1:end,:); % one-to-one mapping between glottal articulatory and F0/Pressure/Voicing dimensions
        
end

