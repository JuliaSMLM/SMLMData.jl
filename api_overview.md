# SMLMData.jl API Overview

This guide provides a structured overview of the SMLMData.jl package designed for Single Molecule Localization Microscopy (SMLM) data handling in Julia.

## Why This Overview Exists

### For Humans
- Provides a **concise reference** without diving into full documentation
- Offers **quick-start examples** for common use cases
- Shows **relevant patterns** more clearly than individual docstrings
- Creates an **at-a-glance understanding** of package capabilities

### For AI Assistants
- Enables **better code generation** with correct API patterns
- Provides **structured context** about type hierarchies and relationships
- Offers **consistent examples** to learn from when generating code
- Helps avoid **common pitfalls** or misunderstandings about the API

## Key Concepts

- **Emitters**: Individual fluorophore localizations (2D or 3D)
- **Camera**: Defines pixel geometry and coordinate system
- **SMLD**: Container holding emitters and camera information
- **Coordinates**: All spatial coordinates are in **microns**
- **Coordinate System**: 
  - Physical space: (0,0) at top-left corner of camera
  - Pixel space: (1,1) at center of top-left pixel

## Type Hierarchy

```
AbstractEmitter                   # Base for all emitter types
├── Emitter2D{T}                  # Basic 2D emitters
├── Emitter3D{T}                  # Basic 3D emitters  
├── Emitter2DFit{T}               # 2D emitters with fit results
└── Emitter3DFit{T}               # 3D emitters with fit results

AbstractCamera                    # Base for all camera types
├── IdealCamera{T}                # Camera with regular pixel grid (Poisson noise only)
└── SCMOSCamera{T}                # sCMOS camera with pixel-dependent calibration

SMLD                              # Base for data containers
├── BasicSMLD{T,E}                # General-purpose container
└── SmiteSMLD{T,E}                # SMITE-compatible container
```

## Essential Types

### Emitter Types

```julia
# Basic 2D emitter
mutable struct Emitter2D{T} <: AbstractEmitter
    x::T           # x-coordinate in microns
    y::T           # y-coordinate in microns
    photons::T     # number of photons emitted
end

# Basic 3D emitter
mutable struct Emitter3D{T} <: AbstractEmitter
    x::T           # x-coordinate in microns
    y::T           # y-coordinate in microns
    z::T           # z-coordinate in microns
    photons::T     # number of photons emitted
end

# 2D emitter with fit results
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

# 3D emitter with fit results
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

#### Emitter Constructor Examples

```julia
# Basic 2D emitter
emitter_2d = Emitter2D{Float64}(
    1.5,      # x-coordinate in microns
    2.3,      # y-coordinate in microns  
    1000.0    # number of photons emitted
)

# Basic 3D emitter
emitter_3d = Emitter3D{Float64}(
    1.5,      # x-coordinate in microns
    2.3,      # y-coordinate in microns
    -0.5,     # z-coordinate in microns (negative = below focal plane)
    1000.0    # number of photons emitted
)

# 2D emitter with fit results using convenience constructor
emitter_2d_fit = Emitter2DFit{Float64}(
    1.5, 2.3,        # x, y coordinates in microns
    1000.0, 10.0,    # photons detected, background photons/pixel
    0.01, 0.01,      # σ_x, σ_y: position uncertainties in microns
    50.0, 2.0;       # σ_photons, σ_bg: photon count uncertainties
    frame=5,         # frame number in acquisition (1-based, default=1)
    dataset=1,       # dataset identifier for multi-acquisition experiments
    track_id=2,      # tracking ID for linked localizations (default=0 = unlinked)
    id=42            # unique identifier within this dataset (default=0)
)
```

### Camera Types

```julia
# Ideal camera with uniform pixel grid (Poisson noise only)
struct IdealCamera{T} <: AbstractCamera
    pixel_edges_x::Vector{T}  # pixel edges in x
    pixel_edges_y::Vector{T}  # pixel edges in y
end

