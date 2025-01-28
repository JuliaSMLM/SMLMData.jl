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
