function FPV=diva_glottalsystem_forwardmodel(ART)
% FPV=diva_glottalsystem_forwardmodel(ART)
% converts glottal articulatory dimensions to F0/Pressure/Voicing dimensions
%    ART : [Nx1] vector of glottal articulatory dimensions
%    FPV : [3x1] vector of Liljencrants-Fant equivalent model F0/Pressure/Voicing values (values ranging from -1 to 1)
%
% n=diva_glottalsystem_forwardmodel;
% returns number of glottal articulatory dimensions (N)
%

Ndims=3;
if nargin<1||isempty(ART), FPV=Ndims; return; end
FPV=ART(end-Ndims+1:end,:); % one-to-one mapping between glottal articulatory and F0/Pressure/Voicing dimensions

end

