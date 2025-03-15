"""
    SMLD

Abstract type representing Single Molecule Localization Data (SMLD).

# Interface Requirements

Any concrete subtype of SMLD must provide:
- `emitters::Vector{<:AbstractEmitter}`: Vector of localized emitters

Additional fields may include:
- Camera information
- Acquisition parameters
- Analysis metadata

Note: All emitter coordinates must be in physical units (microns).
"""
abstract type SMLD end

"""
    BasicSMLD{T,E<:AbstractEmitter} <: SMLD

Basic container for single molecule localization data.

# Fields
- `emitters::Vector{E}`: Vector of localized emitters
- `camera::AbstractCamera`: Camera used for acquisition
- `n_frames::Int`: Total number of frames in acquisition
- `n_datasets::Int`: Number of datasets in the acquisition
- `metadata::Dict{String,Any}`: Additional dataset information

# Type Parameters
- `T`: Numeric type for coordinates (typically Float64)
- `E`: Concrete emitter type

# Example
```julia
# Create camera
cam = IdealCamera(1:512, 1:512, 0.1)

# Create some emitters
emitters = [
    Emitter2DFit{Float64}(1.0, 1.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0; frame=1),
    Emitter2DFit{Float64}(5.0, 5.0, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0; frame=2)
]

# Create metadata
metadata = Dict{String,Any}(
    "exposure_time" => 0.1,
    "timestamp" => now(),
    "sample" => "Test Sample"
)

# Create SMLD object
data = BasicSMLD(emitters, cam, 2, 1, metadata)
```
"""
struct BasicSMLD{T,E<:AbstractEmitter} <: SMLD
    emitters::Vector{E}
    camera::AbstractCamera
    n_frames::Int
    n_datasets::Int
    metadata::Dict{String,Any}
end

"""
    BasicSMLD(emitters::Vector{E}, camera::AbstractCamera,
              n_frames::Int, n_datasets::Int,
              metadata::Dict{String,Any}=Dict{String,Any}()) where E<:AbstractEmitter

Construct a BasicSMLD from a vector of emitters and required metadata.

# Arguments
- `emitters::Vector{E}`: Vector of localized emitters
- `camera::AbstractCamera`: Camera used for acquisition
- `n_frames::Int`: Total number of frames in acquisition
- `n_datasets::Int`: Number of datasets in acquisition
- `metadata::Dict{String,Any}=Dict{String,Any}()`: Optional additional information

The numeric type T is inferred from the camera's pixel_edges_x type.

# Example
```julia
# Create with minimal metadata
data = BasicSMLD(emitters, camera, 10, 1)

# Create with additional metadata
data = BasicSMLD(emitters, camera, 10, 1, Dict(
    "exposure_time" => 0.1,
    "timestamp" => now()
))
```
"""
function BasicSMLD(emitters::Vector{E}, camera::AbstractCamera,
                  n_frames::Int, n_datasets::Int,
                  metadata::Dict{String,Any}=Dict{String,Any}()) where E<:AbstractEmitter
    T = eltype(camera.pixel_edges_x)
    BasicSMLD{T,E}(emitters, camera, n_frames, n_datasets, metadata)
end

# Helper method to get the number of emitters
"""
    Base.length(smld::SMLD)

Return the number of emitters in the SMLD object.
"""
Base.length(smld::SMLD) = length(smld.emitters)

# Helper method for iteration
"""
    Base.iterate(smld::SMLD)
    Base.iterate(smld::SMLD, state)

Enable iteration over emitters in an SMLD object.


"""
Base.iterate(smld::SMLD) = iterate(smld.emitters)
Base.iterate(smld::SMLD, state) = iterate(smld.emitters, state)


"""
    Base.show methods for SMLD types

These methods provide informative displays of SMLD data containers in both REPL and other contexts.
"""

# --- Generic SMLD compact show method ---
# This works for any concrete SMLD type

function Base.show(io::IO, smld::S) where {S<:SMLD}
    n_emitters = length(smld.emitters)
    emitter_type = eltype(smld.emitters)
    camera_type = typeof(smld.camera)
    
    # Get a cleaner type name without parameters
    type_name = string(S.name.name)
    
    print(io, "$type_name($n_emitters $emitter_type, $camera_type, $(smld.n_frames) frames)")
end

# --- BasicSMLD detailed show method ---

function Base.show(io::IO, ::MIME"text/plain", smld::BasicSMLD{T,E}) where {T,E}
    n_emitters = length(smld.emitters)
    
    # Camera info
    cam = smld.camera
    n_pixels_x = length(cam.pixel_edges_x) - 1
    n_pixels_y = length(cam.pixel_edges_y) - 1
    
    # Find mean photons per emitter
    if n_emitters > 0
        mean_photons = sum(e.photons for e in smld.emitters) / n_emitters
        mean_photons = round(mean_photons, digits=1)
    else
        mean_photons = "N/A"
    end
    
    # Prepare metadata preview
    meta_keys = keys(smld.metadata)
    meta_preview = isempty(meta_keys) ? "none" : join(collect(meta_keys)[1:min(3, length(meta_keys))], ", ")
    if length(meta_keys) > 3
        meta_preview *= ", ..."
    end
    
    println(io, "BasicSMLD{$T,$E}:")
    println(io, "  Emitters: $n_emitters")
    println(io, "  Camera: $(n_pixels_x)×$(n_pixels_y) pixels")
    println(io, "  Frames: $(smld.n_frames)")
    println(io, "  Datasets: $(smld.n_datasets)")
    println(io, "  Mean photons: $mean_photons")
    print(io, "  Metadata keys: $meta_preview")
end

