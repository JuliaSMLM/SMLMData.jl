@testset "Basic Emitters" begin
    @testset "2D Emitter" begin
        # Test construction
        e2d = Emitter2D{Float64}(1.0, 2.0, 1000.0)
        @test e2d.x == 1.0
        @test e2d.y == 2.0
        @test e2d.photons == 1000.0
        
        # Test different numeric types
        e2d_32 = Emitter2D{Float32}(1.0f0, 2.0f0, 1000.0f0)
        @test typeof(e2d_32.x) === Float32
    end

    @testset "3D Emitter" begin
        e3d = Emitter3D{Float64}(1.0, 2.0, 3.0, 1000.0)
        @test e3d.x == 1.0
        @test e3d.y == 2.0
        @test e3d.z == 3.0
        @test e3d.photons == 1000.0
    end
end

@testset "Fit Results" begin
    @testset "2D Fit" begin
        # Test full constructor
        e2df = Emitter2DFit{Float64}(
            1.0, 2.0,        # x, y
            1000.0, 10.0,    # photons, bg
            0.01, 0.01,      # σ_x, σ_y
            50.0, 2.0,       # σ_photons, σ_bg
            1, 1, 0, 1       # frame, dataset, track_id, id
        )
        @test e2df.x == 1.0
        @test e2df.σ_x == 0.01
        @test e2df.frame == 1
        @test e2df.track_id == 0
        
        # Test convenience constructor
        e2df_simple = Emitter2DFit{Float64}(
            1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0
        )
        @test e2df_simple.frame == 0  # default value
        @test e2df_simple.dataset == 1  # default value
        @test e2df_simple.track_id == 0  # default value
        @test e2df_simple.id == 0  # default value
    end

    @testset "3D Fit" begin
        # Test full constructor
        e3df = Emitter3DFit{Float64}(
            1.0, 2.0, 3.0,    # x, y, z
            1000.0, 10.0,     # photons, bg
            0.01, 0.01, 0.02, # σ_x, σ_y, σ_z
            50.0, 2.0,        # σ_photons, σ_bg
            1, 1, 0, 1        # frame, dataset, track_id, id
        )
        @test e3df.z == 3.0
        @test e3df.σ_z == 0.02
        
        # Test convenience constructor
        e3df_simple = Emitter3DFit{Float64}(
            1.0, 2.0, 3.0, 1000.0, 10.0, 
            0.01, 0.01, 0.02, 50.0, 2.0
        )
        @test e3df_simple.frame == 0
        @test e3df_simple.dataset == 1
    end
end

@testset "Type Stability" begin
    # Test that operations maintain type stability
    e2d = Emitter2D{Float64}(1.0, 2.0, 1000.0)
    @test typeof(e2d.x) === Float64
    
    e2df = Emitter2DFit{Float32}(
        1.0f0, 2.0f0, 1000.0f0, 10.0f0,
        0.01f0, 0.01f0, 50.0f0, 2.0f0
    )
    @test typeof(e2df.x) === Float32
    @test typeof(e2df.σ_x) === Float32
end
