# This file defines some struct types used in the SMLMData package.
"""
    SMLD 

 SMLD is the highest level abstract type in SMLMData.    
"""
abstract type SMLD end


## SMLD2D specific structures and functions.

"""
    SMLD2D 

Structure containing 2D localization data

    # Fields
    - connectID: integer ID associating localizations
    - x: x position 
    - y: y position
    - σ_x: standard error uncertainty in x
    - σ_y: standard error uncertainty in y
    - photons: total photons 
    - σ_photons: standard error uncertainty in σ_photons
    - bg: fit fluorescence background (photons/pixel)
    - σ_bg: standard error uncertainty in bg
    - framenum: integer framenumber within a dataset
    - datasetnum: integer dataset number
    - datasize::Vector{Int}: size of image area
    - nframes: integer frames per dataset
    - ndatasets: number of dataasets
    - datafields: bookeeping - do not modify
"""
mutable struct SMLD2D <: SMLD
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
    datafields::NTuple{11, Symbol}
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
    smld.x = zeros(Float64, nlocalizations)
    smld.y = zeros(Float64, nlocalizations)
    smld.σ_x = zeros(Float64, nlocalizations)
    smld.σ_y = zeros(Float64, nlocalizations)
    smld.bg = zeros(Float64, nlocalizations)
    smld.σ_bg = zeros(Float64, nlocalizations)
    smld.photons = zeros(Float64, nlocalizations)
    smld.σ_photons = zeros(Float64, nlocalizations)
    smld.connectID = collect(1:nlocalizations)
    smld.framenum = zeros(Int, nlocalizations)
    smld.datasetnum = zeros(Int, nlocalizations)
    smld.nframes = 0
    smld.ndatasets = 0
    smld.datasize = [0; 0]
    smld.datafields = (:connectID, :x, :y, :σ_x, :σ_y, 
        :photons, :σ_photons, :bg, :σ_bg, :framenum, :datasetnum)

    return smld
end

"""
    SMLD2D(; 
        x=zeros(Float64, 0), 
        y=zeros(Float64, 0), 
        σ_x=zeros(Float64, 0), 
        σ_y=zeros(Float64, 0), 
        bg=zeros(Float64, 0), 
        σ_bg=zeros(Float64, 0),
        photons=ones(Float64, 0),
        σ_photons=zeros(Float64, 0),
        framenum=ones(Int, 0),
        datasetnum=ones(Int, 0),
        nframes = 1,
        ndatasets = 1)

Constructor to generate an `smld` with vectors of data.

# Description
This is a constructor for the SMLD2D struct which allows you to populate the
structure with a vector or vectors of data: x,y,σ_x,σ_y,bg, σ_bg, photons, or σ_photons.
"""
function SMLD2D(;
    x=zeros(Float64, 0), 
    y=zeros(Float64, 0), 
    σ_x=zeros(Float64, 0), 
    σ_y=zeros(Float64, 0), 
    photons=ones(Float64, 0),
    σ_photons=zeros(Float64, 0),
    bg=zeros(Float64, 0), 
    σ_bg=zeros(Float64, 0),
    framenum=ones(Int, 0),
    datasetnum=ones(Int, 0),
    datasize = [0; 0],
    nframes = 1,
    ndatasets = 1)


    #make sure all inputs are in the correct format
    x=float(x)
    y=float(y)
    σ_x=float(σ_x)
    σ_y=float(σ_y)
    photons=float(photons)
    σ_photons=float(σ_photons)
    bg=float(bg)
    σ_bg=float(σ_bg)
    datasize=round.(float(datasize))

    #put the data vectors into a single vector
    data = [x, y, σ_x, σ_y, bg, σ_bg, photons, σ_photons]

    #set nloc equal to the length of the first nonzero vector
    nloc = 0
    for value in data
        if length(value) != 0
            nloc = length(value)
            break
        end
    end

    #check that nloc matches the length of all the vectors inputted
    for value in data
        if nloc != length(value) && nloc != 0 && length(value) != 0
            println("Error: Your data input vectors are not all the same length.")
            return
        end
    end

    #fill each remaining empty keyword argument with the desired vector the length of nloc
    x = isempty(x) ? zeros(Float64, nloc) : x
    y = isempty(y) ? zeros(Float64, nloc) : y
    σ_x = isempty(σ_x) ? zeros(Float64, nloc) : σ_x
    σ_y = isempty(σ_y) ? zeros(Float64, nloc) : σ_y
    photons = isempty(photons) ? ones(Float64, nloc) : photons
    σ_photons = isempty(σ_photons) ? zeros(Float64, nloc) : σ_photons
    bg = isempty(bg) ? zeros(Float64, nloc) : bg
    σ_bg = isempty(σ_bg) ? zeros(Float64, nloc) : σ_bg
    framenum = isempty(framenum) ? ones(Int, nloc) : framenum
    datasetnum = isempty(datasetnum) ? ones(Int, nloc) : datasetnum
    datasize = all(datasize .== 0) ? [round(maximum(y)); round(maximum(x))] : datasize

    #set the values that the user was not allowed to change
    connectID = collect(1:nloc)
    datafields = (:connectID, :x, :y, :σ_x, :σ_y, 
         :photons, :σ_photons, :bg, :σ_bg, :framenum, :datasetnum)


    #fill the smld structure
    smld = SMLD2D(connectID, x, y, σ_x, σ_y, photons, σ_photons, bg, σ_bg,
         framenum, datasetnum, datasize, nframes, ndatasets, datafields)

    return smld
