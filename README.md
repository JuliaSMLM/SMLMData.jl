# SMLMData

Data types and utilities for Single Molecule Localization Microscopy (SMLM) in Julia.

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliasmlm.github.io/SMLMData.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliasmlm.github.io/SMLMData.jl/dev)
[![Build Status](https://github.com/juliasmlm/SMLMData.jl/workflows/CI/badge.svg)](https://github.com/juliasmlm/SMLMData.jl/actions)
[![Coverage](https://codecov.io/gh/juliasmlm/SMLMData.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/juliasmlm/SMLMData.jl)
[![Julia Version](https://img.shields.io/badge/julia-%3E%3D%201.6-brightgreen.svg)](https://julialang.org/)

## Quick Start

```julia
using SMLMData

# Create a camera with 100nm pixels
cam = IdealCamera(512, 512, 0.1)  

# Create emitters
emitters = [
    Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0),
    Emitter2DFit{Float64}(3.0, 4.0, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0)
]

# Create SMLD container
smld = BasicSMLD(emitters, cam, 1, 1, Dict{String,Any}())

# Filter by photons
bright = @filter(smld, photons > 1000)

# Select region of interest
roi = filter_roi(smld, 0.0:2.0, 1.0:3.0)
```

## Overview

SMLMData provides a unified framework for handling Single Molecule Localization Microscopy data in Julia. The package enables efficient data manipulation, filtering, and analysis through a well-defined type system that handles both 2D and 3D localizations.

### Key Features

- **Type system** for emitters, cameras, and datasets
- **Physical coordinate handling** with camera pixel mappings
- **Filtering tools** for property-based and spatial selection
- **Dataset operations** for merging and concatenation
- **SMITE format** compatibility for MATLAB interoperability
- **Extensible design** for custom emitter types

## Type Hierarchy

```
AbstractCamera
 └─ IdealCamera{T}

AbstractEmitter
 ├─ Emitter2D{T}
 ├─ Emitter3D{T}
 ├─ Emitter2DFit{T}
 └─ Emitter3DFit{T}

SMLD
 └─ BasicSMLD{T,E}
 
```

## Common Workflows

### Loading External Data

```julia
# Load from SMITE format (MATLAB)
smd = SmiteSMD("path/to/data", "localizations.mat")
smld_2d = load_smite_2d(smd)
```

### Filtering and Analysis

```julia
# Filter by multiple properties
good_fits = @filter(smld, σ_x < 0.02 && σ_y < 0.02 && photons > 500)

# Select spatial region
region = filter_roi(smld, 5.0:15.0, 10.0:20.0)

# Analyze frames
first_10_frames = filter_frames(smld, 1:10)
```

### Combining Datasets

```julia
# Merge datasets with sequential frame numbering
merged = merge_smld([smld1, smld2], adjust_frames=true)
```

## Coordinate Conventions

- All spatial coordinates are in **microns**
- Physical space: (0,0) at top-left corner of camera
- Pixel space: (1,1) at center of top-left pixel
- Conversion functions: `pixel_to_physical`, `physical_to_pixel`

## Design Details

SMLMData is built around three core abstract types that work together:

- **SMLD**: Container type holding a vector of emitters and camera information
- **AbstractEmitter**: Base type for individual localizations
- **AbstractCamera**: Camera geometry and pixel coordinate handling

Any concrete SMLD type must contain:
```julia
emitters::Vector{<:AbstractEmitter}  # Vector of localizations
camera::AbstractCamera               # Camera information
```

The package provides concrete implementations for different use cases:

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

## Extending

To create your own SMLD type:

1. Define your emitter type inheriting from `AbstractEmitter`
2. Define your SMLD type containing a vector of your emitters
3. All core operations (filtering, merging) will work automatically as long as:
   - Your emitter type has the fields being filtered on
   - Your SMLD type contains the standard fields (emitters, camera)

## Installation

```julia
using Pkg
Pkg.add("SMLMData")
```

## Documentation

For detailed usage instructions, tutorials, and API reference, please visit the [official documentation](https://juliasmlm.github.io/SMLMData.jl/stable).