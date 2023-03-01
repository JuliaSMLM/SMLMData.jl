using Revise
using SMLMSim
using SMLMData
using BenchmarkTools
using Images
using CairoMakie 

σ_PSF = 1.3
pixelsize = 0.1 
nframes = 100
framerate = 1.0 # 1/s
k_on = 2.0*framerate/nframes
molecule = SMLMSim.GenericFluor(; q=[0 framerate; k_on 0], γ=1000*framerate)     
smld_bg = SMLMSim.uniform2D(10, SMLMSim.Point2D(), 32, 32)
smld_model = SMLMSim.kineticmodel(smld_bg, molecule, nframes, framerate; ndatasets = 1, minphotons = 50)
smld_noisy = SMLMSim.noise(smld_model, σ_PSF)

# generate SR image
pxsize = 0.1
pxsize_out = .005

@btime SMLMData.gaussim(smld_noisy, pxsize; pxsize_out, prctileceiling=100.0);
@profview SMLMData.gaussim(smld_noisy, pxsize; pxsize_out, prctileceiling=100.0)

img = SMLMData.gaussim(smld_noisy, pxsize; pxsize_out, prctileceiling=100.0)
i2 = Gray.(img)








