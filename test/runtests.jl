using SMLMData
using Test

@testset "SMLMData.jl" begin
    @testset "SMLD2D" begin
        @testset "constructor" begin
            smld = SMLMData.SMLD2D(x=[1.0, 2.0, 3.0])
            @test length(smld.x) == 3
            @test all(smld.x .== [1.0, 2.0, 3.0])
            @test all(smld.y .== zeros(3))
            @test smld.nframes == 0
        end

        @testset "data normalization" begin
            smld = SMLMData.SMLD2D(x=[1.0, 2.0, 3.0], y=[1.0, 2.0])
            @test length(smld.y) == 3
            @test smld.y[3] == 0.0
        end
    end

    @testset "SMLD3D" begin
        @testset "constructor" begin
            smld = SMLMData.SMLD3D(x=[1.0, 2.0, 3.0], z=[1.0, 2.0, 3.0])
            @test length(smld.x) == 3
            @test all(smld.x .== [1.0, 2.0, 3.0])
            @test all(smld.y .== zeros(3))
            @test all(smld.z .== [1.0, 2.0, 3.0])
            @test smld.ndatasets == 0
        end

        @testset "data normalization" begin
            smld = SMLMData.SMLD3D(x=[1.0, 2.0, 3.0], y=[1.0, 2.0], z=[1.0, 2.0])
            @test length(smld.y) == 3
            @test smld.y[3] == 0.0
            @test length(smld.z) == 3
            @test smld.z[3] == 0.0
        end
    end
end
