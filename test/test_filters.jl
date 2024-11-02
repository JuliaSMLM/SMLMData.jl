@testset "Filtering" begin
    # Create test data with known values
    cam = IdealCamera(1:512, 1:512, 0.1)
    emitters = [
        Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0, frame=1),
        Emitter2DFit{Float64}(1.5, 2.5, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0, frame=2),
        Emitter2DFit{Float64}(2.0, 3.0, 1100.0, 11.0, 0.01, 0.01, 55.0, 2.0, frame=3)
    ]
    smld = BasicSMLD(emitters, cam, 3, 1)

    @testset "Simple Conditions" begin
        # Test greater than
        bright = @filter(smld, photons > 1150)
        @test length(bright.emitters) == 1  # Only emitter[2] has photons > 1150 (1200.0)
        @test bright.emitters[1].photons > 1150
        
        # Test less than
        dim = @filter(smld, photons < 1050)
        @test length(dim.emitters) == 1  # Only emitter[1] has photons < 1050 (1000.0)
        @test dim.emitters[1].photons < 1050
        
        # Test equality
        frame2 = @filter(smld, frame == 2)
        @test length(frame2.emitters) == 1
        @test frame2.emitters[1].frame == 2
    end
    
    @testset "Compound Conditions" begin
        # Test AND
        result = @filter(smld, photons > 1000 && σ_x < 0.02)
        # All emitters have photons > 1000 (1000.0, 1200.0, 1100.0) and σ_x < 0.02 (all 0.01)
        @test length(result.emitters) == 2
        @test all(e -> e.photons > 1000 && e.σ_x < 0.02, result.emitters)
        
        # Test OR
        result = @filter(smld, photons > 1150 || frame == 1)
        # emitter[1] has frame == 1 and emitter[2] has photons > 1150
        @test length(result.emitters) == 2
        @test all(e -> e.photons > 1150 || e.frame == 1, result.emitters)
    end
    
    @testset "Range Comparisons" begin
        # Test inclusive range
        result = @filter(smld, 1.0 <= x <= 1.5)
        # Only emitters[1] and [2] have 1.0 <= x <= 1.5 (x values: 1.0, 1.5, 2.0)
        @test length(result.emitters) == 2
        @test all(e -> 1.0 <= e.x <= 1.5, result.emitters)
        
        # Test range with compound condition
        result = @filter(smld, 1.0 <= x <= 2.0 && photons > 1100)
        # emitters[2] and [3] have photons > 1100 (1200.0, 1100.0)
        # and only emitter[2] also has 1.0 <= x <= 2.0
        @test length(result.emitters) == 1
        @test result.emitters[1].x == 1.5  # Should be the second original emitter
        @test all(e -> (1.0 <= e.x <= 2.0) && e.photons > 1100, result.emitters)
    end
end