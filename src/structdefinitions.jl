# This file defines some struct types used in the SMLMData package.
using DataFrames 

abstract type SMLD end

mutable struct SMLD2D <: SMLD
    connectID::Vector{Int}
    x::Vector{Float64}
    y::Vector{Float64}
    σ_x::Vector{Float64}
    σ_y::Vector{Float64}
    framenum::Vector{Int}
    datasetnum::Vector{Int}
    datasize::Vector{Int}
    nframes::Int
    ndatasets::Int
    datafields::NTuple{7, Symbol}
    SMLD2D() = new()
end

"""
    SMLD2D(nlocalizations::Int)

Constructor to generate an empty `smld` with a specific size.

# Description
This is a constructor for the SMLD2D struct which allows you to populate the
structure with undefined values for a predefined number of localizations.
"""
function SMLD2D(nlocalizations::Int)
    smld = SMLD2D()
    floatfill = Vector{Float64}(undef, nlocalizations)
    smld.x = floatfill
    smld.y = floatfill
    smld.σ_x = floatfill
    smld.σ_y = floatfill
    intfill = Vector{Int}(undef, nlocalizations)
    smld.connectID = intfill
    smld.framenum = intfill
    smld.datasetnum = intfill
    smld.nframes = 0
    smld.ndatasets = 0
    smld.datasize = [0; 0]
    smld.datafields = (:connectID, :x, :y, :σ_x, :σ_y, :framenum, :datasetnum)

    return smld
end

"""
    SMLD2D(nlocalizations::Int)

Constructor to generate an `smld` from a data frame.

# Description
This is a constructor for the SMLD2D struct which allows you to populate the
structure with data defined in the dataframe `data`. The intention is that a
.csv table can be organized with localizations on each row as
[datasetnum, framenum, x, y, σ_x, σ_y], loaded using the CSV package, and 
placed into a dataframe with the DataFrames package.
"""
function SMLD2D(data::DataFrames.DataFrame)
    smld = SMLD2D()
    smld.connectID = collect(1:size(data)[1])
    smld.datasetnum = Int.(data[:, 1])
    smld.framenum = Int.(data[:, 2])
    smld.x = Float64.(data[:, 3])
    smld.y = Float64.(data[:, 4])
    smld.σ_x = Float64.(data[:, 5])
    smld.σ_y = Float64.(data[:, 6])
    smld.nframes = Int(maximum(smld.framenum))
    smld.ndatasets = Int(length(unique(smld.datasetnum)))
    smld.datasize = [ceil(maximum(data[:, 3]) - 0.5);
                     ceil(maximum(data[:, 4]) - 0.5)]
    smld.datafields = (:connectID, :x, :y, :σ_x, :σ_y, :framenum, :datasetnum)

    return smld
end