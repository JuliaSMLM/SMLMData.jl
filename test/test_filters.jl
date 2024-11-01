@testset "Filtering" begin
    # Setup common test data
    function create_test_data()
        cam = IdealCamera(1:512, 1:512, 0.1)
        emitters = [
            Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0, 
                                frame=1, dataset=1, track_id=1, id=1),
            Emitter2DFit{Float64}(1.5, 2.5, 500.0, 12.0, 0.02, 0.02, 60.0, 2.0,
                                frame=2, dataset=1, track_id=1, id=2),
            Emitter2DFit{Float64}(3.0, 4.0, 1500.0, 15.0, 0.01, 0.01, 55.0, 2.0,
                                frame=2, dataset=1, track_id=2, id=3)
        ]
        return BasicSMLD(emitters, cam, 2, 1, Dict{String,Any}())
    end

    @testset "@filter Macro" begin
        smld = create_test_data()

        @testset "Simple Conditions" begin
            # Test single condition
            bright = @filter(smld, photons > 1000)
            @test length(bright.emitters) == 2
            @test all(e -> e.photons > 1000, bright.emitters)

            # Test field comparison
            precise = @filter(smld, σ_x < 0.015)
            @test length(precise.emitters) == 2
            @test all(e -> e.σ_x < 0.015, precise.emitters)
        end

        @testset "Compound Conditions" begin
            # Test AND condition
            result = @filter(smld, photons > 1000 && σ_x < 0.015)
            @test length(result.emitters) == 2
            @test all(e -> e.photons > 1000 && e.σ_x < 0.015, result.emitters)

            # Test OR condition
            result = @filter(smld, photons > 1200 || frame == 1)
            @test length(result.emitters) == 2
        end

        @testset "Range Conditions" begin
            # Test inclusive range
            result = @filter(smld, 1.0 <= x <= 2.0)
            @test length(result.emitters) == 2
            @test all(e -> 1.0 <= e.x <= 2.0, result.emitters)

            # Test compound range
            result = @filter(smld, 1.0 <= x <= 2.0 && 2.0 <= y <= 3.0)
            @test length(result.emitters) == 2
        end

        @testset "Frame and Dataset Conditions" begin
            # Test frame selection
            frame2 = @filter(smld, frame == 2)
            @test length(frame2.emitters) == 2
            @test all(e -> e.frame == 2, frame2.emitters)

            # Test track selection
            track1 = @filter(smld, track_id == 1)
            @test length(track1.emitters) == 2
            @test all(e -> e.track_id == 1, track1.emitters)
        end
    end

    @testset "filter_frames" begin
        smld = create_test_data()

        @testset "Single Frame" begin
            # Test single frame selection
            result = filter_frames(smld, 1)
            @test length(result.emitters) == 1
            @test result.emitters[1].frame == 1
        end

        @testset "Frame Range" begin
            # Test frame range
            result = filter_frames(smld, 1:2)
            @test length(result.emitters) == 3
            @test all(e -> e.frame in 1:2, result.emitters)
        end

        @testset "Frame Vector" begin
            # Test specific frames
            result = filter_frames(smld, [1, 2])
            @test length(result.emitters) == 3
            
            # Test non-existent frame
            result = filter_frames(smld, [3])
            @test isempty(result.emitters)
        end
    end

    @testset "filter_roi" begin
        smld = create_test_data()

        @testset "2D ROI" begin
            # Test full containment
            result = filter_roi(smld, 0.0:2.0, 1.0:3.0)
            @test length(result.emitters) == 2

            # Test partial containment
            result = filter_roi(smld, 1.4:1.6, 2.4:2.6)
            @test length(result.emitters) == 1
            @test result.emitters[1].x ≈ 1.5

            # Test no containment
            result = filter_roi(smld, 10.0:11.0, 10.0:11.0)
            @test isempty(result.emitters)
        end

        @testset "3D ROI" begin
            # Create 3D test data
            cam = IdealCamera(1:512, 1:512, 0.1)
            emitters3d = [
                Emitter3DFit{Float64}(1.0, 2.0, -0.5, 1000.0, 10.0, 
                                   0.01, 0.01, 0.02, 50.0, 2.0),
                Emitter3DFit{Float64}(1.5, 2.5, 0.5, 1200.0, 12.0,
                                   0.01, 0.01, 0.02, 60.0, 2.0)
            ]
            smld3d = BasicSMLD(emitters3d, cam, 1, 1)

            # Test 3D ROI
            result = filter_roi(smld3d, 0.0:2.0, 1.0:3.0, -1.0:1.0)
            @test length(result.emitters) == 2

            # Test Z-selective ROI
            result = filter_roi(smld3d, 0.0:2.0, 1.0:3.0, 0.0:1.0)
            @test length(result.emitters) == 1
            @test result.emitters[1].z > 0.0
        end
    end

    @testset "Filter Chaining" begin
        smld = create_test_data()

        # Test multiple filters
        result = filter_frames(smld, 2) |> 
                smld -> @filter(smld, photons < 1000)
        @test length(result.emitters) == 1
        @test result.emitters[1].frame == 2
        @test result.emitters[1].photons < 1000

        # Test ROI and frame filter
        result = filter_roi(smld, 0.0:2.0, 1.0:3.0) |>
                smld -> filter_frames(smld, 1)
        @test length(result.emitters) == 1
        @test result.emitters[1].frame == 1
    end

    @testset "Metadata Preservation" begin
        smld = create_test_data()
        smld.metadata["test"] = "value"

        # Check metadata preservation in all filter types
        filtered1 = @filter(smld, photons > 500)
        @test filtered1.metadata["test"] == "value"

        filtered2 = filter_frames(smld, 1)
        @test filtered2.metadata["test"] == "value"

        filtered3 = filter_roi(smld, 0.0:2.0, 1.0:3.0)
        @test filtered3.metadata["test"] == "value"
    end
end
