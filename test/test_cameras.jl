@testset "Coordinate Conversion" begin
    @testset "Basic Conversions" begin
        pixel_size = 0.1  # 100nm pixels

        # Test pixel center to physical coordinates
        x, y = pixel_to_physical(1.0, 1.0, pixel_size)
        @test x ≈ 0.05
        @test y ≈ 0.05

        # Test physical back to pixel coordinates
        px, py = physical_to_pixel(0.05, 0.05, pixel_size)
        @test px ≈ 1.0
        @test py ≈ 1.0

        # Test corner cases
        x, y = pixel_to_physical(0.5, 0.5, pixel_size)
        @test x ≈ 0.0
        @test y ≈ 0.0
    end

    @testset "Round Trip Conversions" begin
        pixel_size = 0.1

        # Test pixel → physical → pixel
        original_px, original_py = 1.5, 2.5
        x, y = pixel_to_physical(original_px, original_py, pixel_size)
        px, py = physical_to_pixel(x, y, pixel_size)
        @test px ≈ original_px
        @test py ≈ original_py

        # Test physical → pixel → physical
        original_x, original_y = 0.15, 0.25
        px, py = physical_to_pixel(original_x, original_y, pixel_size)
        x, y = pixel_to_physical(px, py, pixel_size)
        @test x ≈ original_x
        @test y ≈ original_y
    end

    @testset "Pixel Indexing" begin
        pixel_size = 0.1

        # Test center of pixels
        px, py = physical_to_pixel_index(0.05, 0.05, pixel_size)
        @test px == 1
        @test py == 1

        # Test edges
        px, py = physical_to_pixel_index(0.09, 0.09, pixel_size)
        @test px == 1
        @test py == 1

        px, py = physical_to_pixel_index(0.11, 0.11, pixel_size)
        @test px == 2
        @test py == 2
    end
end

@testset "Camera" begin
    @testset "IdealCamera Construction" begin
        # Test square pixels
        cam = IdealCamera(1:512, 1:512, 0.1)
        @test length(cam.pixel_edges_x) == 513  # N+1 edges
        @test length(cam.pixel_edges_y) == 513
        
        # Test edge positions
        @test cam.pixel_edges_x[1] ≈ 0.0  # First edge at 0
        @test cam.pixel_edges_x[2] ≈ 0.1  # Second edge at pixel_size
        @test cam.pixel_edges_x[3] ≈ 0.2  # Third edge at 2*pixel_size
        
        # Verify first pixel center is at pixel_size/2
        centers_x, centers_y = get_pixel_centers(cam)
        @test centers_x[1] ≈ 0.05
        @test centers_y[1] ≈ 0.05
        
        # Test rectangular pixels
        cam_rect = IdealCamera(1:512, 1:256, (0.1, 0.2))
        @test cam_rect.pixel_edges_x[1] ≈ 0.0
        @test cam_rect.pixel_edges_y[1] ≈ 0.0
        @test cam_rect.pixel_edges_x[2] ≈ 0.1
        @test cam_rect.pixel_edges_y[2] ≈ 0.2
        
        # Test different numeric types
        cam_32 = IdealCamera(1:3, 1:3, 0.1f0)
        @test eltype(cam_32.pixel_edges_x) === Float32
        @test cam_32.pixel_edges_x[1] ≈ 0.0f0
        @test cam_32.pixel_edges_x[2] ≈ 0.1f0
    end

    @testset "Pixel Centers" begin
        cam = IdealCamera(1:3, 1:3, 0.1)
        centers_x, centers_y = get_pixel_centers(cam)

        # Test number of centers
        @test length(centers_x) == 3
        @test length(centers_y) == 3

        # Test center positions
        @test centers_x[1] ≈ 0.05
        @test centers_x[2] ≈ 0.15
        @test centers_x[3] ≈ 0.25

        # Test with rectangular pixels
        cam_rect = IdealCamera(1:3, 1:3, (0.1, 0.2))
        centers_x, centers_y = get_pixel_centers(cam_rect)
        @test centers_x[2] ≈ 0.15
        @test centers_y[2] ≈ 0.3
    end

    @testset "Type Stability" begin
        @testset "Float32" begin
            # Test camera construction with Float32
            cam_32 = IdealCamera(1:3, 1:3, 0.1f0)
            @test eltype(cam_32.pixel_edges_x) === Float32
            @test eltype(cam_32.pixel_edges_y) === Float32

            # Verify edge values
            @test cam_32.pixel_edges_x[1] ≈ 0.0f0
            @test cam_32.pixel_edges_x[2] ≈ 0.1f0
        end

        @testset "Float64" begin
            # Test default Float64 behavior
            cam_64 = IdealCamera(1:3, 1:3, 0.1)
            @test eltype(cam_64.pixel_edges_x) === Float64
            @test eltype(cam_64.pixel_edges_y) === Float64
        end

        @testset "Coordinate Conversions" begin
            # Test type stability in coordinate conversions
            x32, y32 = pixel_to_physical(1, 1, 0.1f0)
            @test typeof(x32) === Float32
            @test typeof(y32) === Float32

            x64, y64 = pixel_to_physical(1, 1, 0.1)
            @test typeof(x64) === Float64
            @test typeof(y64) === Float64
        end
    end

    @testset "Edge Cases" begin
        # Test single pixel camera
        cam_single = IdealCamera(1:1, 1:1, 0.1)
        @test length(cam_single.pixel_edges_x) == 2
        @test cam_single.pixel_edges_x[1] ≈ 0.0
        @test cam_single.pixel_edges_x[2] ≈ 0.1

        # Test different numeric types
        cam_32 = IdealCamera(1:3, 1:3, 0.1f0)
        @test eltype(cam_32.pixel_edges_x) === Float32

        # Test different x/y dimensions
        cam_rect = IdealCamera(1:10, 1:5, 0.1)
        @test length(cam_rect.pixel_edges_x) == 11
        @test length(cam_rect.pixel_edges_y) == 6
    end
