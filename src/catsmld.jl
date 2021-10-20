"""
    smld = catsmld(smld1::SMLD2D, smld2::SMLD2D)

Concatenate `smld1` and `smld2`.

# Description
This method concatenates the datafields of `smld1` and `smld2` (as defined by
smld1.datafields) into an output `smld`.  The non-data fields are taken from
`smld1` and copied into `smld`.
"""
function catsmld(smld1::SMLD2D, smld2::SMLD2D)
    # Loop through each field and add it to the output SMLD.  For scalar
    # fields, we don't have to apply the indexing of `subind`.
    fields = fieldnames(SMLMData.SMLD2D)
    nfields = length(fields)
    smld = deepcopy(smld1)
    for ii = 1:nfields
        currentfield1 = getfield(smld1, fields[ii])
        if any(fields[ii] .== smld.datafields)
            # Concatenate this field from both input SMLDs.
            currentfield2 = getfield(smld2, fields[ii])
            setfield!(smld, fields[ii], [currentfield1; currentfield2])
        end
    end

    return smld
end