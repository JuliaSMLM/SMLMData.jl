using Base


"""
    smld_sub = isolatesmld(smld::SMLD2D, subind::Int)

Isolate the `smld` localizations specified by `subind` index.

# Description
This method grabs the localization indexed by `subind` from `smld` and outputs
a new SMLD2D structure containing only those localization.
"""
function isolatesmld(smld::SMLD2D, subind::Int)
    # Loop through each field and add it to the output SMLD.  For scalar
    # fields, we don't have to apply the indexing of `subind`.
    fields = fieldnames(SMLMData.SMLD2D)
    nfields = Base.length(fields)
    indlength = Base.length(subind)
    smld_sub = deepcopy(smld)
    for ii = 1:nfields
        if isdefined(smld, fields[ii])
            currentfield = getfield(smld, fields[ii])
            if isa(currentfield, Vector) &&
               any(fields[ii] .== smld.datafields) &&
               (Base.length(currentfield) >= indlength)
                # If this field is a vector, we'll keep only the `subind` element.
                setfield!(smld_sub, fields[ii], [currentfield[subind]])
            end
        end
    end

    return smld_sub
end

"""
    smld_sub = isolatesmld(smld::SMLD2D, subind::Vector{Int})

Isolate the `smld` localizations specified by `subind` indices.

# Description
This method grabs the localization indexed by `subind` from `smld` and outputs
a new SMLD2D structure containing only those localization.
"""
function isolatesmld(smld::SMLD2D, subind::Vector{Int})
    # Loop through each field and add it to the output SMLD.  For scalar
    # fields, we don't have to apply the indexing of `subind`.
    fields = fieldnames(SMLMData.SMLD2D)
    nfields = Base.length(fields)
    indlength = Base.length(subind)
    smld_sub = deepcopy(smld)
    for ii = 1:nfields
        if isdefined(smld, fields[ii])
            currentfield = getfield(smld, fields[ii])
            if isa(currentfield, Vector) &&
               any(fields[ii] .== smld.datafields) &&
               (Base.length(currentfield) >= indlength)
                # If this field is a vector, we'll keep only the `subind` element.
                setfield!(smld_sub, fields[ii], currentfield[subind])
            end
        end
    end

    return smld_sub
end

"""
smld_sub = isolatesmld(smld::SMLD2D, keepbit::BitVector)

Isolate the `smld` localizations specified by `keepbit` BitVector.

# Description
This method grabs the localizations requested by the BitVector `keepbit`,
which should have the same length as the number of localizations in `smld`.
"""
function isolatesmld(smld::SMLD2D, keepbit::BitVector)
    # Loop through each field and add it to the output SMLD.  For scalar
    # fields, we don't have to apply the indexing of `keepbit`.
    fields = fieldnames(SMLMData.SMLD2D)
    nfields = Base.length(fields)
    bitlength = Base.length(keepbit)
    smld_sub = deepcopy(smld)
    for ii = 1:nfields
        if isdefined(smld, fields[ii])
            currentfield = getfield(smld, fields[ii])
            if isa(currentfield, Vector) &&
               any(fields[ii] .== smld.datafields) &&
               (Base.length(currentfield) >= bitlength)
                # If this field is a vector, we'll keep only the `keepbit` elements.
                setfield!(smld_sub, fields[ii], currentfield[keepbit])
            end
        end
    end

    return smld_sub
end

"""
    smld_sub = isolatesmld(smld::SMLD2D, subind::UnitRange)

Isolate the `smld` localizations specified by `subind` indices.

# Description
This method grabs the localizations indexed by `subind` from `smld` and outputs
a new SMLD2D structure containing only those localization.
"""
function isolatesmld(smld::SMLD2D, subind::UnitRange)
    return SMLMData.isolatesmld(smld, collect(subind))
end

"""
    smld_sub = isolateROI(smld::SMLD, roi::Vector{<:Real})

Isolate the `smld` localizations specified by the `roi` region of interest.

# Description
This method grabs the localizations from `smld` that fall within `roi`.

# Inputs
- `smld`: SMLMData.SMLD structure populated with localizations.
- `roi`: Region of interest containing desired localizations.  Must use the 
         same units as smld.x and smld.y, with the pixel convention that
         pixel coordinates exist in the range [-0.5, 0.5]. 
         ([YStart; XStart; YEnd; XEnd])
"""
function isolateROI(smld::SMLD2D, roi::Vector{<:Real})
    keepind = (smld.y .>= (roi[1] - 0.5)) .& (smld.x .>= (roi[2] - 0.5)) .&
              (smld.y .<= (roi[3] + 0.5)) .& (smld.x .<= (roi[4] + 0.5))
    return SMLMData.isolatesmld(smld, keepind)
end

"""
    smld_connected, keepbool = isolateconnected(smld::SMLMData.SMLD2D)

Prepare individual SMLD2D structures for each precluster in `smld`.

# Description
Connected localizations in `smld` (based on their connectID field) are 
reorganized into distinct SMLD2D structures, with each structure corresponding
to a single connectID.

# Inputs
-`smld`: SMLD2D structure containing the localization data, with the field 
         connectID populated with a meaningful set of connection indices.

# outputs
-`smld_connected`: Vector of SMLD2D structures with each structure containing
                   localizations that share the same `connectID`.
-`keepbool`: Vector of BitVector defining the `smld` indices sharing the same
             `connectID`.
"""
function isolateconnected(smld::SMLMData.SMLD2D)
    # Ensure that the provided `smld` has a meaningful connectID field, 
    # returning if not.
    nloc = Base.length(smld)
    if Base.length(smld.connectID) != nloc
        @warn "Input `smld.connectID` is not valid."
        return [smld]
    end

    # Loop through clusters in `smld` and prepare the output.
    connectIDs = unique(smld.connectID)
    smld_connected = Vector{SMLMData.SMLD2D}(undef, Base.length(connectIDs))
    keepbool = Vector{BitVector}(undef, Base.length(connectIDs))
    for cc in connectIDs
        keepbool[cc] = smld.connectID .== cc
        smld_connected[cc] = SMLMData.isolatesmld(smld, keepbool[cc])
    end

    return smld_connected, keepbool
end