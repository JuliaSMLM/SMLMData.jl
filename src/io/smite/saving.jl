"""
    save_smite(smld::SmiteSMLD, filepath::String, filename::String)

Save SmiteSMLD data back to SMITE's SMD .mat format.

# Arguments
- `smld::SmiteSMLD`: SMLD object to save
- `filepath::String`: Directory path where to save the file
- `filename::String`: Name of the output .mat file

# Notes
- Saves in MATLAB v7.3 format
- Preserves all metadata fields
- Writes `Z` and `Z_SE` when the element type is an `Emitter3DFit`, or the emitters are 3D and
  every one has a property `σ_z`; other data are saved without them, as in v0.7.0

# Throws
- `ArgumentError` if the emitters mix 2D and 3D: a SMITE SMD file has one `Z` column for all
  localizations, so save the 2D and the 3D emitters as separate files.
"""
function save_smite(smld::SmiteSMLD, filepath::String, filename::String)
    # Create SMD structure
    s = Dict{String,Any}()
    
    n = length(smld.emitters)

    d = emitter_ndims(smld.emitters)
    d === nothing && !isempty(smld.emitters) && throw(ArgumentError(
        "save_smite: emitters mix 2D and 3D; SMITE stores one Z column, so save 2D and 3D data separately"))
    # Z columns: 0.7.0's rule (an Emitter3DFit element type), or 3D data whose every emitter has σ_z
    # (which includes data made only of Emitter3DFit). Anything else keeps 0.7.0's columns, so
    # nothing 0.7.0 saved throws or loses a column.
    has_z = eltype(smld.emitters) <: Emitter3DFit ||
            (d == 3 && !isempty(smld.emitters) && all(e -> hasproperty(e, :σ_z), smld.emitters))
    
    # Extract arrays from emitters
    s["X"] = [e.x for e in smld.emitters]
    s["Y"] = [e.y for e in smld.emitters]
    if has_z
        s["Z"] = [e.z for e in smld.emitters]
    end
    
    s["Photons"] = [e.photons for e in smld.emitters]
    s["Bg"] = [e.bg for e in smld.emitters]
    
    s["X_SE"] = [e.σ_x for e in smld.emitters]
    s["Y_SE"] = [e.σ_y for e in smld.emitters]
    if has_z
        s["Z_SE"] = [e.σ_z for e in smld.emitters]
    end
    
    s["Photons_SE"] = [e.σ_photons for e in smld.emitters]
    s["Bg_SE"] = [e.σ_bg for e in smld.emitters]
    
    s["FrameNum"] = [e.frame for e in smld.emitters]
    s["DatasetNum"] = [e.dataset for e in smld.emitters]
    s["ConnectID"] = [e.track_id for e in smld.emitters]
    
    # Add metadata
    s["NFrames"] = smld.n_frames
    s["NDatasets"] = smld.n_datasets
    
    # Add any additional fields from metadata
    for (key, value) in smld.metadata
        if !haskey(s, key)
            s[key] = value
        end
    end
    
    # Save to file
    matwrite(joinpath(filepath, filename), Dict("SMD" => s))
end
