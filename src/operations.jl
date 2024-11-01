"""
    cat_smld(smlds::Vector{<:SMLD})
    cat_smld(smlds::SMLD...)

Concatenate multiple SMLD objects into a single SMLD.

# Arguments
- `smlds`: Vector of SMLD objects or multiple SMLD arguments

# Returns
New SMLD containing all emitters from inputs

# Notes
- Camera must be identical across all SMLDs
- n_frames is set to maximum frame number across all inputs
- n_datasets is set to maximum dataset number across all inputs
- Metadata from first SMLD is used, with conflicts noted in metadata

# Examples
```julia
# Concatenate two SMLDs
combined = cat_smld(smld1, smld2)

# Concatenate multiple SMLDs
combined = cat_smld(smld1, smld2, smld3)

# Concatenate vector of SMLDs
combined = cat_smld([smld1, smld2, smld3])
```
"""
function cat_smld(smlds::Vector{<:SMLD})
    isempty(smlds) && error("No SMLDs to concatenate")
    length(smlds) == 1 && return first(smlds)
    
    # Check camera compatibility
    ref_camera = smlds[1].camera
    for smld in smlds[2:end]
        if !is_same_camera(ref_camera, smld.camera)
            error("Cannot concatenate SMLDs with different cameras")
        end
    end
    
    # Concatenate emitters
    all_emitters = vcat([smld.emitters for smld in smlds]...)
    
    # Find maximum frame and dataset numbers
    max_frames = maximum(smld.n_frames for smld in smlds)
    max_datasets = maximum(smld.n_datasets for smld in smlds)
    
    # Combine metadata
    metadata = copy(smlds[1].metadata)
    metadata["concatenated_from"] = length(smlds)
    
    return typeof(first(smlds))(
        all_emitters,
        ref_camera,
        max_frames,
        max_datasets,
        metadata
    )
end

# Varargs version
cat_smld(smlds::SMLD...) = cat_smld(collect(smlds))

"""
    merge_smld(smlds::Vector{<:SMLD}; adjust_frames=false, adjust_datasets=false)
    merge_smld(smlds::SMLD...; adjust_frames=false, adjust_datasets=false)

Merge multiple SMLD objects with options to adjust frame and dataset numbering.

# Arguments
- `smlds`: Vector of SMLD objects or multiple SMLD arguments
- `adjust_frames`: If true, adjusts frame numbers to be sequential
- `adjust_datasets`: If true, adjusts dataset numbers to be sequential

# Returns
New SMLD containing all emitters with adjusted numbering if requested

# Notes
- Camera must be identical across all SMLDs
- When adjust_frames=true, frame numbers are made sequential across all inputs
- When adjust_datasets=true, dataset numbers are made sequential
- Metadata includes information about the merge operation

# Examples
```julia
# Simple merge
merged = merge_smld(smld1, smld2)

# Merge with frame number adjustment
merged = merge_smld(smld1, smld2, adjust_frames=true)

# Merge multiple with both adjustments
merged = merge_smld([smld1, smld2, smld3], 
                   adjust_frames=true, 
                   adjust_datasets=true)
```
"""
function merge_smld(smlds::Vector{<:SMLD}; 
                   adjust_frames::Bool=false, 
                   adjust_datasets::Bool=false)
    isempty(smlds) && error("No SMLDs to merge")
    length(smlds) == 1 && return first(smlds)
    
    # Check camera compatibility
    if !all(is_same_camera(smlds[1].camera, smld.camera) for smld in smlds[2:end])
        error("Cannot merge SMLDs with different cameras")
    end
    
    # Initialize with copied emitters from first SMLD
    all_emitters = copy(smlds[1].emitters)
    frame_offset = smlds[1].n_frames
    dataset_offset = smlds[1].n_datasets
    
    # Process each additional SMLD
    for (i, smld) in enumerate(smlds[2:end])
        new_emitters = copy(smld.emitters)
        
        if adjust_frames
            # Adjust frame numbers to be sequential
            for e in new_emitters
                e.frame += frame_offset
            end
            frame_offset += smld.n_frames
        end
        
        if adjust_datasets
            # Adjust dataset numbers to be sequential
            for e in new_emitters
                e.dataset += dataset_offset
            end
            dataset_offset += smld.n_datasets
        end
        
        append!(all_emitters, new_emitters)
    end
    
    # Calculate new n_frames and n_datasets
    new_n_frames = if adjust_frames
        sum(smld.n_frames for smld in smlds)
    else
        maximum(smld.n_frames for smld in smlds)
    end
    
    new_n_datasets = if adjust_datasets
        sum(smld.n_datasets for smld in smlds)
    else
        maximum(smld.n_datasets for smld in smlds)
    end
    
    # Combine metadata
    metadata = copy(smlds[1].metadata)
    metadata["merged_from"] = length(smlds)
    metadata["frame_adjustment"] = adjust_frames
    metadata["dataset_adjustment"] = adjust_datasets
    
    return typeof(first(smlds))(
        all_emitters,
        smlds[1].camera,
        new_n_frames,
        new_n_datasets,
        metadata
    )
end

# Varargs version
merge_smld(smlds::SMLD...; kwargs...) = merge_smld(collect(smlds); kwargs...)

# Helper function to check camera compatibility
function is_same_camera(cam1::AbstractCamera, cam2::AbstractCamera)
    return typeof(cam1) === typeof(cam2) &&
           cam1.pixel_edges_x == cam2.pixel_edges_x &&
           cam1.pixel_edges_y == cam2.pixel_edges_y
end
