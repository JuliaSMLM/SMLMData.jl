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

# Show methods for SmiteSMD
function Base.show(io::IO, smd::SmiteSMD)
    print(io, "SmiteSMD(\"$(basename(smd.filepath))\", \"$(smd.filename)\", \"$(smd.varname)\")")
end

function Base.show(io::IO, ::MIME"text/plain", smd::SmiteSMD)
    println(io, "SmiteSMD:")
    println(io, "  Filepath: \"$(smd.filepath)\"")
    println(io, "  Filename: \"$(smd.filename)\"")
    print(io, "  Variable name: \"$(smd.varname)\"")
end

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

# Show method for SmiteSMLD
function Base.show(io::IO, ::MIME"text/plain", smld::SmiteSMLD{T,E}) where {T,E}
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
    
    # Get localization dimensions (2D or 3D)
    dim_str = E <: Union{Emitter2D, Emitter2DFit} ? "2D" : "3D"
    
    # Extract original file if available
    orig_file = get(smld.metadata, "original_file", "unknown")
    
    println(io, "SmiteSMLD{$T,$E}:")
    println(io, "  Emitters: $(format_with_commas(n_emitters)) $dim_str localizations")
    println(io, "  Camera: $(n_pixels_x)×$(n_pixels_y) pixels")
    println(io, "  Frames: $(format_with_commas(smld.n_frames))")
    println(io, "  Datasets: $(smld.n_datasets)")
    println(io, "  Mean photons: $mean_photons")
    println(io, "  Original file: $orig_file")
    
    # Add complex field info if present
    if get(smld.metadata, "complex_fields_removed", false)
        removed = get(smld.metadata, "removed_emitter_count", 0)
        fields = get(smld.metadata, "complex_fields", [])
        println(io, "  Complex fields removed: $removed emitters")
        print(io, "  Fields with complex values: $(join(fields, ", "))")
    end
end
