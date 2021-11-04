# This file contains functions/methods useful for transforming coordinates in
# SMLD structures.

"""
    addoffset!(smld::SMLD2D, offset::Vector{Float64})

Add an offset elementwise to each localization `smld.y` and `smld.x`.

# Inputs
-`offset`: Two element vector describing the offset. ([offset_y; offset_x])
"""
function addoffset!(smld::SMLD2D, offset::Vector{Float64})
    smld.y .+= offset[1]
    smld.x .+= offset[2]
end

"""
    smld_offset = addoffset(smld::SMLD2D, offset::Vector{Float64})

Add an offset elementwise to each localization `smld.y` and `smld.x`.

# Inputs
-`offset`: Two element vector describing the offset. ([offset_y; offset_x])
"""
function addoffset(smld::SMLD2D, offset::Vector{Float64})
    smld_offset = deepcopy(smld)
    smld_offset.y .+= offset[1]
    smld_offset.x .+= offset[2]

    return smld_offset
end