# This file defines some struct types used in the SMLMData package.
"""
    SMLD 

 SMLD is the highest level abstract type in SMLMData.    
"""
abstract type SMLD end

"""
    mutable struct SMLD3D <: SMLD

This struct represents a 2D Single Molecule Localization Microscopy (SMLM) dataset.

# Fields
- `connectID::Vector{Int}`: Connect IDs.
- `x::Vector{Float64}`: X coordinates.
- `y::Vector{Float64}`: Y coordinates.
- `σ_x::Vector{Float64}`: Uncertainties in X.
- `σ_y::Vector{Float64}`: Uncertainties in Y.
- `photons::Vector{Float64}`: Photon counts.
- `σ_photons::Vector{Float64}`: Uncertainties in photon counts.
- `bg::Vector{Float64}`: Background values.
- `σ_bg::Vector{Float64}`: Uncertainties in background.
- `framenum::Vector{Int}`: Frame numbers.
- `datasetnum::Vector{Int}`: Dataset numbers.
- `datasize::Vector{Int}`: Size of the dataset.
- `nframes::Int`: Number of frames.
- `ndatasets::Int`: Number of datasets.
- `datafields::NTuple{11, Symbol}`: Tuple of data field names.
"""
mutable struct SMLD2D
    connectID::Vector{Int}
    x::Vector{Float64}
    y::Vector{Float64}
    σ_x::Vector{Float64}
    σ_y::Vector{Float64}
    photons::Vector{Float64}
    σ_photons::Vector{Float64}
    bg::Vector{Float64}
    σ_bg::Vector{Float64}
    framenum::Vector{Int}
    datasetnum::Vector{Int}
    datasize::Vector{Int}
    nframes::Int
    ndatasets::Int
    datafields::NTuple{11,Symbol}
end

"""
    SMLD2D(; kwargs...)

Constructs an `SMLD2D` object. All fields are keyword arguments and have default values.

# Arguments
- `connectID::Vector{Int}=Int[]`: Connect IDs. Defaults to empty vector.
- `x::Vector{Float64}=Float64[]`: X coordinates. Defaults to empty vector.
- `y::Vector{Float64}=Float64[]`: Y coordinates. Defaults to empty vector.
- `σ_x::Vector{Float64}=Float64[]`: Uncertainties in X. Defaults to empty vector.
- `σ_y::Vector{Float64}=Float64[]`: Uncertainties in Y. Defaults to empty vector.
- `photons::Vector{Float64}=Float64[]`: Photon counts. Defaults to empty vector.
- `σ_photons::Vector{Float64}=Float64[]`: Uncertainties in photon counts. Defaults to empty vector.
- `bg::Vector{Float64}=Float64[]`: Background values. Defaults to empty vector.
- `σ_bg::Vector{Float64}=Float64[]`: Uncertainties in background. Defaults to empty vector.
- `framenum::Vector{Int}=Int[]`: Frame numbers. Defaults to empty vector.
- `datasetnum::Vector{Int}=Int[]`: Dataset numbers. Defaults to empty vector.
- `datasize::Vector{Int}=Int[]`: Size of the dataset. Defaults to empty vector.
- `nframes::Int=0`: Number of frames. Defaults to zero.
- `ndatasets::Int=0`: Number of datasets. Defaults to zero.
- `datafields::NTuple{11, Symbol}=(:connectID, :x, :y, :σ_x, :σ_y, :photons, :σ_photons, :bg, :σ_bg, :framenum, :datasetnum)`: Tuple of data field names. 

# Returns
- `SMLD2D`: A new `SMLD2D` object.

# Notes
If vectors with unequal lengths are provided, all vectors will be initialized to the length of 
the longest vector and filled with zeros.
"""
function SMLD2D(; connectID::Vector{Int}=Int[],
    x::Vector{Float64}=Float64[],
    y::Vector{Float64}=Float64[],
    σ_x::Vector{Float64}=Float64[],
    σ_y::Vector{Float64}=Float64[],
    photons::Vector{Float64}=Float64[],
    σ_photons::Vector{Float64}=Float64[],
    bg::Vector{Float64}=Float64[],
    σ_bg::Vector{Float64}=Float64[],
    framenum::Vector{Int}=Int[],
    datasetnum::Vector{Int}=Int[],
    datasize::Vector{Int}=Int[],
    nframes::Int=0,
    ndatasets::Int=0,
    datafields::NTuple{11,Symbol}=(:connectID, :x, :y, :σ_x, :σ_y, :photons, :σ_photons, :bg, :σ_bg, :framenum, :datasetnum)
)

    n = max(length(connectID),
        length(x),
        length(y),
        length(σ_x),
        length(σ_y),
        length(photons),
        length(σ_photons),
        length(bg),
        length(σ_bg),
        length(framenum),
        length(datasetnum)
    )

    connectID = length(connectID) == n ? connectID : zeros(Int, n)
    x = length(x) == n ? x : zeros(Float64, n)
    y = length(y) == n ? y : zeros(Float64, n)
    σ_x = length(σ_x) == n ? σ_x : zeros(Float64, n)
    σ_y = length(σ_y) == n ? σ_y : zeros(Float64, n)
    photons = length(photons) == n ? photons : zeros(Float64, n)
    σ_photons = length(σ_photons) == n ? σ_photons : zeros(Float64, n)
    bg = length(bg) == n ? bg : zeros(Float64, n)
    σ_bg = length(σ_bg) == n ? σ_bg : zeros(Float64, n)
    framenum = length(framenum) == n ? framenum : zeros(Int, n)
    datasetnum = length(datasetnum) == n ? datasetnum : zeros(Int, n)
    datasize = length(datasize) == n ? datasize : zeros(Int, n)
    datafields = isempty(datafields) ? (:connectID, :x, :y, :σ_x, :σ_y, :photons, :σ_photons, :bg, :σ_bg, :framenum, :datasetnum) : datafields
    return SMLD2D(connectID, x, y, σ_x, σ_y, photons, σ_photons, bg, σ_bg, framenum, datasetnum, datasize, nframes, ndatasets, datafields)
