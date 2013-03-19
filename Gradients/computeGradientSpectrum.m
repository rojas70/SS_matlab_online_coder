%% computeGradientSpectrum
% 
% This function is based on the Relative-Change Based Hierarchical Taxonomy
% in which gradients are classified by 9 different gradient labels:
% [pimp bpos mpos spos zero sneg mneg bneg nimp]
%
% This function, given a positive impuluse (pimp) and positive constant
% (pConst) computes the read of the spectrum. 
% 
% Nimp = -pimp and nConst = -pConst. The rest of the spectrum is divided in
% equally spaced areas.
% -------------------------------------------------------------------------
function F = computeGradientSpectrum(pimp,pConst)
    
    nimp    = -1*pimp;
    nConst  = -1*pConst;

    pSpectrum = (pimp - pConst)/3.0;
    nSpectrum = (nimp - nConst)/3.0;

    % Positive Gradients
    bpos = pimp - 1.0*pSpectrum;
    mpos = pimp - 2.0*pSpectrum;
    spos = pimp - 3.0*pSpectrum;

    % Negative Gracients
    bneg = nimp - 1.0*nSpectrum;
    mneg = nimp - 2.0*nSpectrum;
    sneg = nimp - 3.0*nSpectrum;   

    % Save gradient values for a single force axes
    F = [pimp bpos mpos spos sneg mneg bneg nimp];
end