using SMLMData
using Test

@testset "SMLMData.jl" begin
    # Write your tests here.
    
    ## Create an empty SMLD2D structure.
    smld_empty = SMLMData.SMLD2D()
    ## Create an empty SMLD2D structure with a specified numberr of localizations.
    nlocalizations = 10
    smld_init = SMLMData.SMLD2D(nlocalizations)
    smld_init.bg[1] = 10
    @test isapprox(sum(smld_init.bg),10.0; atol=1e-6)
end
