# This file contains functions/methods useful for transforming coordinates in
# SMLD structures.

"""
    addoffset!(smld::SMLD, offset::Vector{Float64})

Add an offset elementwise to each localization coordinate in `smld`.

# Inputs
-`offset`: Vector describing the offset. 
           (for SMLD2D: [offset_y; offset_x], for SMLD3D: [offset_y; offset_x; offset_z])
"""
function addoffset!(smld::SMLD, offset::Vector{Float64})
end

function addoffset!(smld::SMLD2D, offset::Vector{Float64})
    smld.y .+= offset[1]
    smld.x .+= offset[2]

    return smld
end

function addoffset!(smld::SMLD3D, offset::Vector{Float64})
    smld.y .+= offset[1]
    smld.x .+= offset[2]
    smld.z .+= offset[3]

    return smld
end

function addoffset(smld::SMLD, offset::Vector{Float64})
    return addoffset!(deepcopy(smld))
end