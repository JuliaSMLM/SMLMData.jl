using Test
using SMLMData
using StaticArrays

@testset "SingleROI" begin
    @testset "Construction" begin
        # Basic construction
        data = rand(Float32, 11, 11)
        corner = SVector{2,Int32}(100, 200)
        frame_idx = Int32(5)

        roi = SingleROI(data, corner, frame_idx)

        @test roi.data === data
        @test roi.corner === corner
        @test roi.frame_idx === frame_idx
        @test eltype(roi.data) === Float32
        @test eltype(roi.corner) === Int32
    end

    @testset "Type stability" begin
        # Float32
        roi32 = SingleROI(rand(Float32, 11, 11), SVector{2,Int32}(10, 20), Int32(1))
        @test eltype(roi32) === Float32
        @test roi32 isa SingleROI{Float32}

        # Float64
        roi64 = SingleROI(rand(Float64, 11, 11), SVector{2,Int32}(10, 20), Int32(1))
        @test eltype(roi64) === Float64
        @test roi64 isa SingleROI{Float64}
    end

    @testset "Display" begin
        roi = SingleROI(rand(Float32, 11, 11), SVector{2,Int32}(100, 200), Int32(5))
        str = sprint(show, roi)
        @test contains(str, "SingleROI{Float32}")
        @test contains(str, "11×11")
        @test contains(str, "100")
        @test contains(str, "200")
        @test contains(str, "frame=5")
    end
end

@testset "ROIBatch Construction" begin
    @testset "Main constructor with IdealCamera" begin
        camera = IdealCamera(512, 512, 0.1)
        n_rois = 10
        roi_size = 11

        data = rand(Float32, roi_size, roi_size, n_rois)
        corners = rand(Int32(1):Int32(500), 2, n_rois)
        frame_indices = rand(Int32(1):Int32(100), n_rois)

        batch = ROIBatch(data, corners, frame_indices, camera)

        @test batch.data === data
        @test batch.corners === corners
        @test batch.frame_indices === frame_indices
        @test batch.camera === camera
        @test batch.roi_size === roi_size
        @test length(batch) === n_rois
    end

    @testset "Main constructor with SCMOSCamera" begin
        camera = SCMOSCamera(512, 512, 0.1f0, 1.5f0, offset=100.0f0, gain=0.5f0)
        n_rois = 5
        roi_size = 9

        data = rand(Float32, roi_size, roi_size, n_rois)
        corners = rand(Int32(1):Int32(500), 2, n_rois)
        frame_indices = rand(Int32(1):Int32(50), n_rois)

        batch = ROIBatch(data, corners, frame_indices, camera)

        @test batch.camera isa SCMOSCamera
        @test batch.roi_size === roi_size
    end

    @testset "Constructor from x/y vectors" begin
        camera = IdealCamera(512, 512, 0.1)
        n_rois = 8
        roi_size = 13

        data = rand(Float32, roi_size, roi_size, n_rois)
        x_corners = rand(Int32(1):Int32(500), n_rois)
        y_corners = rand(Int32(1):Int32(500), n_rois)
        frame_indices = rand(Int32(1):Int32(100), n_rois)

        batch = ROIBatch(data, x_corners, y_corners, frame_indices, camera)

        @test length(batch) === n_rois
        @test batch.corners[1, :] == Int32.(x_corners)
        @test batch.corners[2, :] == Int32.(y_corners)
        @test batch.frame_indices == Int32.(frame_indices)
    end

    @testset "Constructor from vector of SingleROI" begin
        camera = IdealCamera(256, 256, 0.1)
        roi_size = 11
        n_rois = 12

        # Create SingleROI vector
        rois = [SingleROI(
            rand(Float32, roi_size, roi_size),
            SVector{2,Int32}(i*10, i*20),
            Int32(i)
        ) for i in 1:n_rois]

        batch = ROIBatch(rois, camera)

        @test length(batch) === n_rois
        @test batch.roi_size === roi_size

        # Verify data integrity
        for i in 1:n_rois
            @test batch.data[:, :, i] == rois[i].data
            @test batch.corners[1, i] == rois[i].corner[1]
            @test batch.corners[2, i] == rois[i].corner[2]
            @test batch.frame_indices[i] == rois[i].frame_idx
        end
    end

    @testset "Empty batch" begin
        camera = IdealCamera(512, 512, 0.1)
        rois = SingleROI{Float32}[]

        batch = ROIBatch(rois, camera)

        @test length(batch) === 0
        @test size(batch.data) === (0, 0, 0)
        @test size(batch.corners) === (2, 0)
        @test length(batch.frame_indices) === 0
    end
