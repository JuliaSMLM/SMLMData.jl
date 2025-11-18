# SMLMData.jl

Data types and utilities for Single Molecule Localization Microscopy (SMLM) in Julia.

## Overview

SMLMData.jl provides core data structures and operations for working with Single Molecule Localization Microscopy data. The package follows a type-based design that makes it easy to represent, manipulate, and analyze localization data.

## Emitters

Emitters represent individual fluorophore localizations in single molecule localization microscopy. SMLMData provides several emitter types to accommodate different analysis needs.

### Emitter Type Hierarchy

All emitter types derive from the abstract `AbstractEmitter` base type:

```
AbstractEmitter
 ├─ Emitter2D{T}      - Basic 2D emitter with position and photons
 ├─ Emitter3D{T}      - Basic 3D emitter with position and photons
 ├─ Emitter2DFit{T}   - 2D emitter with fit results and uncertainties
 └─ Emitter3DFit{T}   - 3D emitter with fit results and uncertainties
```

### Basic Emitter Types

The most basic emitter types store only position and photon count:

```julia
struct Emitter2D{T} <: AbstractEmitter
    x::T           # x-coordinate in microns
    y::T           # y-coordinate in microns
    photons::T     # number of photons emitted
end

struct Emitter3D{T} <: AbstractEmitter
    x::T           # x-coordinate in microns
    y::T           # y-coordinate in microns
    z::T           # z-coordinate in microns
    photons::T     # number of photons emitted
end
```

These types are useful for:
- Simulating fluorophore emissions
- Representing ground truth data
- Simple visualization scenarios

### Fit Result Emitter Types

For real data analysis, SMLMData provides extended emitter types that include fit results with uncertainties and tracking information:

```julia
mutable struct Emitter2DFit{T} <: AbstractEmitter
    x::T           # fitted x-coordinate in microns
    y::T           # fitted y-coordinate in microns
    photons::T     # fitted number of photons
    bg::T          # fitted background in photons/pixel
    σ_x::T         # uncertainty in x position in microns
    σ_y::T         # uncertainty in y position in microns
    σ_photons::T   # uncertainty in photon count
    σ_bg::T        # uncertainty in background level
    frame::Int     # frame number in acquisition sequence
    dataset::Int   # identifier for specific acquisition/dataset
    track_id::Int  # identifier for linking localizations across frames
    id::Int        # unique identifier within dataset
end

mutable struct Emitter3DFit{T} <: AbstractEmitter
    x::T           # fitted x-coordinate in microns
    y::T           # fitted y-coordinate in microns
    z::T           # fitted z-coordinate in microns
    photons::T     # fitted number of photons
    bg::T          # fitted background in photons/pixel
    σ_x::T         # uncertainty in x position in microns
    σ_y::T         # uncertainty in y position in microns
    σ_z::T         # uncertainty in z position in microns
    σ_photons::T   # uncertainty in photon count
    σ_bg::T        # uncertainty in background level
    frame::Int     # frame number in acquisition sequence
    dataset::Int   # identifier for specific acquisition/dataset
    track_id::Int  # identifier for linking localizations across frames
    id::Int        # unique identifier within dataset
end
```

These types are suitable for:
- Storing localization analysis results
- Quality control and filtering
- Tracking and trajectory analysis
- Multi-dataset analysis

### Creating Emitters

```julia
# Basic 2D emitter
emitter_2d = Emitter2D{Float64}(1.5, 2.3, 1000.0)  # x, y, photons

# Basic 3D emitter
emitter_3d = Emitter3D{Float64}(1.5, 2.3, -0.5, 1000.0)  # x, y, z, photons

# 2D emitter with fit results using convenience constructor
emitter_2d_fit = Emitter2DFit{Float64}(
    1.5, 2.3,        # x, y coordinates (μm)
    1000.0, 10.0,    # photons, background
    0.01, 0.01,      # σ_x, σ_y (uncertainties in μm)
    50.0, 2.0;       # σ_photons, σ_bg (uncertainties)
    frame=5,         # frame number
    dataset=1,       # dataset identifier
    track_id=2,      # tracking identifier (0 = unlinked)
    id=42            # unique identifier
)

# 3D emitter with fit results
emitter_3d_fit = Emitter3DFit{Float64}(
    1.5, 2.3, -0.5,    # x, y, z coordinates (μm)
    1000.0, 10.0,      # photons, background
    0.01, 0.01, 0.02,  # σ_x, σ_y, σ_z (uncertainties in μm)
    50.0, 2.0;         # σ_photons, σ_bg (uncertainties)
    frame=5,           # frame number
    dataset=1,         # dataset identifier
    track_id=2,        # tracking identifier (0 = unlinked)
    id=42              # unique identifier
)
```

