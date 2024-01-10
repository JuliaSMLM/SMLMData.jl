using SMLMData
SD = SMLMData
using Test

@testset "SMLMData.jl" begin

    @testset "Create Structure" begin

        #test all SMLD2D functions
        s = SD.SMLD2D()
        @test s.x == Float64[]
        s = SD.SMLD2D(3)
        @test s.x == [0,0,0]
        s = SD.SMLD2D(bg=[1,2,3])
        @test s.bg == [1,2,3]

        #test all SMLD3D functions
        s = SD.SMLD3D()
        @test s.x == Float64[]
        s = SD.SMLD3D(3)
        @test s.x == [0,0,0]
        s = SD.SMLD3D(y=[1,2,3])
        @test s.y == [1,2,3]


    end
end
