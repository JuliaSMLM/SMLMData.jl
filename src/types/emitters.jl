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
- `frame::Int=1`: frame number in acquisition sequence
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
                        frame::Int=1, dataset::Int=1, track_id::Int=0, id::Int=0) where T
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
- `frame::Int=1`: frame number in acquisition sequence
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
                        frame::Int=1, dataset::Int=1, track_id::Int=0, id::Int=0) where T
    Emitter3DFit{T}(x, y, z, photons, bg, σ_x, σ_y, σ_z, σ_photons, σ_bg,
                    frame, dataset, track_id, id)
end

"""
    Base.show methods for Emitter types

These methods provide clean displays of all emitter types in both REPL and other contexts.
"""

# --- Emitter2D ---

function Base.show(io::IO, e::Emitter2D{T}) where T
    x = round(e.x, digits=3)
    y = round(e.y, digits=3)
    photons = round(Int, e.photons)
    print(io, "Emitter2D{$T}($(x), $(y) μm, $(photons) photons)")
end

function Base.show(io::IO, ::MIME"text/plain", e::Emitter2D{T}) where T
    println(io, "Emitter2D{$T}:")
    println(io, "  Position: ($(e.x), $(e.y)) μm")
    print(io, "  Photons: $(e.photons)")
end

# --- Emitter3D ---

function Base.show(io::IO, e::Emitter3D{T}) where T
    x = round(e.x, digits=3)
    y = round(e.y, digits=3)
    z = round(e.z, digits=3)
    photons = round(Int, e.photons)
    print(io, "Emitter3D{$T}($(x), $(y), $(z) μm, $(photons) photons)")
end

function Base.show(io::IO, ::MIME"text/plain", e::Emitter3D{T}) where T
    println(io, "Emitter3D{$T}:")
    println(io, "  Position: ($(e.x), $(e.y), $(e.z)) μm")
    print(io, "  Photons: $(e.photons)")
end

# --- Emitter2DFit ---

function Base.show(io::IO, e::Emitter2DFit{T}) where T
    x = round(e.x, digits=3)
    y = round(e.y, digits=3)
    photons = round(Int, e.photons)
    print(io, "Emitter2DFit{$T}($(x), $(y) μm, $(photons) photons, frame=$(e.frame))")
end

function Base.show(io::IO, ::MIME"text/plain", e::Emitter2DFit{T}) where T
    println(io, "Emitter2DFit{$T}:")
    println(io, "  Position: ($(e.x), $(e.y)) μm")
    println(io, "  Photons: $(e.photons)")
    println(io, "  Background: $(e.bg)")
    println(io, "  Uncertainties:")
    println(io, "    σ_x: $(e.σ_x) μm")
    println(io, "    σ_y: $(e.σ_y) μm")
    println(io, "    σ_photons: $(e.σ_photons)")
    println(io, "    σ_bg: $(e.σ_bg)")
    println(io, "  Frame: $(e.frame)")
    println(io, "  Dataset: $(e.dataset)")
    print(io, "  Track ID: $(e.track_id == 0 ? "unlinked" : e.track_id)")
end

# --- Emitter3DFit ---

function Base.show(io::IO, e::Emitter3DFit{T}) where T
    x = round(e.x, digits=3)
    y = round(e.y, digits=3)
    z = round(e.z, digits=3)
    photons = round(Int, e.photons)
    print(io, "Emitter3DFit{$T}($(x), $(y), $(z) μm, $(photons) photons, frame=$(e.frame))")
end

function Base.show(io::IO, ::MIME"text/plain", e::Emitter3DFit{T}) where T
    println(io, "Emitter3DFit{$T}:")
    println(io, "  Position: ($(e.x), $(e.y), $(e.z)) μm")
    println(io, "  Photons: $(e.photons)")
    println(io, "  Background: $(e.bg)")
    println(io, "  Uncertainties:")
    println(io, "    σ_x: $(e.σ_x) μm")
    println(io, "    σ_y: $(e.σ_y) μm")
    println(io, "    σ_z: $(e.σ_z) μm")
    println(io, "    σ_photons: $(e.σ_photons)")
    println(io, "    σ_bg: $(e.σ_bg)")
    println(io, "  Frame: $(e.frame)")
    println(io, "  Dataset: $(e.dataset)")
    print(io, "  Track ID: $(e.track_id == 0 ? "unlinked" : e.track_id)")
end