# sCMOS camera with pixel-dependent calibration parameters
struct SCMOSCamera{T} <: AbstractCamera
    pixel_edges_x::Vector{T}      # pixel edges in x
    pixel_edges_y::Vector{T}      # pixel edges in y
    offset::Union{T, Matrix{T}}   # dark level (ADU)
    gain::Union{T, Matrix{T}}     # conversion gain (e⁻/ADU)
    readnoise::Union{T, Matrix{T}}  # read noise (e⁻ rms)
    qe::Union{T, Matrix{T}}       # quantum efficiency (0-1)
end
```

#### Camera Constructor Examples

```julia
# IdealCamera: Create a camera with 512x512 pixels, each 100nm (0.1μm) in size
# Convenience constructor (most common)
cam = IdealCamera(512, 512, 0.1)

# Explicit constructor using pixel center ranges
cam_explicit = IdealCamera(1:512, 1:512, 0.1)

# For non-square pixels, specify different x and y sizes
cam_rect = IdealCamera(512, 512, (0.1, 0.12))

# SCMOSCamera: Create with readnoise specification (matching spec sheets)
# Minimal (uniform readnoise, assumes offset=0, gain=1, qe=1)
cam_scmos = SCMOSCamera(512, 512, 0.1, 1.6)  # 1.6 e⁻ rms readnoise

# From camera spec sheet (e.g., ORCA-Flash4.0 V3)
cam_flash = SCMOSCamera(
    2048, 2048, 0.065,  # 2048×2048 pixels, 65nm pixel size
    1.6,                # 1.6 e⁻ rms readnoise from spec
    offset = 100.0,     # typical dark level
    gain = 0.46,        # 0.46 e⁻/ADU from spec
    qe = 0.72           # 72% QE at 550nm
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
    gain = 0.5,                     # Uniform gain
    qe = qe_map                     # Per-pixel QE
)
```

### SMLD Container Types

```julia
# Basic SMLD container
struct BasicSMLD{T,E<:AbstractEmitter} <: SMLD
    emitters::Vector{E}        # Vector of emitters
    camera::AbstractCamera     # Camera information
    n_frames::Int              # Total number of frames
    n_datasets::Int            # Number of datasets
    metadata::Dict{String,Any} # Additional information
end

# SMITE format compatible container
struct SmiteSMLD{T,E<:AbstractEmitter} <: SMLD
    emitters::Vector{E}        # Vector of emitters
    camera::AbstractCamera     # Camera information
    n_frames::Int              # Total number of frames
    n_datasets::Int            # Number of datasets
    metadata::Dict{String,Any} # Additional information
end
```

#### SMLD Constructor Examples

```julia
# Create a vector of emitters
emitters = [
    Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0),
    Emitter2DFit{Float64}(3.0, 4.0, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0)
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

## Core Functions

### Accessing the API Overview

```julia
# Get this API overview as a string programmatically
overview_text = api_overview()
```

### Coordinate Conversions

```julia
# Convert from pixel to physical coordinates (microns)
x_physical, y_physical = pixel_to_physical(px, py, pixel_size)

# Convert from physical to pixel coordinates
px, py = physical_to_pixel(x, y, pixel_size)

# Convert from physical to pixel indices (integers)
px_idx, py_idx = physical_to_pixel_index(x, y, pixel_size)

# Get physical coordinates of all pixel centers
centers_x, centers_y = get_pixel_centers(camera)
```

### Filtering Operations

```julia
# Filter by emitter properties using @filter macro
bright = @filter(smld, photons > 1000)                     # Select bright emitters
precise = @filter(smld, σ_x < 0.02 && σ_y < 0.02)         # Select precisely localized emitters
combined = @filter(smld, photons > 1000 && σ_x < 0.02)     # Combine multiple criteria

# The @filter macro supports any emitter property:
# - Basic: x, y, z (for 3D), photons
# - Fit results: bg, σ_x, σ_y, σ_z, σ_photons, σ_bg
# - Metadata: frame, dataset, track_id, id

# Select frames
frame_5 = filter_frames(smld, 5)                  # Single frame
early_frames = filter_frames(smld, 1:10)          # Range of frames (inclusive)
specific_frames = filter_frames(smld, [1,3,5,7])  # Specific frames (uses Set for efficiency)

# Select region of interest (ROI) - coordinates in microns
# 2D ROI
roi_2d = filter_roi(smld, 1.0:5.0, 2.0:6.0)       # x_range, y_range

# 3D ROI (for 3D emitters only)
roi_3d = filter_roi(smld, 1.0:5.0, 2.0:6.0, -1.0:1.0)  # x, y, z ranges
```