end

@testset "Bin Edge Computation" begin
    @testset "Square Pixels" begin
        edges_x, edges_y = compute_bin_edges(1:3, 1:3, 0.1)

        # Test number of edges
        @test length(edges_x) == 4  # N+1 edges for N pixels
        @test length(edges_y) == 4

        # Test edge positions
        @test edges_x[1] ≈ 0.0
        @test edges_x[2] ≈ 0.1
        @test edges_x[3] ≈ 0.2
        @test edges_x[4] ≈ 0.3
    end

    @testset "Rectangular Pixels" begin
        edges_x, edges_y = compute_bin_edges(1:3, 1:3, (0.1, 0.2))

        # Test edge spacing
        @test edges_x[2] - edges_x[1] ≈ 0.1
        @test edges_y[2] - edges_y[1] ≈ 0.2

        # Test total size
        @test edges_x[end] - edges_x[1] ≈ 0.3
        @test edges_y[end] - edges_y[1] ≈ 0.6
    end
end

@testset "SCMOSCamera" begin
    @testset "Construction with scalar parameters" begin
        # Minimal constructor (readnoise only)
        cam = SCMOSCamera(512, 512, 0.1, 1.6)
        @test length(cam.pixel_edges_x) == 513
        @test length(cam.pixel_edges_y) == 513
        @test cam.offset === 0.0
        @test cam.gain === 1.0
        @test cam.readnoise === 1.6
        @test cam.qe === 1.0

        # With all parameters
        cam_full = SCMOSCamera(512, 512, 0.1, 1.6, offset=100.0, gain=0.46, qe=0.72)
        @test cam_full.offset === 100.0
        @test cam_full.gain === 0.46
        @test cam_full.readnoise === 1.6
        @test cam_full.qe === 0.72

        # Rectangular pixels
        cam_rect = SCMOSCamera(512, 256, (0.1, 0.15), 1.8)
        @test cam_rect.pixel_edges_x[2] ≈ 0.1
        @test cam_rect.pixel_edges_y[2] ≈ 0.15
        @test cam_rect.readnoise === 1.8
    end

    @testset "Construction with matrix parameters" begin
        # Create calibration maps
        readnoise_map = ones(Float64, 10, 10) .* 1.5
        readnoise_map[5, 5] = 2.0  # Hot pixel

        gain_map = ones(Float64, 10, 10) .* 0.5
        qe_map = ones(Float64, 10, 10) .* 0.85

        # With readnoise map only
        cam1 = SCMOSCamera(10, 10, 0.1, readnoise_map)
        @test cam1.readnoise isa Matrix{Float64}
        @test size(cam1.readnoise) == (10, 10)
        @test cam1.readnoise[5, 5] ≈ 2.0
        @test cam1.offset === 0.0  # Scalar default
        @test cam1.gain === 1.0

        # With all matrix parameters
        offset_map = ones(Float64, 10, 10) .* 100.0
        cam2 = SCMOSCamera(10, 10, 0.1, readnoise_map,
                          offset=offset_map, gain=gain_map, qe=qe_map)
        @test cam2.offset isa Matrix{Float64}
        @test cam2.gain isa Matrix{Float64}
        @test cam2.qe isa Matrix{Float64}
        @test size(cam2.offset) == (10, 10)

        # Mixed scalar and matrix
        cam3 = SCMOSCamera(10, 10, 0.1, readnoise_map,
                          offset=100.0, gain=gain_map, qe=0.85)
        @test cam3.offset isa Float64
        @test cam3.gain isa Matrix{Float64}
        @test cam3.qe isa Float64
    end

    @testset "Construction with custom edges" begin
        edges_x = collect(range(0.0, 1.0, length=11))
        edges_y = collect(range(0.0, 0.5, length=6))

        # Scalar parameters
        cam = SCMOSCamera(edges_x, edges_y, readnoise=1.5, gain=0.5)
        @test length(cam.pixel_edges_x) == 11
        @test length(cam.pixel_edges_y) == 6
        @test cam.readnoise === 1.5
        @test cam.gain === 0.5

        # Matrix parameters - size must be (ny, nx) = (rows, cols) following Julia convention
        # edges_x has 11 elements → nx = 10 columns
        # edges_y has 6 elements → ny = 5 rows
        noise_map = ones(Float64, 5, 10) .* 1.2  # (ny, nx) = (5, 10)
        cam2 = SCMOSCamera(edges_x, edges_y, readnoise=noise_map)
        @test size(cam2.readnoise) == (5, 10)
    end

    @testset "Type stability" begin
        # Float32
        cam32 = SCMOSCamera(10, 10, 0.1f0, 1.6f0)
        @test eltype(cam32.pixel_edges_x) === Float32
        @test eltype(cam32.pixel_edges_y) === Float32
        @test cam32.offset === 0.0f0
        @test cam32.readnoise === 1.6f0

        # Float64
        cam64 = SCMOSCamera(10, 10, 0.1, 1.6)
        @test eltype(cam64.pixel_edges_x) === Float64
        @test cam64.offset === 0.0

        # Matrix type matching
        noise_map32 = ones(Float32, 10, 10)
        cam_mat32 = SCMOSCamera(10, 10, 0.1f0, noise_map32)
        @test eltype(cam_mat32.readnoise) === Float32
    end

    @testset "Dimension validation" begin
        # Wrong matrix size should error
        wrong_size_map = ones(Float64, 5, 5)
        @test_throws DimensionMismatch SCMOSCamera(10, 10, 0.1, wrong_size_map)
        @test_throws DimensionMismatch SCMOSCamera(10, 10, 0.1, 1.5, gain=wrong_size_map)
        @test_throws DimensionMismatch SCMOSCamera(10, 10, 0.1, 1.5, offset=wrong_size_map)
        @test_throws DimensionMismatch SCMOSCamera(10, 10, 0.1, 1.5, qe=wrong_size_map)
    end

    @testset "Matrix convention (ny, nx) for rectangular cameras" begin
        # Rectangular camera: 512 columns (x), 256 rows (y)
        # Matrix must be (ny, nx) = (256, 512) following Julia [row, col] convention
        nx, ny = 512, 256

        # Create noise map with a marker at known position
        noise_map = ones(Float64, ny, nx)  # (256, 512) = (rows, cols)
        noise_map[100, 300] = 5.0  # row 100, col 300 → pixel (x=300, y=100)

        cam = SCMOSCamera(nx, ny, 0.1, noise_map)
        @test size(cam.readnoise) == (ny, nx)
        @test size(cam.readnoise) == (256, 512)

        # Verify semantic access: map[y, x] gives value for pixel at (x, y)
        @test cam.readnoise[100, 300] == 5.0

        # Transposed matrix should fail
        wrong_map = ones(Float64, nx, ny)  # (512, 256) - WRONG
        @test_throws DimensionMismatch SCMOSCamera(nx, ny, 0.1, wrong_map)
    end

    @testset "Realistic use cases" begin
        # ORCA-Flash4.0 V3
        cam_flash = SCMOSCamera(
            2048, 2048, 0.065,
            1.6,
            offset = 100.0,
            gain = 0.46,
            qe = 0.72
        )
        @test length(cam_flash.pixel_edges_x) == 2049
        @test cam_flash.readnoise === 1.6
        @test cam_flash.gain === 0.46

        # ORCA-Quest (ultra low noise)
        cam_quest = SCMOSCamera(2304, 4096, 0.0044, 0.27, gain=0.5, qe=0.85)
        @test cam_quest.readnoise === 0.27
        @test cam_quest.qe === 0.85

        # With per-pixel calibration
        nx, ny = 512, 512
        readnoise_map = randn(nx, ny) .* 0.2 .+ 1.5  # ~1.5 ± 0.2 e⁻ rms
        gain_map = randn(nx, ny) .* 0.05 .+ 0.5      # ~0.5 ± 0.05 e⁻/ADU
        qe_map = randn(nx, ny) .* 0.02 .+ 0.85       # ~0.85 ± 0.02

        cam_calibrated = SCMOSCamera(
            nx, ny, 0.1, readnoise_map,
            offset = 100.0,
            gain = gain_map,
            qe = qe_map
        )
        @test size(cam_calibrated.readnoise) == (nx, ny)
        @test size(cam_calibrated.gain) == (nx, ny)
        @test cam_calibrated.offset === 100.0  # Scalar
    end

    @testset "Display methods" begin
        # Compact display (scalar)
        cam = SCMOSCamera(512, 512, 0.1, 1.6)
        str = sprint(show, cam)
        @test contains(str, "SCMOSCamera{Float64}")
        @test contains(str, "512×512")
        @test contains(str, "0.1μm")

        # Detailed display
        io = IOBuffer()
        show(io, MIME("text/plain"), cam)
        detailed = String(take!(io))
        @test contains(detailed, "SCMOSCamera{Float64}")
        @test contains(detailed, "Dimensions: 512 × 512 pixels")
        @test contains(detailed, "Pixel size: 0.1 μm")
        @test contains(detailed, "Offset: uniform")
        @test contains(detailed, "Gain: uniform")
        @test contains(detailed, "Read noise: uniform")
        @test contains(detailed, "QE: uniform")

        # With matrix parameters
        noise_map = ones(Float64, 10, 10)
        gain_map = ones(Float64, 10, 10)
        cam_matrix = SCMOSCamera(10, 10, 0.1, noise_map,
                                 offset=100.0, gain=gain_map, qe=0.85)
        io = IOBuffer()
        show(io, MIME("text/plain"), cam_matrix)
        detailed_matrix = String(take!(io))
        @test contains(detailed_matrix, "Offset: uniform")
        @test contains(detailed_matrix, "Gain: per-pixel")
        @test contains(detailed_matrix, "Read noise: per-pixel")
        @test contains(detailed_matrix, "QE: uniform")

        # Rectangular pixels
        cam_rect = SCMOSCamera(512, 256, (0.1, 0.15), 1.8)
        str_rect = sprint(show, cam_rect)
        @test contains(str_rect, "0.1×0.15μm")
    end
end
