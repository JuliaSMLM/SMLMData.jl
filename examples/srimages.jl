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
using Images

magnification = 50.0
circleim = SMLMData.makecircleim(smld, magnification)
save("circleim.png", Images.colorview(Gray, circleim))


## Create and save a Gaussian image.
using SMLMData
using Images

magnification = 50.0
gaussim = SMLMData.makegaussim(smld; mag = magnification)
SMLMData.contraststretch!(gaussim)
save("gaussim.png", Images.colorview(Gray, gaussim))