### SMLD Operations

```julia
# Concatenate multiple SMLDs
combined = cat_smld(smld1, smld2)
combined = cat_smld([smld1, smld2, smld3])

# Merge with options to adjust frame and dataset numbering
merged = merge_smld(smld1, smld2)
merged = merge_smld([smld1, smld2, smld3])

# Merge with sequential frame numbers
sequential = merge_smld([smld1, smld2, smld3], adjust_frames=true)

# Merge with sequential dataset numbers
sequential_ds = merge_smld([smld1, smld2, smld3], adjust_datasets=true)
```

### I/O Operations

```julia
# Import from SMITE format (MATLAB)
smd = SmiteSMD("path/to/data", "localizations.mat")  # Default variable name "SMD"
smd = SmiteSMD("path/to/data", "localizations.mat", "CustomSMD")  # Custom variable name

# Load as 2D or 3D data
smld_2d = load_smite_2d(smd)
smld_3d = load_smite_3d(smd)

# Export to SMITE format (saved as MATLAB v7.3 format)
# Note: requires SmiteSMLD object, not BasicSMLD
smite_smld = SmiteSMLD(smld.emitters, smld.camera, smld.n_frames, smld.n_datasets, smld.metadata)
save_smite(smite_smld, "output/directory", "results.mat")
```

**Note**: The SMITE loader automatically handles complex-valued fields by removing emitters with non-zero imaginary components in key fields (X, Y, Z, Photons, background, and uncertainties). Information about removed emitters is stored in the metadata as `"removed_complex_emitters" => count`.

### Working with SMLD Objects

```julia
# Get number of emitters
n_emitters = length(smld)

# Iterate over emitters
for emitter in smld
    println("Emitter at ($(emitter.x), $(emitter.y)) with $(emitter.photons) photons")
end

# Display formatted information
show(smld)  # Compact view
show(stdout, MIME("text/plain"), smld)  # Detailed view
```

## Common Workflows

### Creating and Working with Emitters

```julia
# Create emitters
emitter1 = Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0)
emitter2 = Emitter2DFit{Float64}(3.0, 4.0, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0)

# Create camera
cam = IdealCamera(512, 512, 0.1)  # 512x512 camera with 0.1 micron pixels

# Create SMLD container
emitters = [emitter1, emitter2]
smld = BasicSMLD(emitters, cam, 1, 1, Dict{String,Any}())
```

### Loading and Filtering Data

```julia
# Load from SMITE format
smd = SmiteSMD("data_directory", "localizations.mat")
smld = load_smite_2d(smd)

# Filter by quality
good_fits = @filter(smld, σ_x < 0.02 && σ_y < 0.02 && photons > 500)

# Filter by ROI
roi = filter_roi(good_fits, 10.0:20.0, 10.0:20.0)

# Filter by frames
frames_1_10 = filter_frames(roi, 1:10)
```

### Multi-Dataset Analysis

```julia
# Load multiple datasets
smd1 = SmiteSMD("experiment1", "data.mat")
smd2 = SmiteSMD("experiment2", "data.mat")
smld1 = load_smite_2d(smd1)
smld2 = load_smite_2d(smd2)

# Filter each dataset
bright1 = @filter(smld1, photons > 1000)
bright2 = @filter(smld2, photons > 1000)

# Merge datasets with sequential frame numbering
merged = merge_smld([bright1, bright2], adjust_frames=true)

# Process the merged dataset
result = @filter(merged, σ_x < 0.02 && σ_y < 0.02)

# Save the results (convert to SmiteSMLD first if needed)
result_smite = SmiteSMLD(result.emitters, result.camera, result.n_frames, result.n_datasets, result.metadata)
save_smite(result_smite, "analysis_results", "merged_filtered.mat")
```