### Type Parameter

All emitter types use a type parameter `T` to specify the numeric precision:

```julia
# Float64 precision (default)
emitter_f64 = Emitter2D{Float64}(1.0, 2.0, 1000.0)

# Float32 precision for reduced memory usage
emitter_f32 = Emitter2D{Float32}(1.0f0, 2.0f0, 1000.0f0)
```

## Cameras

Cameras define the imaging system's geometry and handling of pixel coordinates.

### Camera Types

SMLMData provides two camera types:
- **IdealCamera**: For detectors with Poisson noise only (e.g., EMCCD in photon-counting mode)
- **SCMOSCamera**: For sCMOS detectors with pixel-dependent calibration parameters

#### IdealCamera

```julia
# Create a camera with 512x512 pixels, each 100nm (0.1μm) in size
camera = IdealCamera(512, 512, 0.1)

# For non-square pixels, specify different x and y sizes
camera_rect = IdealCamera(512, 512, (0.1, 0.12))
```

#### SCMOSCamera

```julia
# Minimal: uniform readnoise (assumes offset=0, gain=1, qe=1)
cam_scmos = SCMOSCamera(512, 512, 0.1, 1.6)  # 1.6 e⁻ rms readnoise

# From camera spec sheet (e.g., ORCA-Flash4.0 V3)
cam_flash = SCMOSCamera(
    2048, 2048, 0.065,  # 2048×2048 pixels, 65nm pixel size
    1.6,                 # 1.6 e⁻ rms readnoise from spec
    offset = 100.0,      # typical dark level (ADU)
    gain = 0.46,         # 0.46 e⁻/ADU from spec
    qe = 0.72            # 72% QE at 550nm
)

# With per-pixel calibration maps (precision SMLM)
readnoise_map = load("camera_noise.mat")  # 512×512 measured values
gain_map = load("camera_gain.mat")
qe_map = load("camera_qe.mat")
cam_calibrated = SCMOSCamera(512, 512, 0.1, readnoise_map,
                              gain=gain_map, qe=qe_map)

# Mixed scalar and matrix parameters
cam_mixed = SCMOSCamera(
    512, 512, 0.1, readnoise_map,  # Per-pixel noise
    offset = 100.0,                 # Uniform offset
    gain = 0.5                      # Uniform gain
)
```

**SCMOSCamera Parameters:**
- `offset`: Dark level in ADU (analog-to-digital units)
- `gain`: Conversion gain in e⁻/ADU (electrons per ADU)
- `readnoise`: Read noise in e⁻ rms (root-mean-square, matches spec sheets)
- `qe`: Quantum efficiency (dimensionless, 0-1)

Each parameter can be:
- **Scalar**: Uniform value across the sensor
- **Matrix**: Per-pixel calibration map (size must match pixel grid)


### Coordinate Conventions

- All spatial coordinates are in **microns**
- Physical space: (0,0) at top-left corner of camera
- Pixel space: (1,1) at center of top-left pixel

```julia
# Convert between coordinate systems
x_physical, y_physical = pixel_to_physical(10.5, 15.5, 0.1)
px, py = physical_to_pixel(1.05, 1.55, 0.1)
```

## ROI Batch Types

ROI (Region of Interest) batch types provide efficient storage and processing of image regions extracted from SMLM data. These types enable batched processing workflows across the JuliaSMLM ecosystem.

### SingleROI

A single region of interest with its location context:

```julia
struct SingleROI{T}
    data::Matrix{T}              # ROI image data (roi_size × roi_size)
    corner::SVector{2,Int32}     # (x, y) = (col, row) corner position
    frame_idx::Int32             # Frame number (1-indexed)
end

# Example
roi_data = rand(Float32, 11, 11)
roi = SingleROI(roi_data, SVector{2,Int32}(100, 200), Int32(5))
```