end

@testset "ROIBatch Validation" begin
    @testset "Non-square ROIs error" begin
        camera = IdealCamera(512, 512, 0.1)
        data = rand(Float32, 11, 13, 5)  # Non-square
        corners = rand(Int32(1):Int32(500), 2, 5)
        frame_indices = rand(Int32(1):Int32(100), 5)

        @test_throws AssertionError ROIBatch(data, corners, frame_indices, camera)
    end

    @testset "Corner size mismatch error" begin
        camera = IdealCamera(512, 512, 0.1)
        data = rand(Float32, 11, 11, 5)
        corners = rand(Int32(1):Int32(500), 2, 7)  # Wrong n_rois
        frame_indices = rand(Int32(1):Int32(100), 5)

        @test_throws AssertionError ROIBatch(data, corners, frame_indices, camera)
    end

    @testset "Frame indices size mismatch error" begin
        camera = IdealCamera(512, 512, 0.1)
        data = rand(Float32, 11, 11, 5)
        corners = rand(Int32(1):Int32(500), 2, 5)
        frame_indices = rand(Int32(1):Int32(100), 3)  # Wrong count

        @test_throws AssertionError ROIBatch(data, corners, frame_indices, camera)
    end

    @testset "Wrong corner dimensions error" begin
        camera = IdealCamera(512, 512, 0.1)
        data = rand(Float32, 11, 11, 5)
        corners = rand(Int32(1):Int32(500), 3, 5)  # Should be 2×n_rois
        frame_indices = rand(Int32(1):Int32(100), 5)

        @test_throws AssertionError ROIBatch(data, corners, frame_indices, camera)
    end
end

@testset "ROIBatch Indexing" begin
    camera = IdealCamera(512, 512, 0.1)
    n_rois = 15
    roi_size = 11

    data = rand(Float32, roi_size, roi_size, n_rois)
    corners = rand(Int32(1):Int32(500), 2, n_rois)
    frame_indices = rand(Int32(1):Int32(100), n_rois)

    batch = ROIBatch(data, corners, frame_indices, camera)

    @testset "Single element indexing" begin
        for i in [1, 5, n_rois]
            roi = batch[i]

            @test roi isa SingleROI{Float32}
            @test roi.data == data[:, :, i]
            @test roi.corner == SVector{2,Int32}(corners[1, i], corners[2, i])
            @test roi.frame_idx == frame_indices[i]
        end
    end

    @testset "Length and size" begin
        @test length(batch) === n_rois
        @test size(batch) === (n_rois,)
    end
end

@testset "ROIBatch Iteration" begin
    camera = IdealCamera(256, 256, 0.1)
    n_rois = 7
    roi_size = 9

    data = rand(Float32, roi_size, roi_size, n_rois)
    x_corners = collect(Int32(1):Int32(n_rois))
    y_corners = collect(Int32(10):Int32(10+n_rois-1))
    frame_indices = collect(Int32(1):Int32(n_rois))

    batch = ROIBatch(data, x_corners, y_corners, frame_indices, camera)

    @testset "For loop iteration" begin
        count = 0
        for roi in batch
            count += 1
            @test roi isa SingleROI{Float32}
            @test size(roi.data) === (roi_size, roi_size)
        end
        @test count === n_rois
    end

    @testset "Collect iteration" begin
        rois = collect(batch)
        @test length(rois) === n_rois
        @test all(roi isa SingleROI{Float32} for roi in rois)

        # Verify order preserved
        for i in 1:n_rois
            @test rois[i].corner[1] === x_corners[i]
            @test rois[i].corner[2] === y_corners[i]
            @test rois[i].frame_idx === frame_indices[i]
        end
    end