## Complete Example

```julia
using SMLMData

# 1. Create a camera with 100nm pixels
# Camera has 512x512 pixels, each 0.1 microns (100nm) in size
cam = IdealCamera(512, 512, 0.1)  # Using convenience constructor  

# 2. Create emitters representing single molecule localizations
emitters = [
    # Emitter at (1.0, 2.0) μm with high precision
    Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0),
    
    # Bright emitter at (3.0, 4.0) μm
    Emitter2DFit{Float64}(3.0, 4.0, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0),
    
    # Dimmer emitter at (5.0, 6.0) μm with lower precision
    Emitter2DFit{Float64}(5.0, 6.0, 800.0, 9.0, 0.03, 0.03, 40.0, 1.5)
]

# 3. Create SMLD container to hold all data
smld = BasicSMLD(
    emitters,                              # Vector of emitters
    cam,                                   # Camera geometry
    1,                                     # Number of frames
    1,                                     # Number of datasets
    Dict{String,Any}("sample" => "Test")   # Metadata
)

# 4. Filter by photons to select bright emitters
bright = @filter(smld, photons > 900)      # Creates new SMLD with filtered emitters

# 5. Select region of interest (ROI)
# Select emitters in rectangular region: x ∈ [0, 4] μm, y ∈ [1, 5] μm
roi = filter_roi(bright, 0.0:4.0, 1.0:5.0)

# 6. Examine the results
println("Original dataset: $(length(smld)) emitters")
println("After filtering by brightness: $(length(bright)) emitters")
println("After ROI selection: $(length(roi)) emitters")

# 7. Access individual emitters
for (i, emitter) in enumerate(roi)
    println("Emitter $i: position=($(emitter.x), $(emitter.y)) μm, photons=$(emitter.photons)")
end

# Output:
# Original dataset: 3 emitters
# After filtering by brightness: 2 emitters
# After ROI selection: 2 emitters
# Emitter 1: position=(1.0, 2.0) μm, photons=1000.0
# Emitter 2: position=(3.0, 4.0) μm, photons=1200.0
```

## Common Pitfalls and Important Notes

### Coordinate System
- **Physical coordinates are always in microns**, not nanometers or pixels
- **Pixel indices start at 1** (Julia convention), not 0
- **Frame numbers start at 1** (default=1, following Julia's 1-based indexing convention)
- The origin (0,0) in physical space is at the **top-left corner** of the camera

### Type Stability
- When creating emitters, ensure all numeric fields use the same type (e.g., all `Float64`)
- The `BasicSMLD` constructor automatically infers type `T` from the camera's pixel edges
- Mixing types (e.g., `Float32` and `Float64`) can lead to performance issues

### Filtering
- The `@filter` macro creates a **new SMLD object**; it doesn't modify the original
- Filtering by frames with a vector uses `Set` internally for O(1) lookup performance
- Applying a 3D ROI filter to 2D emitters will throw an error

### SMITE Format
- Complex-valued fields in SMITE files are automatically handled by removing affected emitters
- The loader adds metadata about removed emitters: `"removed_complex_emitters" => count`
- SMITE files are saved in MATLAB v7.3 format (HDF5-based)

### Memory Considerations
- Large datasets benefit from using appropriate numeric types (e.g., `Float32` vs `Float64`)
- The `filter_frames` function with specific frame lists is optimized for sparse selections
- Iterating over emitters is memory-efficient (doesn't create intermediate arrays)

### Common Mistakes
```julia
# WRONG: Using pixel units instead of microns
emitter = Emitter2D{Float64}(100, 200, 1000.0)  # ❌ Likely pixel coordinates

# CORRECT: Using micron coordinates
emitter = Emitter2D{Float64}(10.0, 20.0, 1000.0)  # ✓ Physical coordinates

# WRONG: Modifying original SMLD
bright = @filter(smld, photons > 1000)
# smld is unchanged!

# CORRECT: Working with the filtered result
bright = @filter(smld, photons > 1000)
# Use 'bright' for further analysis
```