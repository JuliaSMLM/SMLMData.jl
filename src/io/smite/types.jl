"""
    SmiteSMD

Helper structure for loading Smite SMD .mat files.

# Fields
- `filepath::String`: Path to the directory containing the .mat file
- `filename::String`: Name of the .mat file
- `varname::String`: Variable name in the .mat file (default: "SMD")

# Example
```julia
# Load from default "SMD" variable
smd = SmiteSMD("path/to/data", "localizations.mat")

# Load from custom variable name
smd = SmiteSMD("path/to/data", "localizations.mat", "CustomSMD")
```
"""
mutable struct SmiteSMD 
    filepath::String
    filename::String
    varname::String
end

# Convenience constructor with default variable name
SmiteSMD(filepath::String, filename::String) = SmiteSMD(filepath, filename, "SMD")

"""
    SmiteSMLD{T,E<:AbstractEmitter} <: SMLD

SMLD type compatible with the Smite SMD (Single Molecule Data) format.

# Fields
- `emitters::Vector{E}`: Vector of localized emitters
- `camera::AbstractCamera`: Camera used for acquisition
- `n_frames::Int`: Total number of frames in acquisition
- `n_datasets::Int`: Number of datasets in the acquisition
- `metadata::Dict{String,Any}`: Additional dataset information

# Type Parameters
- `T`: Numeric type for coordinates (typically Float64)
- `E`: Concrete emitter type (typically Emitter2DFit or Emitter3DFit)
"""
struct SmiteSMLD{T,E<:AbstractEmitter} <: SMLD
    emitters::Vector{E}
    camera::AbstractCamera
    n_frames::Int
    n_datasets::Int
    metadata::Dict{String,Any}
end
