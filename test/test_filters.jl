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

# Reference copies of the 0.7.0 filter_roi bodies minus the type check, for allocation parity
function _roi2d_reference(smld, x_range, y_range)
    x_min, x_max = extrema(x_range)
    y_min, y_max = extrema(y_range)
    keep = [x_min ≤ e.x ≤ x_max && y_min ≤ e.y ≤ y_max for e in smld.emitters]
    return typeof(smld)(
        smld.emitters[keep],
        smld.camera,
        smld.n_frames,
        smld.n_datasets,
        copy(smld.metadata)
    )
end

function _roi3d_reference(smld, x_range, y_range, z_range)
    x_min, x_max = extrema(x_range)
    y_min, y_max = extrema(y_range)
    z_min, z_max = extrema(z_range)
    keep = [x_min ≤ e.x ≤ x_max &&
            y_min ≤ e.y ≤ y_max &&
            z_min ≤ e.z ≤ z_max for e in smld.emitters]
    return typeof(smld)(
        smld.emitters[keep],
        smld.camera,
        smld.n_frames,
        smld.n_datasets,
        copy(smld.metadata)
    )
end

# @allocated of a single call jitters by a few dozen bytes, so take the minimum of several
_alloc_roi(smld, xr, yr) = minimum((@allocated filter_roi(smld, xr, yr)) for _ in 1:10)
_alloc_roi(smld, xr, yr, zr) = minimum((@allocated filter_roi(smld, xr, yr, zr)) for _ in 1:10)
_alloc_ref(smld, xr, yr) = minimum((@allocated _roi2d_reference(smld, xr, yr)) for _ in 1:10)
_alloc_ref(smld, xr, yr, zr) = minimum((@allocated _roi3d_reference(smld, xr, yr, zr)) for _ in 1:10)

@testset "Dimension routing" begin
    cam = IdealCamera(1:512, 1:512, 0.1)
    xr, yr, zr = (0.0, 2.0), (0.0, 2.0), (-1.0, 1.0)
    msg2on3 = "2D ROI cannot be applied to 3D emitter type"
    msg3on2 = "3D ROI cannot be applied to 2D emitter type"

    # Emitters 1 and 3 are inside the box; 2 (x), 4 (y) and 5 (z) are outside
    xs = [1.0, 5.0, 0.5, 1.0, 1.5]
    ys = [1.0, 1.0, 1.5, 9.0, 0.5]
    zs = [0.0, 0.0, 0.5, 0.0, 3.0]
    inside2d = [1, 3, 5]
    inside3d = [1, 3]

    make2d = Dict(
        Emitter2D => () -> [Emitter2D{Float64}(xs[i], ys[i], 1000.0) for i in 1:5],
        Emitter2DFit => () -> [Emitter2DFit{Float64}(xs[i], ys[i], 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0,
                                                     frame=i) for i in 1:5])
    make3d = Dict(
        Emitter3D => () -> [Emitter3D{Float64}(xs[i], ys[i], zs[i], 1000.0) for i in 1:5],
        Emitter3DFit => () -> [Emitter3DFit{Float64}(xs[i], ys[i], zs[i], 1000.0, 10.0,
                                                     0.01, 0.01, 0.02, 50.0, 2.0, frame=i) for i in 1:5])

    for (E, make) in make2d
        @testset "$E" begin
            s = BasicSMLD(make(), cam, 5, 1, Dict{String,Any}("k" => 1))
            r = filter_roi(s, xr, yr)
            @test typeof(r) == typeof(s)
            @test length(r.emitters) == length(inside2d)
            @test [e.x for e in r.emitters] == xs[inside2d]
            @test [e.y for e in r.emitters] == ys[inside2d]
            @test r.camera === s.camera
            @test r.n_frames == s.n_frames
            @test r.n_datasets == s.n_datasets
            @test r.metadata == s.metadata
            @test r.metadata !== s.metadata
            @test_throws ErrorException(msg3on2) filter_roi(s, xr, yr, zr)
            @test occursin("2D", sprint(show, s))
            @test occursin("2D", sprint(show, MIME("text/plain"), s))
        end
    end

    for (E, make) in make3d
        @testset "$E" begin
            s = BasicSMLD(make(), cam, 5, 1, Dict{String,Any}("k" => 1))
            r = filter_roi(s, xr, yr, zr)
            @test typeof(r) == typeof(s)
            @test length(r.emitters) == length(inside3d)
            @test [e.x for e in r.emitters] == xs[inside3d]
            @test [e.y for e in r.emitters] == ys[inside3d]
            @test [e.z for e in r.emitters] == zs[inside3d]
            @test r.camera === s.camera
            @test r.n_frames == s.n_frames
            @test r.n_datasets == s.n_datasets
            @test r.metadata == s.metadata
            @test r.metadata !== s.metadata
            @test_throws ErrorException(msg2on3) filter_roi(s, xr, yr)
            @test occursin("3D", sprint(show, s))
            @test occursin("3D", sprint(show, MIME("text/plain"), s))
        end
    end

    @testset "Allocation parity" begin
        n = 10_000
        s2 = BasicSMLD([Emitter2DFit{Float64}(rand(), rand(), 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0)
                        for _ in 1:n], cam, 1, 1)
        s3 = BasicSMLD([Emitter3DFit{Float64}(rand(), rand(), rand(), 1000.0, 10.0, 0.01, 0.01, 0.02, 50.0, 2.0)
                        for _ in 1:n], cam, 1, 1)
        xr, yr, zr = (0.2, 0.8), (0.2, 0.8), (0.2, 0.8)
        _alloc_roi(s2, xr, yr); _alloc_ref(s2, xr, yr)
        _alloc_roi(s3, xr, yr, zr); _alloc_ref(s3, xr, yr, zr)
        @test _alloc_roi(s2, xr, yr) == _alloc_ref(s2, xr, yr)
        @test _alloc_roi(s3, xr, yr, zr) == _alloc_ref(s3, xr, yr, zr)
    end
end
