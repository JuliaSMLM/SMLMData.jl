"""
    load_smite_2d(smd::SmiteSMD)

Load a 2D Smite SMD .mat file and convert it to SmiteSMLD format.

# Arguments
- `smd::SmiteSMD`: SmiteSMD object specifying the file to load

# Returns
SmiteSMLD containing 2D localizations

# Notes
- All spatial coordinates are converted to microns
- If PixelSize is not specified in the file, defaults to 0.1 microns
"""
function load_smite_2d(smd::SmiteSMD)
    # Load matlab file 
    p = joinpath(smd.filepath, smd.filename)
    file = matopen(p)
    s = read(file, smd.varname)
    close(file)
    
    n = size(s["FrameNum"], 1)
    
    # Create camera
    pixel_size = get(s, "PixelSize", 0.1) # default 0.1 microns if not specified
    camera = IdealCamera(1:Int(s["XSize"]), 1:Int(s["YSize"]), pixel_size)
    
    # Create emitters
    emitters = Vector{Emitter2DFit{Float64}}(undef, n)
    for i in 1:n
        emitters[i] = Emitter2DFit{Float64}(
            s["X"][i], s["Y"][i],           # x, y
            s["Photons"][i], s["Bg"][i],    # photons, background
            s["X_SE"][i], s["Y_SE"][i],     # σ_x, σ_y
            s["Photons_SE"][i], s["Bg_SE"][i], # σ_photons, σ_bg
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

# Arguments
- `smd::SmiteSMD`: SmiteSMD object specifying the file to load

# Returns
SmiteSMLD containing 3D localizations

# Notes
- All spatial coordinates are converted to microns
- If PixelSize is not specified in the file, defaults to 0.1 microns
"""
function load_smite_3d(smd::SmiteSMD)
    # Load matlab file 
    p = joinpath(smd.filepath, smd.filename)
    file = matopen(p)
    s = read(file, smd.varname)
    close(file)
    
    n = size(s["FrameNum"], 1)
    
    # Create camera
    pixel_size = get(s, "PixelSize", 0.1) # default 0.1 microns if not specified
    camera = IdealCamera(1:Int(s["XSize"]), 1:Int(s["YSize"]), pixel_size)
    
    # Create emitters
    emitters = Vector{Emitter3DFit{Float64}}(undef, n)
    for i in 1:n
        emitters[i] = Emitter3DFit{Float64}(
            s["X"][i], s["Y"][i], s["Z"][i],    # x, y, z
            s["Photons"][i], s["Bg"][i],        # photons, background
            s["X_SE"][i], s["Y_SE"][i], s["Z_SE"][i], # σ_x, σ_y, σ_z
            s["Photons_SE"][i], s["Bg_SE"][i],  # σ_photons, σ_bg
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
