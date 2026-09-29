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
- `σ_xy::T`: covariance between x and y uncertainties (microns², 0 = axis-aligned)
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
    σ_xy::T
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
- `σ_xy::T`: covariance between x and y (microns², 0 = uncorrelated)
- `σ_xz::T`: covariance between x and z (microns², 0 = uncorrelated)
- `σ_yz::T`: covariance between y and z (microns², 0 = uncorrelated)
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
    σ_xy::T
    σ_xz::T
    σ_yz::T
    σ_photons::T
    σ_bg::T
    frame::Int
    dataset::Int
    track_id::Int
    id::Int
end


"""
    Emitter2DFit{T}(x, y, photons, bg, σ_x, σ_y, σ_photons, σ_bg;
                    σ_xy=zero(T), frame=1, dataset=1, track_id=0, id=0) where T

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
- `σ_xy::T=0`: covariance between x and y uncertainties (microns², 0 = axis-aligned)
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

# Create emitter with covariance for rotated uncertainty ellipse
emitter = Emitter2DFit{Float64}(
    1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0;
    σ_xy=0.005, frame=5, dataset=2
)
```
"""
function Emitter2DFit{T}(x::T, y::T, photons::T, bg::T,
                        σ_x::T, σ_y::T, σ_photons::T, σ_bg::T;
                        σ_xy::T=zero(T), frame::Int=1, dataset::Int=1, track_id::Int=0, id::Int=0) where T
    Emitter2DFit{T}(x, y, photons, bg, σ_x, σ_y, σ_xy, σ_photons, σ_bg,
                    frame, dataset, track_id, id)
end

"""
    Emitter3DFit{T}(x, y, z, photons, bg, σ_x, σ_y, σ_z, σ_photons, σ_bg;
                    σ_xy=zero(T), σ_xz=zero(T), σ_yz=zero(T),
                    frame=1, dataset=1, track_id=0, id=0) where T

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
- `σ_xy::T=0`: covariance between x and y (microns², 0 = uncorrelated)
- `σ_xz::T=0`: covariance between x and z (microns², 0 = uncorrelated)
- `σ_yz::T=0`: covariance between y and z (microns², 0 = uncorrelated)
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

# Create emitter with full 3D covariance
emitter = Emitter3DFit{Float64}(
    1.0, 2.0, -0.5, 1000.0, 10.0, 0.01, 0.01, 0.02, 50.0, 2.0;
    σ_xy=0.005, σ_xz=0.002, σ_yz=0.003, frame=5, track_id=1
)
```
"""
function Emitter3DFit{T}(x::T, y::T, z::T, photons::T, bg::T,
                        σ_x::T, σ_y::T, σ_z::T, σ_photons::T, σ_bg::T;
                        σ_xy::T=zero(T), σ_xz::T=zero(T), σ_yz::T=zero(T),
                        frame::Int=1, dataset::Int=1, track_id::Int=0, id::Int=0) where T
    Emitter3DFit{T}(x, y, z, photons, bg, σ_x, σ_y, σ_z, σ_xy, σ_xz, σ_yz, σ_photons, σ_bg,
                    frame, dataset, track_id, id)
end

"""
    emitter_ndims(smld::AbstractSMLD)
    emitter_ndims(emitters::AbstractVector{<:AbstractEmitter})
    emitter_ndims(e::AbstractEmitter)
    emitter_ndims(::Type{<:AbstractEmitter})

Spatial dimension of emitters: `3` when the emitter type has a field named `z`, otherwise `2`.
Emitter types defined in other packages work as long as they subtype `AbstractEmitter` and
store `z` as a field; nothing needs to be registered.

A type that computes `z` through `getproperty`, or keeps its dimension in a type parameter,
declares it with a method on its type; every other method goes through that one. A type whose
dimension is a parameter also declares that the type without it has no single dimension, so a
vector of such emitters is checked element by element:

    SMLMData.emitter_ndims(::Type{<:MyLocalization{N}}) where {N} = N
    SMLMData.emitter_ndims(::Type{<:MyLocalization}) = nothing

A vector or SMLD whose element type is concrete is decided from that type alone, even when empty.
Otherwise every element is checked, and the result is `nothing` when there is no single answer:
the elements mix 2D and 3D, or the vector is empty. An abstract type (`AbstractEmitter`) or a
`Union` also gives `nothing`; a parametric type written without its parameters (`Emitter2DFit`)
is decided from its fields.

A caller that needs a number must handle `nothing` itself, for example
`d = emitter_ndims(smld); d === nothing && throw(ArgumentError("emitters are mixed 2D/3D or empty"))`,
or treat an empty input as a no-op before asking. Do not compare the result with `<` or `>`
without that check.

# Examples
```julia
emitter_ndims(Emitter2DFit)   # 2
emitter_ndims(smld_3d)        # 3 for an SMLD of Emitter3DFit

# An emitter type defined in another package
mutable struct MyEmitter{T} <: SMLMData.AbstractEmitter
    x::T
    y::T
    photons::T
    frame::Int
    dataset::Int
    track_id::Int
    id::Int
end
emitter_ndims(MyEmitter(1.0, 2.0, 500.0, 1, 1, 0, 1))   # 2

mixed = SMLMData.AbstractEmitter[Emitter2D{Float64}(1.0, 2.0, 500.0),
                                 Emitter3D{Float64}(1.0, 2.0, 0.1, 500.0)]
emitter_ndims(mixed)          # nothing
```
"""
function emitter_ndims(::Type{E}) where {E<:AbstractEmitter}
    B = Base.unwrap_unionall(E)
    (B isa DataType && !isabstracttype(B)) || return nothing
    return hasfield(B, :z) ? 3 : 2
end
emitter_ndims(e::AbstractEmitter) = emitter_ndims(typeof(e))
function emitter_ndims(emitters::AbstractVector{<:AbstractEmitter})
    d = emitter_ndims(eltype(emitters))
    (d !== nothing || isempty(emitters)) && return d
    d1 = emitter_ndims(first(emitters))   # single assignment: a reassigned d captured by the closure would box
    return all(e -> emitter_ndims(e) == d1, emitters) ? d1 : nothing
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
    e.σ_xy != 0 && println(io, "    σ_xy: $(e.σ_xy) μm²")
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
    has_cov = e.σ_xy != 0 || e.σ_xz != 0 || e.σ_yz != 0
    if has_cov
        println(io, "  Covariances:")
        e.σ_xy != 0 && println(io, "    σ_xy: $(e.σ_xy) μm²")
        e.σ_xz != 0 && println(io, "    σ_xz: $(e.σ_xz) μm²")
        e.σ_yz != 0 && println(io, "    σ_yz: $(e.σ_yz) μm²")
    end
    println(io, "    σ_photons: $(e.σ_photons)")
    println(io, "    σ_bg: $(e.σ_bg)")
    println(io, "  Frame: $(e.frame)")
    println(io, "  Dataset: $(e.dataset)")
    print(io, "  Track ID: $(e.track_id == 0 ? "unlinked" : e.track_id)")
end
