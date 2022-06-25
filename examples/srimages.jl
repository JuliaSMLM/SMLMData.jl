# This script demonstrates how to create and save different types of
# localization images.

using SMLMData
using SMLMSim


## Simulate some 2D data that we'll make images from.
smld_true, smld_model, smld = SMLMSim.sim(;
    ρ=1.0,
    σ_PSF=0.13, #micron 
    minphotons=50,
    ndatasets=10,
    nframes=1000,
    framerate=50.0, # 1/s
    pattern=SMLMSim.Nmer2D(),
    molecule=SMLMSim.GenericFluor(; q=[0 50; 1e-2 0]), #1/s 
    camera=SMLMSim.IdealCamera(; xpixels=128, ypixels=128, pixelsize=0.1) #pixelsize is microns
)

## Create and save a circle image.
pxsize = 0.1
pxsize_out = 0.001
SMLMData.circleim(smld, pxsize, "circleim.png";
    pxsize_out=pxsize_out)

## Create and save a Gaussian image.
pxsize = 0.1
pxsize_out = 0.001
prctileceiling = 99.8
nsigma = 5.0
SMLMData.gaussim(smld, pxsize, "gaussim.png";
    pxsize_out=pxsize_out,
    prctileceiling=prctileceiling,
    nsigma=nsigma)

## Create a "raw" Gaussian image distribution (i.e., no extra thresholds and 
## it sums to 1.0).
pxsize = 0.1
pxsize_out = 0.001
nsigma = 5.0
imdistrib = SMLMData.makegaussim(smld; mag=pxsize / pxsize_out, nsigma=nsigma)