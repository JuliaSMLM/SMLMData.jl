using SMLMData
SD = SMLMData
using Test

@testset "SMLMData.jl" begin
    # Write your tests here.

    #these test if this particular function runs without error
    @test SD.SMLD2D(3)
    @test SD.SMLD2D(3, y=[1,2,3])
    @test SD.SMLD2D(3, y=[1,2])
end
