# This file defines some struct types used in the SMLMData package.
using DataFrames 

mutable struct SMLD
    connectID::Vector{Int}
    x::Vector{Float32}
    y::Vector{Float32}
    x_se::Vector{Float32}
    y_se::Vector{Float32}
    framenum::Vector{Int}
    datasetnum::Vector{Int}
    nframes::Int
    ndatasets::Int
    ysize::Int
    xsize::Int
    SMLD() = new()
end

"""
    SMLD(nlocalizations::Int)

Constructor to generate an empty `smld` with a specific size.

# Description
This is a constructor for the SMLD struct which allows you to populate the
structure with undefined values for a predefined number of localizations.
"""
function SMLD(nlocalizations::Int)
    smld = SMLD()
    floatfill = Vector{Float32}(undef, nlocalizations)
    smld.x = floatfill
    smld.y = floatfill
    smld.x_se = floatfill
    smld.y_se = floatfill
    intfill = Vector{Int}(undef, nlocalizations)
    smld.framenum = intfill
    smld.datasetnum = intfill
    smld.nframes = 0
    smld.ndatasets = 0
    smld.ysize = 0
    smld.xsize = 0

    return smld
end

"""
    SMLD(nlocalizations::Int)

Constructor to generate an `smld` from a data frame.

# Description
This is a constructor for the SMLD struct which allows you to populate the
structure with data defined in the dataframe `data`. The intention is that a
.csv table can be organized with localizations on each row as
[datasetnum, framenum, x, y, x_se, y_se], loaded using the CSV package, and 
placed into a dataframe with the DataFrames package.
"""
function SMLD(data::DataFrames.DataFrame)
    smld = SMLD()
    smld.datasetnum = Int.(data[:, 1])
    smld.framenum = Int.(data[:, 2])
    smld.x = Float32.(data[:, 3])
    smld.y = Float32.(data[:, 4])
    smld.x_se = Float32.(data[:, 5])
    smld.y_se = Float32.(data[:, 6])
    smld.nframes = Int(maximum(smld.framenum))
    smld.ndatasets = Int(length(unique(smld.datasetnum)))
    smld.ysize = ceil(maximum(data[:, 3]) - 0.5)
    smld.xsize = ceil(maximum(data[:, 4]) - 0.5)

    return smld
end