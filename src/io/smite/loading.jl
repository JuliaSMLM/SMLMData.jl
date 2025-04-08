"""
    has_nonzero_imag(value)

Check if a value has a non-zero imaginary component.
Works for both scalar values and arrays.
"""
function has_nonzero_imag(value)
    if isa(value, Complex) || eltype(value) <: Complex
        # For arrays, check if any element has non-zero imaginary part
        if isa(value, AbstractArray)
            return any(imag.(value) .!= 0)
        else
            # For scalar complex values
            return imag(value) != 0
        end
    end
    return false  # Not complex
end

"""
    check_complex_fields(s, fields)

Check if any of the given fields in s are complex and have non-zero imaginary components.
Returns a tuple with:
1. Boolean indicating if any fields are complex with non-zero imaginary parts
2. Dict mapping field names to arrays of indices with non-zero imaginary parts
"""
function check_complex_fields(s, fields)
    has_complex = false
    complex_indices = Dict{String, Vector{Int}}()
    
    for field in fields
        if haskey(s, field) && has_nonzero_imag(s[field])
            has_complex = true
            
            # Find indices with non-zero imaginary parts
            if isa(s[field], AbstractArray)
                indices = findall(imag.(s[field]) .!= 0)
                complex_indices[field] = [idx[1] for idx in indices]  # Extract linear indices
            end
        end
    end
    
    return has_complex, complex_indices
end

"""
    get_valid_indices(s, complex_indices)

Get indices of elements that don't have complex values with non-zero imaginary parts
in any field.
"""
function get_valid_indices(s, complex_indices)
    n = size(s["FrameNum"], 1)
    
    # Start with all indices
    valid_indices = collect(1:n)
    
    # Remove indices that have complex values in any field
    all_complex_indices = Set{Int}()
    for indices in values(complex_indices)
        union!(all_complex_indices, indices)
    end
    
    setdiff!(valid_indices, all_complex_indices)
    return valid_indices
end

"""
    load_smite_2d(smd::SmiteSMD)

Load a 2D Smite SMD .mat file and convert it to SmiteSMLD format.
Checks for complex fields and removes emitters with non-zero imaginary components.

# Arguments
- `smd::SmiteSMD`: SmiteSMD object specifying the file to load

# Returns
SmiteSMLD containing 2D localizations

# Notes
- All spatial coordinates are converted to microns
- If PixelSize is not specified in the file, defaults to 0.1 microns
- Emitters with non-zero imaginary components will be excluded with a warning
"""
function load_smite_2d(smd::SmiteSMD)
    # Load matlab file 
    p = joinpath(smd.filepath, smd.filename)
    file = matopen(p)
    s = read(file, smd.varname)
    close(file)
    
    n = size(s["FrameNum"], 1)
    
    # Check for complex fields
    fields_to_check = ["X", "Y", "Photons", "Bg", "X_SE", "Y_SE", "Photons_SE", "Bg_SE"]
    has_complex, complex_indices = check_complex_fields(s, fields_to_check)
    
    if has_complex
        valid_indices = get_valid_indices(s, complex_indices)
        removed_count = n - length(valid_indices)
        
        # Issue a warning
        @warn "Found $(removed_count) emitters with non-zero imaginary components. These will be excluded from the result." fields_with_complex=collect(keys(complex_indices))
    else
        valid_indices = 1:n
    end
    
    # Create camera
    pixel_size = get(s, "PixelSize", 0.1) # default 0.1 microns if not specified
    camera = IdealCamera(1:Int(s["XSize"]), 1:Int(s["YSize"]), pixel_size)
    
    # Create emitters (only for valid indices)
    n_valid = length(valid_indices)
    emitters = Vector{Emitter2DFit{Float64}}(undef, n_valid)
    T = Float64

    for (new_idx, i) in enumerate(valid_indices)
        emitters[new_idx] = Emitter2DFit{T}(
            real(s["X"][i]), real(s["Y"][i]),             # x, y (take real part)
            real(s["Photons"][i]), real(s["Bg"][i]),      # photons, background
            real(s["X_SE"][i]), real(s["Y_SE"][i]),       # σ_x, σ_y
            real(s["Photons_SE"][i]), real(s["Bg_SE"][i]);# σ_photons, σ_bg
            frame=Int(s["FrameNum"][i]),
            dataset=Int(s["DatasetNum"][i]),
            track_id=Int(s["ConnectID"][i]),
            id=i
        )
    end
    
    # Create metadata
    metadata = Dict{String,Any}(
        "original_file" => smd.filename,
        "data_size" => [Int(s["YSize"]), Int(s["XSize"])],
        "pixel_size" => pixel_size
    )
    
    # Add complex field information to metadata if any were found
    if has_complex
        metadata["complex_fields_removed"] = true
        metadata["complex_fields"] = collect(keys(complex_indices))
        metadata["original_emitter_count"] = n
        metadata["removed_emitter_count"] = n - length(valid_indices)
    end
    
    # Add any additional fields from SMITE
    for key in keys(s)
        if !in(key, ["X", "Y", "Photons", "Bg", "X_SE", "Y_SE", "Photons_SE", "Bg_SE",
                     "FrameNum", "DatasetNum", "ConnectID", "XSize", "YSize", "NFrames", 
                     "NDatasets", "PixelSize"])
            metadata[key] = s[key]
        end
    end
    
    SmiteSMLD{Float64,Emitter2DFit{Float64}}(
        emitters, 
        camera,
        Int(s["NFrames"]),
        Int(s["NDatasets"]),
        metadata
    )
