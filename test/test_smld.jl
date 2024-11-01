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
    @testset "Subsetting" begin
        cam = IdealCamera(1:512, 1:512, 0.1)
        emitters = [
            Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0, frame=1),
            Emitter2DFit{Float64}(1.5, 2.5, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0, frame=2),
            Emitter2DFit{Float64}(2.0, 3.0, 1100.0, 11.0, 0.01, 0.01, 55.0, 2.0, frame=3)
        ]
        smld = BasicSMLD(emitters, cam, 3, 1)
        
        # Test subset_smld helper
        keep = [true, false, true]
        subset = subset_smld(smld, keep)
        @test length(subset.emitters) == 2
        @test subset.emitters[1].frame == 1
        @test subset.emitters[2].frame == 3
    end
    
    @testset "Metadata Handling" begin
        cam = IdealCamera(1:512, 1:512, 0.1)
        emitters = [Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0)]
        metadata = Dict{String,Any}(
            "exposure_time" => 0.1,
            "pixel_size" => 0.1,
            "timestamp" => "2024-01-01"
        )
        
        smld = BasicSMLD(emitters, cam, 1, 1, metadata)
        
        # Test metadata copying during operations
        keep = [true]
        subset = subset_smld(smld, keep)
        @test subset.metadata["exposure_time"] == 0.1
        @test subset.metadata !== smld.metadata  # Should be a copy, not same reference
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