end

"""
    SMLD2D(data::DataFrames.DataFrame)

Constructor to generate an `smld` from a data frame.

# Description
This is a constructor for the SMLD2D struct which allows you to populate the
structure with data defined in the dataframe `data`. The intention is that a
.csv table can be organized with localizations on each row as
`[datasetnum, framenum, x, y, σ_x, σ_y]`, loaded using the CSV package, and 
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
    smld.photons = Float64.(data[:, 7])
    smld.σ_photons = Float64.(data[:, 8])
    smld.bg = Float64.(data[:, 9])
    smld.σ_bg = Float64.(data[:, 10])
    smld.nframes = Int(maximum(smld.framenum))
    smld.ndatasets = Int(Base.length(unique(smld.datasetnum)))
    smld.datasize = [ceil(maximum(data[:, 3]) - 0.5);
                     ceil(maximum(data[:, 4]) - 0.5)]
    smld.datafields = (:connectID, :x, :y, :σ_x, :σ_y, 
        :photons, :σ_photons, :bg, :σ_bg, :framenum, :datasetnum)

    return smld
end


## SMLD3D specific structures and functions.

"""
    SMLD3D 

Structure containing 3D localization data

    # Fields
    - connectID: integer ID associating localizations
    - x: x position 
    - y: y position
    - z: z position
    - σ_x: standard error in x position
    - σ_y: standard error in y position
    - σ_z: standard error in z position
    - photons: total photons 
    - σ_photons: standard error uncertainty in σ_photons
    - bg: fit fluorescence background (photons/pixel)
    - σ_bg: standard error uncertainty in bg
    - framenum: integer framenumber within a dataset
    - datasetnum: integer dataset number
    - datasize::Vector{Int}: size of image area
    - nframes: integer frames per dataset
    - ndatasets: number of dataasets
    - datafields: bookeeping - do not modify
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
    datafields::NTuple{13, Symbol}
end

"""
    SMLD3D(nlocalizations::Int)

Constructor to generate an empty `smld` with a specific size.

# Description
This is a constructor for the SMLD3D struct which allows you to populate the
structure with undefined values for a predefined number of localizations.
"""
function SMLD3D(nlocalizations::Int)
    smld = SMLD3D()
    smld.x = zeros(Float64, nlocalizations)
    smld.y = zeros(Float64, nlocalizations)
    smld.z = zeros(Float64, nlocalizations)
    smld.σ_x = zeros(Float64, nlocalizations)
    smld.σ_y = zeros(Float64, nlocalizations)
    smld.σ_z = zeros(Float64, nlocalizations)
    smld.bg = zeros(Float64, nlocalizations)
    smld.σ_bg = zeros(Float64, nlocalizations)
    smld.photons = zeros(Float64, nlocalizations)
    smld.σ_photons = zeros(Float64, nlocalizations)
    smld.connectID = collect(1:nlocalizations)
    smld.framenum = zeros(Int, nlocalizations)
    smld.datasetnum = zeros(Int, nlocalizations)
    smld.nframes = 0
    smld.ndatasets = 0
    smld.datasize = [0; 0; 0]
    smld.datafields = (:connectID, :x, :y, :z, :σ_x, :σ_y, :σ_z,
        :photons, :σ_photons, :bg, :σ_bg, :framenum, :datasetnum)

    return smld
end

