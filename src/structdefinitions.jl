# This file defines some struct types used in the SMLMData package.
using DataFrames 

"""
    SMLD(connectID::Vector{Int64}, x::Vector{Float32}, y::Vector{Float32},
        x_se::Vector{Float32}, y_se::Vector{Float32}, framenum::Vector{Int64},
        nframes::Int64, datasetnum::Vector{Int64}, ndatasets::Int64)

Single Molecule Localization Data structure with information about localizations.
"""
mutable struct SMLD
    connectID::Vector{Int64}
    x::Vector{Float32}
    y::Vector{Float32}
    x_se::Vector{Float32}
    y_se::Vector{Float32}
    framenum::Vector{Int64}
    nframes::Int64
    datasetnum::Vector{Int64}
    ndatasets::Int64
    SMLD() = new()
end
function SMLD(nlocalizations::Int)
    smld = SMLD()
    floatfill = Vector{Float32}(undef, nlocalizations)
    smld.x = floatfill
    smld.y = floatfill
    smld.x_se = floatfill
    smld.y_se = floatfill
    intfill = Vector{Int64}(undef, nlocalizations)
    smld.framenum = intfill
    smld.datasetnum = intfill

    return smld
end
function SMLD(data::DataFrames.DataFrame)
    smld = SMLD()
    smld.datasetnum = Int64.(data[:, 1])
    smld.framenum = Int64.(data[:, 2])
    smld.x = Float32.(data[:, 3])
    smld.y = Float32.(data[:, 4])
    smld.x_se = Float32.(data[:, 5])
    smld.y_se = Float32.(data[:, 6])
    smld.nframes = Int64(maximum(smld.framenum))
    smld.ndatasets = Int64(length(unique(smld.datasetnum)))

    return smld
end