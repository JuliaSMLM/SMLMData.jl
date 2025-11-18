"""
    SMLMData

A Julia package for working with Single Molecule Localization Microscopy (SMLM) data.

# Features
- Type system for emitters, cameras, and localization data
- Physical coordinate handling (microns) with camera pixel mappings
- Filtering and ROI selection tools
- SMITE format compatibility
- Memory-efficient data structures

# Basic Usage
```julia
using SMLMData

# Create a camera
cam = IdealCamera(1:512, 1:512, 0.1)  # 512x512 camera with 0.1 micron pixels

# Create some emitters
emitters = [
    Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0),
    Emitter2DFit{Float64}(3.0, 4.0, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0)
]

# Create SMLD object
smld = BasicSMLD(emitters, cam, 1, 1, Dict{String,Any}())

# Filter operations
roi = filter_roi(smld, 0.0:2.0, 1.0:3.0)
bright = @filter(smld, photons > 1000)
```

# API Overview
For a comprehensive overview of the API, use the help mode on `api`:

```julia
?api
```

Or access the complete API documentation programmatically:

```julia
docs = SMLMData.api()
```
"""
module SMLMData

# External Packages
using MAT

# Base imports
import Base: filter

# Type definitions
export 
    # Abstract types
    AbstractEmitter,
    AbstractCamera,
    SMLD,

    # Concrete emitter types
    Emitter2D,
    Emitter3D,
    Emitter2DFit,
    Emitter3DFit,

    # Camera types
    IdealCamera,
    SCMOSCamera,

    # ROI batch types
    SingleROI,
    ROIBatch,

    # SMLD types
    BasicSMLD,
    SmiteSMLD,
    SmiteSMD

# Coordinates and conversions
export 
    pixel_to_physical,
    physical_to_pixel,
    physical_to_pixel_index,
    compute_bin_edges,
    get_pixel_centers

# Filtering and operations
export
    @filter,
    filter_frames,
    filter_roi,
    cat_smld,
    merge_smld

# SMITE functionality
export
    load_smite_2d,
    load_smite_3d,
    save_smite

# Include all source files
include("types/emitters.jl")  # Move from current location
include("types/cameras.jl")   # Move from current location
include("types/roi_batch.jl") # ROI batch types for ecosystem interop
include("types/smld.jl")      # Move from current location

include("core/coordinates.jl") # Move from coordinates.jl
include("core/filters.jl")    # Move from filters.jl
include("core/operations.jl") # Move from operations.jl

include("io/smite/types.jl")   # Move from smite/types.jl
include("io/smite/loading.jl") # Move from smite/loading.jl
include("io/smite/saving.jl")  # Move from smite/saving.jl

# Include the API overview functionality
include("api.jl")

end