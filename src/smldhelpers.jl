using Base

"""
    length(smld::SMLMData.SMLD2D)

Returns the number of localizations in `smld`.
"""
function length(smld::SMLMData.SMLD2D)
    # Determine the length of `smld` by counting the number of frames.
    return Base.length(smld.framenum)
end