end

"""
    SMLD2D(nlocalizations::Int)

Generate an empty `smld` with a specific size.

# Description
This is a constructor for the SMLD2D struct which allows you to populate the
structure with undefined values for a predefined number of localizations.
"""
function SMLD2D(nlocalizations::Int)
    smld = SMLD2D(; x=zeros(Float64, nlocalizations))
    return smld
end

## SMLD3D specific structures and functions.

"""
    mutable struct SMLD3D <: SMLD 

Structure to store 3D single molecule localization data.

# Fields
- `connectID::Vector{Int}` : Unique identifiers for each localization
- `x::Vector{Float64}` : X-coordinates of localizations
- `y::Vector{Float64}` : Y-coordinates of localizations
- `z::Vector{Float64}` : Z-coordinates of localizations
- `σ_x::Vector{Float64}` : Uncertainty in X-coordinates
- `σ_y::Vector{Float64}` : Uncertainty in Y-coordinates
- `σ_z::Vector{Float64}` : Uncertainty in Z-coordinates
- `photons::Vector{Float64}` : Number of detected photons per localization
- `σ_photons::Vector{Float64}` : Uncertainty in the number of detected photons
- `bg::Vector{Float64}` : Background signal
- `σ_bg::Vector{Float64}` : Uncertainty in the background signal
- `framenum::Vector{Int}` : Frame number of each localization
- `datasetnum::Vector{Int}` : Dataset number of each localization
- `datasize::Vector{Int}` : Size of the dataset
- `nframes::Int` : Total number of frames
- `ndatasets::Int` : Total number of datasets
- `datafields::NTuple{13, Symbol}` : Tuple containing the names of the fields
"""
mutable struct SMLD3D <: SMLD
    connectID::Vector{Int}
    x::Vector{Float64}
    y::Vector{Float64}
    z::Vector{Float64}
    σ_x::Vector{Float64}
    σ_y::Vector{Float64}
    σ_z::Vector{Float64}
    photons::Vector{Float64}
    σ_photons::Vector{Float64}
    bg::Vector{Float64}
    σ_bg::Vector{Float64}
    framenum::Vector{Int}
    datasetnum::Vector{Int}
    datasize::Vector{Int}
    nframes::Int
    ndatasets::Int
    datafields::NTuple{13,Symbol}
end