"""
    SMLD3D(; 
        x=zeros(Float64, 0), 
        y=zeros(Float64, 0), 
        z=zeros(Float64, 0),
        σ_x=zeros(Float64, 0), 
        σ_y=zeros(Float64, 0), 
        σ_z=zeros(Float64, 0),
        bg=zeros(Float64, 0), 
        σ_bg=zeros(Float64, 0),
        photons=ones(Float64, 0),
        σ_photons=zeros(Float64, 0),
        framenum=ones(Int, 0),
        datasetnum=ones(Int, 0),
        nframes = 1,
        ndatasets = 1)

Constructor to generate an `smld` with vectors of data.

# Description
This is a constructor for the SMLD3D struct which allows you to populate the
structure with a vector or vectors of data: x ,y ,z ,σ_x ,σ_y ,σ_z,bg , σ_bg, photons, or σ_photons.
"""
function SMLD3D(;
    x=zeros(Float64, 0), 
    y=zeros(Float64, 0), 
    z=zeros(Float64, 0),
    σ_x=zeros(Float64, 0), 
    σ_y=zeros(Float64, 0), 
    σ_z=zeros(Float64, 0),
    photons=ones(Float64, 0),
    σ_photons=zeros(Float64, 0),
    bg=zeros(Float64, 0), 
    σ_bg=zeros(Float64, 0),
    framenum=ones(Int, 0),
    datasetnum=ones(Int, 0),
    datasize = [0; 0; 0],
    nframes = 1,
    ndatasets = 1)


    #make sure all inputs are in the correct format
    x=float(x)
    y=float(y)
    z=float(z)
    σ_x=float(σ_x)
    σ_y=float(σ_y)
    σ_z=float(σ_z)
    photons=float(photons)
    σ_photons=float(σ_photons)
    bg=float(bg)
    σ_bg=float(σ_bg)
    datasize=round.(float(datasize))

    #put the data vectors into a single vector
    data = [x, y, z, σ_x, σ_y, σ_z, bg, σ_bg, photons, σ_photons, framenum]

    #set nloc equal to the length of the first nonzero vector
    nloc = 0
    for value in data
        if length(value) != 0
            nloc = length(value)
            break
        end
    end

    #check that nloc matches the length of all the vectors inputted
    for value in data
        if nloc != length(value) && nloc != 0 && length(value) != 0
            println("Error: Your data input vectors are not all the same length.")
            return
        end
    end

    #fill each remaining empty keyword argument with the desired vector the length of nloc
    x = isempty(x) ? zeros(Float64, nloc) : x
    y = isempty(y) ? zeros(Float64, nloc) : y
    z = isempty(z) ? zeros(Float64, nloc) : z
    σ_x = isempty(σ_x) ? zeros(Float64, nloc) : σ_x
    σ_y = isempty(σ_y) ? zeros(Float64, nloc) : σ_y
    σ_z = isempty(σ_z) ? zeros(Float64, nloc) : σ_z
    photons = isempty(photons) ? ones(Float64, nloc) : photons
    σ_photons = isempty(σ_photons) ? zeros(Float64, nloc) : σ_photons
    bg = isempty(bg) ? zeros(Float64, nloc) : bg
    σ_bg = isempty(σ_bg) ? zeros(Float64, nloc) : σ_bg
    framenum = isempty(framenum) ? ones(Int, nloc) : framenum
    datasetnum = isempty(datasetnum) ? ones(Int, nloc) : datasetnum
    datasize = all(datasize .== 0) ? [round(maximum(y)); round(maximum(x)); round(maximum(z))] : datasize

    #set the values that the user was not allowed to change
    connectID = collect(1:nloc)
    datafields = (:connectID, :x, :y, :z, :σ_x, :σ_y, :σ_z,  
         :photons, :σ_photons, :bg, :σ_bg, :framenum, :datasetnum)


    #fill the smld structure
    smld = SMLD3D(connectID, x, y, z, σ_x, σ_y, σ_z, photons, σ_photons, bg, σ_bg,
         framenum, datasetnum, datasize, nframes, ndatasets, datafields)

    return smld
end

"""
    SMLD3D(data::DataFrames.DataFrame)

Constructor to generate an `smld` from a data frame.

# Description
This is a constructor for the SMLD3D struct which allows you to populate the
structure with data defined in the dataframe `data`. The intention is that a
.csv table can be organized with localizations on each row as
`[datasetnum, framenum, x, y, z, σ_x, σ_y, σ_z]`, loaded using the CSV package, and 
placed into a dataframe with the DataFrames package.
"""
function SMLD3D(data::DataFrames.DataFrame)
    smld = SMLD3D()
    smld.connectID = collect(1:size(data)[1])
    smld.datasetnum = Int.(data[:, 1])
    smld.framenum = Int.(data[:, 2])
    smld.x = Float64.(data[:, 3])
    smld.y = Float64.(data[:, 4])
    smld.z = Float64.(data[:, 5])
    smld.σ_x = Float64.(data[:, 6])
    smld.σ_y = Float64.(data[:, 7])
    smld.σ_z = Float64.(data[:, 8])
    smld.photons = Float64.(data[:, 9])
    smld.σ_photons = Float64.(data[:, 10])
    smld.bg = Float64.(data[:, 11])
    smld.σ_bg = Float64.(data[:, 12])
    smld.nframes = Int(maximum(smld.framenum))
    smld.ndatasets = Int(Base.length(unique(smld.datasetnum)))
    smld.datasize = [ceil(maximum(data[:, 3]) - 0.5)
        ceil(maximum(data[:, 4]) - 0.5)
        ceil(maximum(data[:, 5]) - 0.5)]
    smld.datafields = (:connectID, :x, :y, :z, :σ_x, :σ_y, :σ_z,
        :photons, :σ_photons, :bg, :σ_bg, :framenum, :datasetnum)

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