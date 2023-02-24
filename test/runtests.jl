using SMLMData
using Test

@testset "SMLMData.jl" begin
    # Write your tests here.
    
    ## Create an empty SMLD2D structure.
    smld_empty = SMLMData.SMLD2D()
    ## Create an empty SMLD2D structure with a specified numberr of localizations.
    nlocalizations = 100
    smld_init = SMLMData.SMLD2D(nlocalizations)
end
