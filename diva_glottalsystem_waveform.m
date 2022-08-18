function s=diva_glottalsystem_waveform(GLOTART, nsamples)
% s=diva_glottalsystem_forwardmodel(ART, n)
% outputs one period of glottal waveform
%    ART : [Nx1] vector of glottal articulatory dimensions (e.g 3x1 vector for LF F0/Pressure/Voicing model) 
%    s   : [nx1] vector containing n samples covering one period of glottal waveform
%

gname='LF'; % name of glottal model used by default

switch(gname) % note: to add new glottal model add a new 'case' below with its details
    case 'LF'
        % unvoiced source
        s0 = fft(.10*randn(nsamples,1));
        fs0=min(0:numel(s0)-1,numel(s0):-1:1)';
        s0=s0.*(1./sqrt(1+fs0));
        s0=real(ifft(s0));

        % voiced LF source
        FPV=diva_glottalsystem_forwardmodel(GLOTART);
        voicing=(1+tanh(10*FPV(3)))/2;
        pressure=max(0,FPV(2)-0.1);

        pp=[.6,.2-.1*voicing,.1+.1*voicing]'; % LF model parameters
        ppp=.5*[1 -1*.050 0*.002];             % LF model weights
        resf=16;                              % estimate at higher frequency and then resample
        tt=(0:1/nsamples/resf:1-1/nsamples/resf)';

        s1 =    ppp(1)*glotlf(0,tt,pp)+...
            ppp(2)*glotlf(1,tt,pp)+...
            ppp(3)*glotlf(2,tt,pp);
        s1 = fft(s1);
        s1(2+nsamples:end-nsamples)=0;
        s1=real(ifft(s1)); s1=mean(reshape(s1,resf,[]),1)';
        s1=s1 .* (1+.05*randn(nsamples,1));

        % combined voiced/unvoiced sources
        wvoiced = (max(0,voicing));
        s =  pressure * (wvoiced * s1 + (1-wvoiced) * s0);
end

