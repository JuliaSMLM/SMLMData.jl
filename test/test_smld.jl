@testset "Basic SMLD" begin
    @testset "Construction" begin
        # Create test data
        cam = IdealCamera(1:512, 1:512, 0.1)
        emitters = [
            Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0, 
                                frame=1, dataset=1, track_id=1, id=1),
            Emitter2DFit{Float64}(1.5, 2.5, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0,
                                frame=2, dataset=1, track_id=1, id=2)
        ]
        metadata = Dict{String,Any}("exposure_time" => 0.1)
        
        # Test basic construction
        smld = BasicSMLD{Float64,Emitter2DFit{Float64}}(
            emitters, cam, 2, 1, metadata
        )
        
        @test length(smld.emitters) == 2
        @test smld.n_frames == 2
        @test smld.n_datasets == 1
        @test haskey(smld.metadata, "exposure_time")
        
        # Test convenience constructor
        smld_simple = BasicSMLD(emitters, cam, 2, 1)
        @test length(smld_simple.emitters) == 2
        @test isempty(smld_simple.metadata)
    end
    
    @testset "Type Stability" begin
        cam = IdealCamera(1:512, 1:512, 0.1)
        emitters = [Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0)]
        
        smld = BasicSMLD(emitters, cam, 1, 1)
        @test eltype(smld.emitters) === Emitter2DFit{Float64}
    end
    
    @testset "Iteration" begin
        cam = IdealCamera(1:512, 1:512, 0.1)
        emitters = [
            Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0),
            Emitter2DFit{Float64}(1.5, 2.5, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0)
        ]
        smld = BasicSMLD(emitters, cam, 2, 1)
        
        # Test iteration
        count = 0
        for emitter in smld
            @test emitter isa Emitter2DFit
            count += 1
        end
        @test count == 2
        
        # Test length
        @test length(smld) == 2
    end
end

@testset "SMLD Operations" begin
    @testset "Filtering" begin
        # Create test data
        cam = IdealCamera(1:512, 1:512, 0.1)
        emitters = [
            Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0, frame=1),
            Emitter2DFit{Float64}(1.5, 2.5, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0, frame=2),
            Emitter2DFit{Float64}(2.0, 3.0, 1100.0, 11.0, 0.01, 0.01, 55.0, 2.0, frame=3)
        ]
        smld = BasicSMLD(emitters, cam, 3, 1)
        
        @testset "Frame Filtering" begin
            frame1 = filter_frames(smld, 1)
            @test length(frame1.emitters) == 1
            @test frame1.emitters[1].frame == 1
        end
        
        @testset "Condition Filtering" begin
            cam = IdealCamera(1:512, 1:512, 0.1)
            emitters = [
                Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0, frame=1),
                Emitter2DFit{Float64}(1.5, 2.5, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0, frame=2),
                Emitter2DFit{Float64}(2.0, 3.0, 1100.0, 11.0, 0.01, 0.01, 55.0, 2.0, frame=3)
            ]
            smld = BasicSMLD(emitters, cam, 3, 1)
            
            @testset "Simple Comparisons" begin
                # Test greater than
                bright = @filter(smld, photons > 1150)
                @test length(bright.emitters) == 1
                @test bright.emitters[1].photons > 1150
                
                # Test less than
                dim = @filter(smld, photons < 1050)
                @test length(dim.emitters) == 1
                @test dim.emitters[1].photons < 1050
                
                # Test equality
                frame2 = @filter(smld, frame == 2)
                @test length(frame2.emitters) == 1
                @test frame2.emitters[1].frame == 2
            end
            
            @testset "Compound Conditions" begin
                # Test AND
                result = @filter(smld, photons > 1000 && σ_x < 0.02)
                @test all(e -> e.photons > 1000 && e.σ_x < 0.02, result.emitters)
                
                # Test OR
                result = @filter(smld, photons > 1150 || frame == 1)
                @test all(e -> e.photons > 1150 || e.frame == 1, result.emitters)
            end
            
            @testset "Range Comparisons" begin
                # Test inclusive range
                result = @filter(smld, 1.0 <= x <= 1.5)
                @test all(e -> 1.0 <= e.x <= 1.5, result.emitters)
                
                # Test range with compound condition
                result = @filter(smld, 1.0 <= x <= 2.0 && photons > 1100)
                @test all(e -> (1.0 <= e.x <= 2.0) && e.photons > 1100, result.emitters)
            end
        end
    end
    
    @testset "Metadata Handling" begin
        cam = IdealCamera(1:512, 1:512, 0.1)
        emitters = [
            Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0, frame=1),
            Emitter2DFit{Float64}(1.5, 2.5, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0, frame=2)
        ]
        metadata = Dict{String,Any}(
            "exposure_time" => 0.1,
            "pixel_size" => 0.1,
            "timestamp" => "2024-01-01"
        )
        
        smld = BasicSMLD(emitters, cam, 2, 1, metadata)
        
        # Test metadata copying during filtering operations
        frame1 = filter_frames(smld, 1)
        @test frame1.metadata["exposure_time"] == 0.1
        @test frame1.metadata !== smld.metadata  # Should be a copy, not same reference
        
        # Test metadata preservation with @filter
        bright = @filter(smld, photons > 1100)
        @test bright.metadata["exposure_time"] == 0.1
        @test bright.metadata !== smld.metadata
        
        # Test metadata preservation with ROI filtering
        roi = filter_roi(smld, 0.0:2.0, 1.0:3.0)
        @test roi.metadata["exposure_time"] == 0.1
        @test roi.metadata !== smld.metadata
    end
    
    @testset "3D SMLD" begin
        cam = IdealCamera(1:512, 1:512, 0.1)
        emitters = [
            Emitter3DFit{Float64}(1.0, 2.0, 0.5, 1000.0, 10.0, 
                               0.01, 0.01, 0.02, 50.0, 2.0, frame=1),
            Emitter3DFit{Float64}(1.5, 2.5, -0.5, 1200.0, 12.0,
                               0.01, 0.01, 0.02, 60.0, 2.0, frame=2)
        ]
        smld = BasicSMLD(emitters, cam, 2, 1)
        
        @test eltype(smld.emitters) === Emitter3DFit{Float64}
        @test all(e -> hasfield(typeof(e), :z), smld.emitters)
    end
end

@testset "Empty SMLD" begin
    cam = IdealCamera(1:512, 1:512, 0.1)
    empty_emitters = Emitter2DFit{Float64}[]
    smld = BasicSMLD(empty_emitters, cam, 0, 0)
    
    @test length(smld) == 0
    @test isempty(smld.emitters)
    
    # Test iteration on empty SMLD
    count = 0
    for _ in smld
        count += 1
    end
    @test count == 0
end
