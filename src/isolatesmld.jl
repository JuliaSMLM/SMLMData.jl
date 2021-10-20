"""
    smld_sub = isolatesmld(smld::SMLD2D, subind::Vector{Int})

Isolate the `smld` localizations specified by `subind` indices.

# Description
This method grabs the localizations indexed by `subind` from `smld` and outputs
a new SMLD2D structure containing only those localization.
"""
function isolatesmld(smld::SMLD2D, subind::Vector{Int})
    # Loop through each field and add it to the output SMLD.  For scalar
    # fields, we don't have to apply the indexing of `subind`.
    fields = fieldnames(SMLMData.SMLD2D)
    nfields = length(fields)
    smld_sub = deepcopy(smld)
    for ii = 1:nfields
        currentfield = getfield(smld, fields[ii])
        if isa(currentfield, Vector) && any(fields[ii] .== smld.datafields)
            # If this field is a vector, we'll keep only the `subind` elements.
            setfield!(smld_sub, fields[ii], currentfield[subind])
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
    nfields = length(fields)
    smld_sub = deepcopy(smld)
    for ii = 1:nfields
        currentfield = getfield(smld, fields[ii])
        if isa(currentfield, Vector) && any(fields[ii] .== smld.datafields)
            # If this field is a vector, we'll keep only the `keepbit` elements.
            setfield!(smld_sub, fields[ii], currentfield[keepbit])
        end
    end

    return smld_sub
end