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
"""
function save_smite(smld::SmiteSMLD, filepath::String, filename::String)
    # Create SMD structure
    s = Dict{String,Any}()
    
    n = length(smld.emitters)
    
    # Extract arrays from emitters
    s["X"] = [e.x for e in smld.emitters]
    s["Y"] = [e.y for e in smld.emitters]
    if eltype(smld.emitters) <: Emitter3DFit
        s["Z"] = [e.z for e in smld.emitters]
    end
    
    s["Photons"] = [e.photons for e in smld.emitters]
    s["Bg"] = [e.bg for e in smld.emitters]
    
    s["X_SE"] = [e.σ_x for e in smld.emitters]
    s["Y_SE"] = [e.σ_y for e in smld.emitters]
    if eltype(smld.emitters) <: Emitter3DFit
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
