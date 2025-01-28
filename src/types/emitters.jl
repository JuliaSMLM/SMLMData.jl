"""
    AbstractEmitter

Abstract supertype for all emitter types in single molecule localization microscopy (SMLM).
All spatial coordinates are specified in physical units (microns).
"""
abstract type AbstractEmitter end

"""
    Emitter2D{T} <: AbstractEmitter

Represents a 2D emitter for SMLM simulations with position and brightness.

# Fields
- `x::T`: x-coordinate in microns
- `y::T`: y-coordinate in microns
- `photons::T`: number of photons emitted by the fluorophore
"""
mutable struct Emitter2D{T} <: AbstractEmitter
    x::T
    y::T
    photons::T
end

"""
    Emitter3D{T} <: AbstractEmitter

Represents a 3D emitter for SMLM simulations with position and brightness.

# Fields
- `x::T`: x-coordinate in microns
- `y::T`: y-coordinate in microns
- `z::T`: z-coordinate in microns (axial position)
- `photons::T`: number of photons emitted by the fluorophore
"""
mutable struct Emitter3D{T} <: AbstractEmitter
    x::T
    y::T
    z::T
    photons::T
end

"""
    Emitter2DFit{T} <: AbstractEmitter

Represents fitted 2D localization results with uncertainties and temporal/tracking information.

# Fields
- `x::T`: fitted x-coordinate in microns
- `y::T`: fitted y-coordinate in microns
- `photons::T`: fitted number of photons
- `bg::T`: fitted background in photons/pixel
- `σ_x::T`: uncertainty in x position in microns
- `σ_y::T`: uncertainty in y position in microns
- `σ_photons::T`: uncertainty in photon count
- `σ_bg::T`: uncertainty in background in photons/pixel
- `frame::Int`: frame number in acquisition sequence
- `dataset::Int`: identifier for specific acquisition/dataset
- `track_id::Int`: identifier for linking localizations across frames (0 = unlinked)
- `id::Int`: unique identifier within dataset
"""
mutable struct Emitter2DFit{T} <: AbstractEmitter
    x::T
    y::T
    photons::T
    bg::T
    σ_x::T
    σ_y::T
    σ_photons::T
    σ_bg::T
    frame::Int
    dataset::Int
    track_id::Int
    id::Int
end

"""
    Emitter3DFit{T} <: AbstractEmitter

Represents fitted 3D localization results with uncertainties and temporal/tracking information.

# Fields
- `x::T`: fitted x-coordinate in microns
- `y::T`: fitted y-coordinate in microns
- `z::T`: fitted z-coordinate in microns
- `photons::T`: fitted number of photons
- `bg::T`: fitted background in photons/pixel
- `σ_x::T`: uncertainty in x position in microns
- `σ_y::T`: uncertainty in y position in microns
- `σ_z::T`: uncertainty in z position in microns
- `σ_photons::T`: uncertainty in photon count
- `σ_bg::T`: uncertainty in background in photons/pixel
- `frame::Int`: frame number in acquisition sequence
- `dataset::Int`: identifier for specific acquisition/dataset
- `track_id::Int`: identifier for linking localizations across frames (0 = unlinked)
- `id::Int`: unique identifier within dataset
"""
mutable struct Emitter3DFit{T} <: AbstractEmitter
    x::T
    y::T
    z::T
    photons::T
    bg::T
    σ_x::T
    σ_y::T
    σ_z::T
    σ_photons::T
    σ_bg::T
    frame::Int
    dataset::Int
    track_id::Int
    id::Int
end


"""
    Emitter2DFit{T}(x, y, photons, bg, σ_x, σ_y, σ_photons, σ_bg;
                    frame=0, dataset=1, track_id=0, id=0) where T

Convenience constructor for 2D localization fit results with optional identification parameters.

# Arguments
## Required
- `x::T`: fitted x-coordinate in microns
- `y::T`: fitted y-coordinate in microns
- `photons::T`: fitted number of photons
- `bg::T`: fitted background in photons/pixel
- `σ_x::T`: uncertainty in x position in microns
- `σ_y::T`: uncertainty in y position in microns
- `σ_photons::T`: uncertainty in photon count
- `σ_bg::T`: uncertainty in background level

## Optional Keywords
- `frame::Int=0`: frame number in acquisition sequence
- `dataset::Int=1`: identifier for specific acquisition/dataset
- `track_id::Int=0`: identifier for linking localizations across frames
- `id::Int=0`: unique identifier within dataset

# Example
```julia
# Create emitter with just required parameters
emitter = Emitter2DFit{Float64}(
    1.0, 2.0,        # x, y
    1000.0, 10.0,    # photons, background
    0.01, 0.01,      # σ_x, σ_y
    50.0, 2.0        # σ_photons, σ_bg
)

# Create emitter with specific frame and dataset
emitter = Emitter2DFit{Float64}(
    1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0;
    frame=5, dataset=2
)
```
"""
function Emitter2DFit{T}(x::T, y::T, photons::T, bg::T, 
                        σ_x::T, σ_y::T, σ_photons::T, σ_bg::T;
                        frame::Int=0, dataset::Int=1, track_id::Int=0, id::Int=0) where T
    Emitter2DFit{T}(x, y, photons, bg, σ_x, σ_y, σ_photons, σ_bg, 
                    frame, dataset, track_id, id)
end

"""
    Emitter3DFit{T}(x, y, z, photons, bg, σ_x, σ_y, σ_z, σ_photons, σ_bg;
                    frame=0, dataset=1, track_id=0, id=0) where T

Convenience constructor for 3D localization fit results with optional identification parameters.

# Arguments
## Required
- `x::T`: fitted x-coordinate in microns
- `y::T`: fitted y-coordinate in microns
- `z::T`: fitted z-coordinate in microns
- `photons::T`: fitted number of photons
- `bg::T`: fitted background in photons/pixel
- `σ_x::T`: uncertainty in x position in microns
- `σ_y::T`: uncertainty in y position in microns
- `σ_z::T`: uncertainty in z position in microns
- `σ_photons::T`: uncertainty in photon count
- `σ_bg::T`: uncertainty in background level

## Optional Keywords
- `frame::Int=0`: frame number in acquisition sequence
- `dataset::Int=1`: identifier for specific acquisition/dataset
- `track_id::Int=0`: identifier for linking localizations across frames
- `id::Int=0`: unique identifier within dataset

# Example
```julia
# Create emitter with just required parameters
emitter = Emitter3DFit{Float64}(
    1.0, 2.0, -0.5,  # x, y, z
    1000.0, 10.0,    # photons, background
    0.01, 0.01, 0.02,# σ_x, σ_y, σ_z
    50.0, 2.0        # σ_photons, σ_bg
)

# Create emitter with specific frame and tracking
emitter = Emitter3DFit{Float64}(
    1.0, 2.0, -0.5, 1000.0, 10.0, 0.01, 0.01, 0.02, 50.0, 2.0;
    frame=5, track_id=1
)
```
"""
function Emitter3DFit{T}(x::T, y::T, z::T, photons::T, bg::T, 
                        σ_x::T, σ_y::T, σ_z::T, σ_photons::T, σ_bg::T;
                        frame::Int=0, dataset::Int=1, track_id::Int=0, id::Int=0) where T
    Emitter3DFit{T}(x, y, z, photons, bg, σ_x, σ_y, σ_z, σ_photons, σ_bg,
                    frame, dataset, track_id, id)
end