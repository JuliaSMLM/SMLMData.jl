using SMLMData
using Test

@testset "SMLMData.jl" begin
    # Notify which tests are being run
    println("\nRunning SMLMData tests...\n")

    @testset "Emitter Types" begin
        include("test_emitters.jl")
    end

    @testset "Camera & Coordinates" begin
        include("test_cameras.jl")
    end

    @testset "ROI Batch Types" begin
        include("test_roi_batch.jl")
    end

    @testset "SMLD Types" begin
        include("test_smld.jl")
    end

    @testset "Filtering" begin
        include("test_filters.jl")
    end

    @testset "Operations" begin
        include("test_operations.jl")
    end

    @testset "SMITE Format" begin
        include("test_smite.jl")
    end
end
