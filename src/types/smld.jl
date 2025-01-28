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