end

@testset "ROIBatch Type Stability" begin
    @testset "Float32" begin
        camera = IdealCamera(512, 512, 0.1f0)
        data = rand(Float32, 11, 11, 5)
        corners = rand(Int32(1):Int32(500), 2, 5)
        frames = rand(Int32(1):Int32(100), 5)

        batch = ROIBatch(data, corners, frames, camera)

        @test batch isa ROIBatch{Float32,3,Array{Float32,3},IdealCamera{Float32}}
        @test eltype(batch.data) === Float32

        roi = batch[1]
        @test roi isa SingleROI{Float32}
    end

    @testset "Float64" begin
        camera = IdealCamera(512, 512, 0.1)
        data = rand(Float64, 11, 11, 5)
        corners = rand(Int32(1):Int32(500), 2, 5)
        frames = rand(Int32(1):Int32(100), 5)

        batch = ROIBatch(data, corners, frames, camera)

        @test batch isa ROIBatch{Float64,3,Array{Float64,3},IdealCamera{Float64}}
        @test eltype(batch.data) === Float64

        roi = batch[1]
        @test roi isa SingleROI{Float64}
    end
end

@testset "ROIBatch Display" begin
    camera = IdealCamera(512, 512, 0.1)
    data = rand(Float32, 13, 13, 25)
    corners = rand(Int32(1):Int32(500), 2, 25)
    frames = rand(Int32(1):Int32(100), 25)

    batch = ROIBatch(data, corners, frames, camera)

    @testset "Compact display" begin
        str = sprint(show, batch)
        @test contains(str, "ROIBatch{Float32}")
        @test contains(str, "13×13")
        @test contains(str, "25 ROIs")
    end

    @testset "Detailed display" begin
        str = sprint(show, MIME("text/plain"), batch)
        @test contains(str, "ROIBatch{Float32}")
        @test contains(str, "ROI size: 13 × 13")
        @test contains(str, "Number of ROIs: 25")
        @test contains(str, "IdealCamera")
        @test contains(str, "Frame range:")
    end
end

@testset "ROIBatch with Different Cameras" begin
    @testset "IdealCamera" begin
        camera = IdealCamera(1024, 1024, 0.065)
        batch = ROIBatch(
            rand(Float32, 11, 11, 10),
            rand(Int32(1):Int32(1000), 2, 10),
            rand(Int32(1):Int32(50), 10),
            camera
        )

        @test batch.camera isa IdealCamera{Float64}
    end

    @testset "SCMOSCamera with scalar parameters" begin
        camera = SCMOSCamera(2048, 2048, 0.065, 1.6,
                            offset=100.0, gain=0.46, qe=0.72)
        batch = ROIBatch(
            rand(Float32, 9, 9, 15),
            rand(Int32(1):Int32(2000), 2, 15),
            rand(Int32(1):Int32(100), 15),
            camera
        )

        @test batch.camera isa SCMOSCamera{Float64}
        @test batch.camera.gain === 0.46
    end

    @testset "SCMOSCamera with per-pixel parameters" begin
        readnoise_map = ones(Float32, 512, 512) .* 1.5f0
        camera = SCMOSCamera(512, 512, 0.1f0, readnoise_map)

        batch = ROIBatch(
            rand(Float32, 11, 11, 8),
            rand(Int32(1):Int32(500), 2, 8),
            rand(Int32(1):Int32(20), 8),
            camera
        )

        @test batch.camera isa SCMOSCamera{Float32}
        @test batch.camera.readnoise isa Matrix{Float32}
    end
