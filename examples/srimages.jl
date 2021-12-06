# This script demonstrates how to create and save different types of
# localization images.

## Simulate some data that we'll make images from.
using SMLMSim

γ = 1e5 # Fluorophore emission rate
q = [0 50
    1e-2 0] # Fluorophore blinking rates
n = 6 # Nmer rank
d = 0.3 # Nmer diameter
ρ = 0.1 # density of Nmers 
xsize = 25.6 # image size
ysize = 25.6
nframes = 5000 # number of frames
ndatasets = 10
framerate = 50.0 # framerate
σ_psf = 1.3 # psf sigma used for uncertainty calcs
minphotons = 500 # minimum number of photons per frame accepted
fluor = SMLMSim.GenericFluor(γ, q)
pattern = SMLMSim.Nmer2D(n, d)
smld_true = SMLMSim.uniform2D(ρ, pattern, xsize, ysize)
smld_model = SMLMSim.kineticmodel(smld_true, fluor, nframes, framerate;
    ndatasets = ndatasets, minphotons = minphotons)
smld = SMLMSim.noise(smld_model, σ_psf)


## Create and save a circle image.
using SMLMData

pxsize = 0.1
pxsize_out = 0.001
SMLMData.circleim(smld, pxsize, "circleim.png";
    pxsize_out = pxsize_out)


## Create and save a Gaussian image.
pxsize = 0.1
pxsize_out = 0.001
prctileceiling = 99.8
nsigma = 5.0
SMLMData.gaussim(smld, pxsize, "gaussim.png";
    pxsize_out = pxsize_out,
    prctileceiling = prctileceiling,
    nsigma = nsigma)

## Create a "raw" Gaussian image distribution (i.e., no extra thresholds and 
## it sums to 1.0).
pxsize = 0.1
pxsize_out = 0.001
nsigma = 5.0
imdistrib = SMLMData.makegaussim(smld; mag = pxsize/pxsize_out, nsigma = nsigma)

