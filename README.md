# SMLMData

Data types and utilities for Single Molecule Localization Microscopy (SMLM) in Julia.

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliasmlm.github.io/SMLMData.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliasmlm.github.io/SMLMData.jl/dev)
[![Build Status](https://github.com/juliasmlm/SMLMData.jl/workflows/CI/badge.svg)](https://github.com/juliasmlm/SMLMData.jl/actions)
[![Coverage](https://codecov.io/gh/juliasmlm/SMLMData.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/juliasmlm/SMLMData.jl)

## Design

SMLMData is built around three core abstract types that work together:

- **SMLD**: Container type holding a vector of emitters and camera information
- **AbstractEmitter**: Base type for individual localizations
- **AbstractCamera**: Camera geometry and pixel coordinate handling

Any concrete SMLD type must contain:
```julia
emitters::Vector{<:AbstractEmitter}  # Vector of localizations
camera::AbstractCamera               # Camera information
```

The package provides concrete implementations demonstrating this hierarchy:

```julia
# Basic emitter with just position and photons
struct Emitter2D{T} <: AbstractEmitter
    x::T           # microns
    y::T           # microns
    photons::T
end

# Camera defined by its pixel edges in physical units
struct IdealCamera{T} <: AbstractCamera
    pixel_edges_x::Vector{T}  # microns
    pixel_edges_y::Vector{T}  # microns
end

# Basic SMLD implementation
struct BasicSMLD{T,E<:AbstractEmitter} <: SMLD
    emitters::Vector{E}
    camera::AbstractCamera
    n_frames::Int
    n_datasets::Int
    metadata::Dict{String,Any}
end
```

## Provided Types

The package includes several emitter type variants:

- **2D/3D**: Basic emitter types for both 2D and 3D localizations
  ```julia
  Emitter2D{T}  # x, y, photons
  Emitter3D{T}  # x, y, z, photons
  ```

- **Fit Results**: Extended types with uncertainties and tracking
  ```julia
  Emitter2DFit{T}  # Adds σ_x, σ_y, bg, frame, track_id, etc.
  Emitter3DFit{T}  # Adds z coordinate and σ_z
  ```

These all work with the basic SMLD operations and differ only in their available fields.



## Operations

The following operations work automatically for any SMLD type:

- **Filtering**: 
  ```julia
  # Multiple filtering methods available
  @filter(smld, photons > 1000)
  filter_frames(smld, 1:10)
  filter_roi(smld, 0.0:5.0, 0.0:5.0)
  ```

- **Concatenation/Merging**:
  ```julia
  # Combine multiple SMLD objects
  cat_smld(smld1, smld2)
  merge_smld([smld1, smld2], adjust_frames=true)
  ```

## Extending

To create your own SMLD type:

1. Define your emitter type inheriting from `AbstractEmitter`
2. Define your SMLD type containing a vector of your emitters
3. All core operations (filtering, merging) will work automatically as long as:
   - Your emitter type has the fields being filtered on
   - Your SMLD type contains the standard fields (emitters, camera)

No additional method implementations are needed for basic functionality.

## Coordinate Conventions

- All spatial coordinates are in microns
- Physical space: (0,0) at top-left corner of camera
- Pixel space: (1,1) at center of top-left pixel
- Conversion functions provided: `pixel_to_physical`, `physical_to_pixel`

## Usage Example

```julia
using SMLMData

# Create camera
cam = IdealCamera(1:512, 1:512, 0.1)  # 512x512 pixels, 100nm pixel size

# Create some emitters
emitters = [
    Emitter2D{Float64}(1.0, 2.0, 1000.0),
    Emitter2D{Float64}(3.0, 4.0, 1200.0)
]

# Create SMLD
smld = BasicSMLD(emitters, cam, 1, 1, Dict{String,Any}())

# Use built-in operations
bright = @filter(smld, photons > 1000)
roi = filter_roi(smld, 0.0:5.0, 0.0:5.0)
```

## Installation

```julia
using Pkg
Pkg.add("SMLMData")
```