### ROIBatch

A batch of ROIs for efficient parallel processing:

```julia
struct ROIBatch{T,N,A<:AbstractArray{T,N},C<:AbstractCamera}
    data::A                      # ROI stack (roi_size × roi_size × n_rois)
    corners::Matrix{Int32}       # 2×n_rois corner positions
    frame_indices::Vector{Int32} # Frame number for each ROI
    camera::C                    # Camera object
    roi_size::Int                # Size of each ROI (square)
end
```

#### Creating ROI Batches

```julia
# From arrays
camera = IdealCamera(512, 512, 0.1)
data = rand(Float32, 11, 11, 100)  # 100 ROIs of 11×11 pixels
corners = rand(Int32(1):Int32(500), 2, 100)
frames = rand(Int32(1):Int32(50), 100)
batch = ROIBatch(data, corners, frames, camera)

# From separate x/y corner vectors
x_corners = rand(Int32(1):Int32(500), 100)
y_corners = rand(Int32(1):Int32(500), 100)
batch = ROIBatch(data, x_corners, y_corners, frames, camera)

# From vector of SingleROI
using StaticArrays
rois = [SingleROI(rand(Float32, 11, 11), SVector{2,Int32}(i*10, i*10), Int32(i))
        for i in 1:100]
batch = ROIBatch(rois, camera)
```

#### Working with ROI Batches

```julia
# Indexing
roi = batch[5]  # Returns SingleROI

# Iteration
for roi in batch
    # Process each ROI
    process(roi.data, roi.corner, roi.frame_idx)
end

# Length
n_rois = length(batch)

# GPU adaptation
using CUDA
batch_gpu = adapt(CuArray, batch)  # Transfer to GPU
```

#### Coordinate System

- **Camera coordinates**: 1-indexed, (1,1) = top-left of full image
- **ROI corners**: (x, y) = (col, row) position in camera coordinates
- **ROI data**: Local coordinates, (1,1) = top-left within ROI
- **Frame indices**: 1-indexed

#### Typical Workflow

1. **Extract ROIs**: Use SMLMBoxer.jl to detect and extract ROIs from image stack
2. **Fit ROIs**: Use GaussMLE.jl to fit Gaussian PSFs to each ROI
3. **Convert to SMLD**: Convert fit results to `BasicSMLD` for further analysis

## SMLD

SMLD (Single Molecule Localization Data) is the container type that holds emitters and camera information.

### Creating an SMLD

```julia
# Create a vector of emitters
emitters = [
    Emitter2D{Float64}(1.0, 2.0, 1000.0),
    Emitter2D{Float64}(3.0, 4.0, 1200.0)
]

# Create a BasicSMLD
smld = BasicSMLD(emitters, camera, 1, 1, Dict{String,Any}())

# Add metadata
smld_with_metadata = BasicSMLD(
    emitters, 
    camera, 
    10,  # number of frames
    1,   # number of datasets
    Dict{String,Any}(
        "exposure_time" => 0.1,
        "sample" => "Test Sample"
    )
)
```

### Filtering Operations

```julia
# Filter by emitter properties
bright_emitters = @filter(smld, photons > 1000)
precise_fits = @filter(smld, σ_x < 0.02 && σ_y < 0.02)

# Select region of interest
region = filter_roi(smld, 0.0:2.0, 1.0:3.0)

# Select frames
frame_5 = filter_frames(smld, 5)
early_frames = filter_frames(smld, 1:10)
```

### Combining SMLDs

```julia
# Concatenate two SMLD objects
combined = cat_smld(smld1, smld2)

# Merge with sequential frame numbering
merged = merge_smld([smld1, smld2], adjust_frames=true)
```

## File I/O

SMLMData currently supports the SMITE format, with more formats planned for future releases.

```julia
# Import from SMITE format (MATLAB)
smd = SmiteSMD("path/to/data", "localizations.mat")
smld_2d = load_smite_2d(smd)
smld_3d = load_smite_3d(smd)

# Export to SMITE format
save_smite(smld, "output/directory", "results.mat")
```

## Installation

```julia
using Pkg
Pkg.add("SMLMData")
```

For complete API documentation, see the [API Reference](api.md).