"""
    save_smite(smld::SmiteSMLD, filepath::String, filename::String)

Save SmiteSMLD data back to SMITE's SMD .mat format.

# Arguments
- `smld::SmiteSMLD`: SMLD object to save
- `filepath::String`: Directory path where to save the file
- `filename::String`: Name of the output .mat file

# Notes
- Saves in MATLAB v7.3 format
- Preserves all metadata fields whose names are not emitter columns; an emitter column wins over
  a metadata entry of the same name, so data that get `Z` and `Z_SE` here replace a metadata `Z`
  or `Z_SE` that v0.7.0 would have written
- Writes `Z` and `Z_SE` for an `Emitter3DFit` element type (as v0.7.0 did), or for non-empty 3D
  data (`emitter_ndims`) whose every emitter has properties `z` and `σ_z` and whose `z` and `σ_z`
  columns each come out as a `Vector{Float32}` or `Vector{Float64}`. Otherwise it writes v0.7.0's
  columns, with no `Z`, and warns when non-empty 3D or mixed 2D/3D data lose `Z` (a SMITE SMD
  file has one `Z` column for all localizations, so save 2D and 3D data separately to keep it).
  It never throws where v0.7.0 saved.
- Only `Float32` and `Float64` columns widen, because MATLAB stores those as single and double:
  MAT.jl writes `Float64`, `Float32`, `Int` and `Bool` vectors but throws on `Float16`,
  `Rational`, `BigFloat` and `missing`, and writes a mixed `Float32`/`Float64` column as a cell.
- A type whose `propertynames` lists a property that `getproperty` refuses breaks Julia's
  property interface and is not supported.
"""
function save_smite(smld::SmiteSMLD, filepath::String, filename::String)
    # Create SMD structure
    s = Dict{String,Any}()
    
    n = length(smld.emitters)

    # Z columns for v0.7.0's rule (an Emitter3DFit element type), or for non-empty 3D data whose
    # z and σ_z columns MAT writes as MATLAB single or double. Anything else gets v0.7.0's columns
    # and never throws where v0.7.0 saved; non-empty 3D or mixed data that lose Z get a warning.
    d = emitter_ndims(smld.emitters)
    zcols = nothing
    if eltype(smld.emitters) <: Emitter3DFit
        zcols = ([e.z for e in smld.emitters], [e.σ_z for e in smld.emitters])
    elseif d == 3 && !isempty(smld.emitters) &&
           all(e -> hasproperty(e, :z) && hasproperty(e, :σ_z), smld.emitters)
        z, σz = [e.z for e in smld.emitters], [e.σ_z for e in smld.emitters]
        eltype(z) in (Float32, Float64) && eltype(σz) in (Float32, Float64) && (zcols = (z, σz))
    end
    if zcols === nothing && !isempty(smld.emitters)
        d === nothing && @warn("save_smite: mixed 2D/3D emitters: Z not saved; " *
                               "save 2D and 3D data separately")
        d == 3 && @warn("save_smite: 3D emitters without Float32/Float64 z and σ_z: Z not saved")
    end
    
    # Extract arrays from emitters
    s["X"] = [e.x for e in smld.emitters]
    s["Y"] = [e.y for e in smld.emitters]
    if zcols !== nothing
        s["Z"] = zcols[1]
    end
    
    s["Photons"] = [e.photons for e in smld.emitters]
    s["Bg"] = [e.bg for e in smld.emitters]
    
    s["X_SE"] = [e.σ_x for e in smld.emitters]
    s["Y_SE"] = [e.σ_y for e in smld.emitters]
    if zcols !== nothing
        s["Z_SE"] = zcols[2]
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