end

"""
    load_smite_3d(smd::SmiteSMD)

Load a 3D Smite SMD .mat file and convert it to SmiteSMLD format.
Checks for complex fields and removes emitters with non-zero imaginary components.

# Arguments
- `smd::SmiteSMD`: SmiteSMD object specifying the file to load

# Returns
SmiteSMLD containing 3D localizations

# Notes
- All spatial coordinates are converted to microns
- If PixelSize is not specified in the file, defaults to 0.1 microns
- Emitters with non-zero imaginary components will be excluded with a warning
"""
function load_smite_3d(smd::SmiteSMD)
    # Load matlab file 
    p = joinpath(smd.filepath, smd.filename)
    file = matopen(p)
    s = read(file, smd.varname)
    close(file)
    
    n = size(s["FrameNum"], 1)
    
    # Check for complex fields
    fields_to_check = ["X", "Y", "Z", "Photons", "Bg", "X_SE", "Y_SE", "Z_SE", "Photons_SE", "Bg_SE"]
    has_complex, complex_indices = check_complex_fields(s, fields_to_check)
    
    if has_complex
        valid_indices = get_valid_indices(s, complex_indices)
        removed_count = n - length(valid_indices)
        
        # Issue a warning
        @warn "Found $(removed_count) emitters with non-zero imaginary components. These will be excluded from the result." fields_with_complex=collect(keys(complex_indices))
    else
        valid_indices = 1:n
    end
    
    # Create camera
    pixel_size = get(s, "PixelSize", 0.1) # default 0.1 microns if not specified
    camera = IdealCamera(1:Int(s["XSize"]), 1:Int(s["YSize"]), pixel_size)
    
    # Create emitters (only for valid indices)
    n_valid = length(valid_indices)
    emitters = Vector{Emitter3DFit{Float64}}(undef, n_valid)
    
    for (new_idx, i) in enumerate(valid_indices)
        emitters[new_idx] = Emitter3DFit{Float64}(
            real(s["X"][i]), real(s["Y"][i]), real(s["Z"][i]),       # x, y, z (take real part)
            real(s["Photons"][i]), real(s["Bg"][i]),                 # photons, background
            real(s["X_SE"][i]), real(s["Y_SE"][i]), real(s["Z_SE"][i]), # σ_x, σ_y, σ_z
            real(s["Photons_SE"][i]), real(s["Bg_SE"][i]);           # σ_photons, σ_bg
            frame=Int(s["FrameNum"][i]),
            dataset=Int(s["DatasetNum"][i]),
            track_id=Int(s["ConnectID"][i]),
            id=i
        )
    end
    
    # Create metadata
    metadata = Dict{String,Any}(
        "original_file" => smd.filename,
        "data_size" => [Int(s["YSize"]), Int(s["XSize"]), Int(s["ZSize"])],
        "pixel_size" => pixel_size
    )
    
    # Add complex field information to metadata if any were found
    if has_complex
        metadata["complex_fields_removed"] = true
        metadata["complex_fields"] = collect(keys(complex_indices))
        metadata["original_emitter_count"] = n
        metadata["removed_emitter_count"] = n - length(valid_indices)
    end
    
    # Add any additional fields from SMITE
    for key in keys(s)
        if !in(key, ["X", "Y", "Z", "Photons", "Bg", "X_SE", "Y_SE", "Z_SE", "Photons_SE", 
                     "Bg_SE", "FrameNum", "DatasetNum", "ConnectID", "XSize", "YSize", 
                     "ZSize", "NFrames", "NDatasets", "PixelSize"])
            metadata[key] = s[key]
        end
    end
    
    SmiteSMLD{Float64,Emitter3DFit{Float64}}(
        emitters, 
        camera,
        Int(s["NFrames"]),
        Int(s["NDatasets"]),
        metadata
    )
end
