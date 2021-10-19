"""
    smld_subregion = isolatesubregion(smld::SMLD, subind::Vector{Int})

Isolate the `smld` localizations specified by `subind` indices.

# Description
This method grabs the localizations indexed by `subind` from `smld` and outputs
a new SMLD structure containing only those localization.
"""
function isolatesubregion(smld::SMLD, subind::Vector{Int})
    # Loop through each field and add it to the output SMLD.  For scalar
    # fields, we don't have to apply the indexing of `subind`.
    fields = fieldnames(SMLMData.SMLD)
    nfields = length(fields)
    smld_subregion = deepcopy(smld)
    for ii = 1:nfields
        currentfield = getfield(smld, fields[ii])
        if isa(currentfield, Vector)
            # If this field is a vector, we'll keep only the `subind` elements.
            setfield!(smld_subregion, fields[ii], currentfield[subind])
        end
    end

    return smld_subregion
end

"""
    smld_subregion = isolatesubregion(smld::SMLD, keepbit::BitVector)

Isolate the `smld` localizations specified by `keepbit` BitVector.

# Description
This method grabs the localizations requested by the BitVector `keepbit`,
which should have the same length as the number of localizations in `smld`.
"""
function isolatesubregion(smld::SMLD, keepbit::BitVector)
    # Loop through each field and add it to the output SMLD.  For scalar
    # fields, we don't have to apply the indexing of `keepbit`.
    fields = fieldnames(SMLMData.SMLD)
    nfields = length(fields)
    smld_subregion = deepcopy(smld)
    for ii = 1:nfields
        currentfield = getfield(smld, fields[ii])
        if isa(currentfield, Vector)
            # If this field is a vector, we'll keep only the `keepbit` elements.
            setfield!(smld_subregion, fields[ii], currentfield[keepbit])
        end
    end

    return smld_subregion
end