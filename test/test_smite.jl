@testset "SMLD Operations" begin
    # Setup helper function to create test data
    function create_test_smld(frame_range, dataset_num=1)
        cam = IdealCamera(1:512, 1:512, 0.1)
        emitters = [
            Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0,
                                  frame=f, dataset=dataset_num, track_id=1, id=i)
            for (i, f) in enumerate(frame_range)
        ]
    
        # Set n_frames to 0 if frame_range is empty
        n_frames = isempty(frame_range) ? 0 : maximum(frame_range)
    
        return BasicSMLD(emitters, cam, n_frames, dataset_num, 
                         Dict{String, Any}("original_frames" => frame_range))
    end
    

    @testset "cat_smld" begin
        @testset "Basic Concatenation" begin
            smld1 = create_test_smld(1:2)
            smld2 = create_test_smld(3:4)
            
            # Test varargs version
            result = cat_smld(smld1, smld2)
            @test length(result.emitters) == 4
            @test result.n_frames == 4
            @test result.n_datasets == 1
            
            # Test vector version
            result_vec = cat_smld([smld1, smld2])
            @test length(result_vec.emitters) == 4
            @test result_vec.n_frames == 4
        end

        @testset "Camera Compatibility" begin
            smld1 = create_test_smld(1:2)
            # Create SMLD with different camera
            cam2 = IdealCamera(1:256, 1:256, 0.1)
            emitters2 = [
                Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0)
            ]
            smld2 = BasicSMLD(emitters2, cam2, 1, 1, Dict{String,Any}())
            
            # Should error on different cameras
            @test_throws ErrorException cat_smld(smld1, smld2)
        end

        @testset "Metadata Handling" begin
            metadata1 = Dict{String,Any}("key1" => "value1")
            metadata2 = Dict{String,Any}("key2" => "value2")
            
            smld1 = create_test_smld(1:2)
            smld1.metadata["key1"] = "value1"
            
            smld2 = create_test_smld(3:4)
            smld2.metadata["key2"] = "value2"
            
            result = cat_smld(smld1, smld2)
            @test haskey(result.metadata, "key1")
            @test haskey(result.metadata, "concatenated_from")
            @test result.metadata["concatenated_from"] == 2
        end

        @testset "Empty and Single SMLD" begin
            smld = create_test_smld(1:2)
            empty_smld = create_test_smld(Int[])
            
            # Test concatenation with empty SMLD
            result = cat_smld(smld, empty_smld)
            @test length(result.emitters) == 2
            
            # Test single SMLD
            result = cat_smld([smld])
            @test length(result.emitters) == 2
            @test result.n_frames == 2
        end
    end

    @testset "merge_smld" begin
        @testset "Basic Merging" begin
            smld1 = create_test_smld(1:2, 1)
            smld2 = create_test_smld(1:2, 2)
            
            # Test without adjustments
            result = merge_smld(smld1, smld2)
            @test length(result.emitters) == 4
            @test result.n_frames == 2
            @test result.n_datasets == 2
            
            # Test with frame adjustment
            result = merge_smld(smld1, smld2, adjust_frames=true)
            @test result.n_frames == 4
            @test result.emitters[3].frame == 3  # Should be adjusted
            
            # Test with dataset adjustment
            result = merge_smld(smld1, smld2, adjust_datasets=true)
            @test result.n_datasets == 2
            unique_datasets = unique(e.dataset for e in result.emitters)
            @test length(unique_datasets) == 2
        end

        @testset "Frame Number Adjustment" begin
            smld1 = create_test_smld(1:2)
            smld2 = create_test_smld(1:2)
            
            result = merge_smld([smld1, smld2], adjust_frames=true)
            frames = [e.frame for e in result.emitters]
            @test sort(unique(frames)) == [1, 2, 3, 4]
            @test result.n_frames == 4
        end

        @testset "Dataset Number Adjustment" begin
            smld1 = create_test_smld(1:2, 1)
            smld2 = create_test_smld(1:2, 1)
            
            result = merge_smld([smld1, smld2], adjust_datasets=true)
            datasets = [e.dataset for e in result.emitters]
            @test sort(unique(datasets)) == [1, 2]
            @test result.n_datasets == 2
        end

        @testset "Both Adjustments" begin
            smld1 = create_test_smld(1:2, 1)
            smld2 = create_test_smld(1:2, 1)
            
            result = merge_smld([smld1, smld2], 
                              adjust_frames=true, 
                              adjust_datasets=true)
            
            @test result.n_frames == 4
            @test result.n_datasets == 2
            
            # Check that frames and datasets were properly adjusted
            frames = sort(unique([e.frame for e in result.emitters]))
            datasets = sort(unique([e.dataset for e in result.emitters]))
            @test frames == [1, 2, 3, 4]
            @test datasets == [1, 2]
        end

        @testset "Metadata Handling" begin
            smld1 = create_test_smld(1:2)
            smld2 = create_test_smld(3:4)
            
            smld1.metadata["unique1"] = "value1"
            smld2.metadata["unique2"] = "value2"
            
            result = merge_smld(smld1, smld2)
            @test haskey(result.metadata, "unique1")
            @test haskey(result.metadata, "merged_from")
            @test haskey(result.metadata, "frame_adjustment")
            @test result.metadata["merged_from"] == 2
        end

        @testset "Error Cases" begin
            smld1 = create_test_smld(1:2)
            # Create SMLD with different camera
            cam2 = IdealCamera(1:256, 1:256, 0.1)
            emitters2 = [
                Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0)
            ]
            smld2 = BasicSMLD(emitters2, cam2, 1, 1, Dict{String,Any}())
            
            # Should error on different cameras
            @test_throws ErrorException merge_smld(smld1, smld2)
            
            # Test empty input
            @test_throws ErrorException merge_smld(SMLD[])
        end
    end
end