"""
    SMLD3D(; kwargs...)

Constructs an `SMLD3D` object. All fields are keyword arguments and have default values.

# Arguments
- `connectID::Vector{Int}=Int[]`: Connect IDs. Defaults to empty vector.
- `x::Vector{Float64}=Float64[]`: X coordinates. Defaults to empty vector.
- `y::Vector{Float64}=Float64[]`: Y coordinates. Defaults to empty vector.
- `z::Vector{Float64}=Float64[]`: Z coordinates. Defaults to empty vector.
- `σ_x::Vector{Float64}=Float64[]`: Uncertainties in X. Defaults to empty vector.
- `σ_y::Vector{Float64}=Float64[]`: Uncertainties in Y. Defaults to empty vector.
- `σ_z::Vector{Float64}=Float64[]`: Uncertainties in Z. Defaults to empty vector.
- `photons::Vector{Float64}=Float64[]`: Photon counts. Defaults to empty vector.
- `σ_photons::Vector{Float64}=Float64[]`: Uncertainties in photon counts. Defaults to empty vector.
- `bg::Vector{Float64}=Float64[]`: Background values. Defaults to empty vector.
- `σ_bg::Vector{Float64}=Float64[]`: Uncertainties in background. Defaults to empty vector.
- `framenum::Vector{Int}=Int[]`: Frame numbers. Defaults to empty vector.
- `datasetnum::Vector{Int}=Int[]`: Dataset numbers. Defaults to empty vector.
- `datasize::Vector{Int}=Int[]`: Size of the dataset. Defaults to empty vector.
- `nframes::Int=0`: Number of frames. Defaults to zero.
- `ndatasets::Int=0`: Number of datasets. Defaults to zero.
- `datafields::NTuple{13, Symbol}=(:connectID, :x, :y, :z, :σ_x, :σ_y, :σ_z, :photons, :σ_photons, :bg, :σ_bg, :framenum, :datasetnum)`: Tuple of data field names. 

# Returns
- `SMLD3D`: A new `SMLD3D` object.

# Notes
If vectors with unequal lengths are provided, all vectors will be initialized to the length of 
the longest vector and filled with zeros.
"""
function SMLD3D(; connectID::Vector{Int}=Int[],
    x::Vector{Float64}=Float64[],
    y::Vector{Float64}=Float64[],
    z::Vector{Float64}=Float64[],
    σ_x::Vector{Float64}=Float64[],
    σ_y::Vector{Float64}=Float64[],
    σ_z::Vector{Float64}=Float64[],
    photons::Vector{Float64}=Float64[],
    σ_photons::Vector{Float64}=Float64[],
    bg::Vector{Float64}=Float64[],
    σ_bg::Vector{Float64}=Float64[],
    framenum::Vector{Int}=Int[],
    datasetnum::Vector{Int}=Int[],
    datasize::Vector{Int}=Int[],
    nframes::Int=0,
    ndatasets::Int=0,
    datafields::NTuple{13,Symbol}=(:connectID, :x, :y, :z, :σ_x, :σ_y, :σ_z, :photons, :σ_photons, :bg, :σ_bg, :framenum, :datasetnum)
)

    n = max(length(connectID),
        length(x),
        length(y),
        length(z),
        length(σ_x),
        length(σ_y),
        length(σ_z),
        length(photons),
        length(σ_photons),
        length(bg),
        length(σ_bg),
        length(framenum),
        length(datasetnum)
    )

    connectID = length(connectID) == n ? connectID : zeros(Int, n)
    x = length(x) == n ? x : zeros(Float64, n)
    y = length(y) == n ? y : zeros(Float64, n)
    z = length(z) == n ? z : zeros(Float64, n)
    σ_x = length(σ_x) == n ? σ_x : zeros(Float64, n)
    σ_y = length(σ_y) == n ? σ_y : zeros(Float64, n)
    σ_z = length(σ_z) == n ? σ_z : zeros(Float64, n)
    photons = length(photons) == n ? photons : zeros(Float64, n)
    σ_photons = length(σ_photons) == n ? σ_photons : zeros(Float64, n)
    bg = length(bg) == n ? bg : zeros(Float64, n)
    σ_bg = length(σ_bg) == n ? σ_bg : zeros(Float64, n)
    framenum = length(framenum) == n ? framenum : zeros(Int, n)
    datasetnum = length(datasetnum) == n ? datasetnum : zeros(Int, n)
    datasize = length(datasize) == n ? datasize : zeros(Int, n)
    datafields = isempty(datafields) ? (:connectID, :x, :y, :z, :σ_x, :σ_y, :σ_z, :photons, :σ_photons, :bg, :σ_bg, :framenum, :datasetnum) : datafields
    return SMLD3D(connectID, x, y, z, σ_x, σ_y, σ_z, photons, σ_photons, bg, σ_bg, framenum, datasetnum, datasize, nframes, ndatasets, datafields)
end


"""
    SMLD3D(nlocalizations::Int)

Generate an empty `smld` with a specific size.

# Description
This is a constructor for the SMLD3D struct which allows you to populate the
structure with undefined values for a predefined number of localizations.
"""
function SMLD3D(nlocalizations::Int)
    smld = SMLD3D(; x=zeros(Float64, nlocalizations))
    return smld
end


## Generic functions for any SMLD type.
"""
    Base.length(smld::SMLMData.SMLD)

Returns the number of localizations in `smld`.
"""
function Base.length(smld::SMLMData.SMLD)
    # Determine the length of `smld` by counting the number of frames.
    return Base.length(smld.framenum)
end

"""
    Base.getindex(smld::SMLMData.SMLD, ind)

Returns the requested localization from `smld`.
"""
function Base.getindex(smld::SMLMData.SMLD, ind)
    return SMLMData.isolatesmld(smld, ind)
end