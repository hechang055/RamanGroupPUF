function newspectrum = smooth_backcor(shift,spectrum,order)
    spec_sm=smooth(spectrum,'moving');
    spec_sm = spectrum;
    z = backcor(shift,spec_sm,order,0.001,'atq');
    newspectrum = spec_sm-z;
end
% [EST,COEFS,IT]=backcor(shift,spec,3,0.001)