end

@testset "ROIBatch GPU Adaptation" begin
    using Adapt

    camera = IdealCamera(512, 512, 0.1)
    n_rois = 5

    data = rand(Float32, 11, 11, n_rois)
    corners = rand(Int32(1):Int32(500), 2, n_rois)
    frames = rand(Int32(1):Int32(50), n_rois)

    batch = ROIBatch(data, corners, frames, camera)

    @testset "Adapt.adapt_structure defined" begin
        # Test that adapt_structure is defined
        @test hasmethod(Adapt.adapt_structure, Tuple{Type{Array}, ROIBatch})
    end

    @testset "Mock GPU adaptation (Array -> Array)" begin
        # Adapt to Array (no-op, but tests the mechanism)
        adapted = adapt(Array, batch)

        @test adapted isa ROIBatch
        @test adapted.data isa Array
        @test adapted.corners isa Matrix{Int32}
        @test adapted.frame_indices isa Vector{Int32}
        @test adapted.camera === batch.camera  # Camera stays on host
        @test adapted.roi_size === batch.roi_size
    end
end

@testset "ROIBatch Real-world Scenarios" begin
    @testset "Typical SMLM workflow" begin
        # Simulate output from SMLMBoxer
        camera = IdealCamera(2048, 2048, 0.065)  # ORCA-Flash4.0
        n_detections = 156
        roi_size = 13

        # ROIs from 20 frames
        data = rand(Float32, roi_size, roi_size, n_detections)
        x_corners = rand(Int32(1):Int32(2040), n_detections)
        y_corners = rand(Int32(1):Int32(2040), n_detections)
        frames = rand(Int32(1):Int32(20), n_detections)

        batch = ROIBatch(data, x_corners, y_corners, frames, camera)

        @test length(batch) === n_detections
        @test batch.roi_size === roi_size

        # Verify can iterate and process
        processed_count = 0
        for roi in batch
            # Simulate processing (e.g., fitting)
            @test size(roi.data) === (roi_size, roi_size)
            @test roi.corner[1] >= 1 && roi.corner[1] <= 2040
            @test roi.corner[2] >= 1 && roi.corner[2] <= 2040
            @test roi.frame_idx >= 1 && roi.frame_idx <= 20
            processed_count += 1
        end
        @test processed_count === n_detections
    end

    @testset "High-density SMLM (many ROIs)" begin
        camera = SCMOSCamera(512, 512, 0.1, 1.5, gain=0.5)
        n_rois = 5000  # Typical for dense labeling
        roi_size = 9

        data = rand(Float32, roi_size, roi_size, n_rois)
        corners = rand(Int32(1):Int32(500), 2, n_rois)
        frames = rand(Int32(1):Int32(500), n_rois)

        batch = ROIBatch(data, corners, frames, camera)

        @test length(batch) === n_rois

        # Verify efficient indexing
        sample_indices = [1, 100, 1000, 2500, 5000]
        for i in sample_indices
            roi = batch[i]
            @test roi.data == data[:, :, i]
        end
    end

    @testset "Multi-frame time series" begin
        camera = IdealCamera(256, 256, 0.1)
        n_frames = 1000
        rois_per_frame = 3
        n_total = n_frames * rois_per_frame

        data = rand(Float32, 11, 11, n_total)
        corners = rand(Int32(1):Int32(240), 2, n_total)
        frames = repeat(Int32(1):Int32(n_frames), inner=rois_per_frame)

        batch = ROIBatch(data, corners, frames, camera)

        # Verify frame distribution
        frame_counts = Dict{Int32,Int}()
        for idx in batch.frame_indices
            frame_counts[idx] = get(frame_counts, idx, 0) + 1
        end

        @test length(frame_counts) === n_frames
        @test all(count == rois_per_frame for count in values(frame_counts))
    end
end
