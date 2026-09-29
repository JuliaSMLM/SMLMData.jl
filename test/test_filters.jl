using SMLMData, Test

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

# Emitter types as another package would define them: subtypes of AbstractEmitter only
mutable struct ForeignEmitter2D{T} <: SMLMData.AbstractEmitter
    x::T; y::T; photons::T; frame::Int; dataset::Int; track_id::Int; id::Int
end
mutable struct ForeignEmitter3D{T} <: SMLMData.AbstractEmitter
    x::T; y::T; z::T; photons::T; frame::Int; dataset::Int; track_id::Int; id::Int
end
mutable struct ForeignEmitter3DFit{T} <: SMLMData.AbstractEmitter   # for save_smite
    x::T; y::T; z::T; photons::T; bg::T; σ_x::T; σ_y::T; σ_z::T; σ_photons::T; σ_bg::T
    frame::Int; dataset::Int; track_id::Int; id::Int
end

# Mimics SykTrack's Localization: position in a tuple, x/y/z computed in getproperty,
# :z listed in propertynames only for N >= 3. No emitter_ndims method of its own.
struct PropZLoc{N,T} <: SMLMData.AbstractEmitter
    position::NTuple{N,T}
    uncertainty::NTuple{N,T}
    photons::T
    bg::T
    σ_photons::T
    σ_bg::T
    frame::Int
    dataset::Int
    track_id::Int
    id::Int
end
function Base.getproperty(e::PropZLoc{N,T}, s::Symbol) where {N,T}
    s === :x && return getfield(e, :position)[1]
    s === :y && return getfield(e, :position)[2]
    s === :z && return N >= 3 ? getfield(e, :position)[3] : zero(T)
    s === :σ_x && return getfield(e, :uncertainty)[1]
    s === :σ_y && return getfield(e, :uncertainty)[2]
    s === :σ_z && return N >= 3 ? getfield(e, :uncertainty)[3] : zero(T)
    return getfield(e, s)
end
Base.propertynames(::PropZLoc{N,T}) where {N,T} =
    (fieldnames(PropZLoc{N,T})..., (N >= 3 ? (:x, :y, :z, :σ_x, :σ_y, :σ_z) : (:x, :y, :σ_x, :σ_y))...)

# One concrete type whose instances differ in dimension: :z is listed only when the
# position has three entries.
struct VarDimLoc <: SMLMData.AbstractEmitter
    position::Vector{Float64}
    photons::Float64
    frame::Int
    dataset::Int
    track_id::Int
    id::Int
end
function Base.getproperty(e::VarDimLoc, s::Symbol)
    s === :x && return getfield(e, :position)[1]
    s === :y && return getfield(e, :position)[2]
    s === :z && return length(getfield(e, :position)) >= 3 ? getfield(e, :position)[3] : 0.0
    return getfield(e, s)
end
# Two constant tuples: splatting a runtime-chosen tuple here would allocate on every call.
Base.propertynames(e::VarDimLoc) = length(getfield(e, :position)) >= 3 ?
    (:position, :photons, :frame, :dataset, :track_id, :id, :x, :y, :z) :
    (:position, :photons, :frame, :dataset, :track_id, :id, :x, :y)

# Same as PropZLoc, plus the documented type-only declaration.
struct DeclaredZLoc{N,T} <: SMLMData.AbstractEmitter
    position::NTuple{N,T}
    uncertainty::NTuple{N,T}
    photons::T
    bg::T
    σ_photons::T
    σ_bg::T
    frame::Int
    dataset::Int
    track_id::Int
    id::Int
end
function Base.getproperty(e::DeclaredZLoc{N,T}, s::Symbol) where {N,T}
    s === :x && return getfield(e, :position)[1]
    s === :y && return getfield(e, :position)[2]
    s === :z && return N >= 3 ? getfield(e, :position)[3] : zero(T)
    s === :σ_x && return getfield(e, :uncertainty)[1]
    s === :σ_y && return getfield(e, :uncertainty)[2]
    s === :σ_z && return N >= 3 ? getfield(e, :uncertainty)[3] : zero(T)
    return getfield(e, s)
end
Base.propertynames(::DeclaredZLoc{N,T}) where {N,T} =
    (fieldnames(DeclaredZLoc{N,T})..., (N >= 3 ? (:x, :y, :z, :σ_x, :σ_y, :σ_z) : (:x, :y, :σ_x, :σ_y))...)
SMLMData.emitter_ndims(::Type{<:DeclaredZLoc{N}}) where {N} = N
SMLMData.emitter_ndims(::Type{<:DeclaredZLoc}) = nothing

# Computes z in getproperty but does not list it in propertynames; declares its
# dimension on its type instead.
struct DeclaredOnlyLoc{N,T} <: SMLMData.AbstractEmitter
    position::NTuple{N,T}
    photons::T
    frame::Int
    dataset::Int
    track_id::Int
    id::Int
end
function Base.getproperty(e::DeclaredOnlyLoc{N,T}, s::Symbol) where {N,T}
    s === :x && return getfield(e, :position)[1]
    s === :y && return getfield(e, :position)[2]
    s === :z && return N >= 3 ? getfield(e, :position)[3] : zero(T)
    return getfield(e, s)
end
SMLMData.emitter_ndims(::Type{<:DeclaredOnlyLoc{N}}) where {N} = N
SMLMData.emitter_ndims(::Type{<:DeclaredOnlyLoc}) = nothing

# Has a field z but its type declares 2: a property z always wins for elements.
struct ZFieldDeclared2 <: SMLMData.AbstractEmitter
    x::Float64
    y::Float64
    z::Float64
    photons::Float64
    frame::Int
    dataset::Int
    track_id::Int
    id::Int
end
SMLMData.emitter_ndims(::Type{ZFieldDeclared2}) = 2

# Function barrier so the allocation count is the scan's own.
_nd_alloc(v) = minimum(@allocated(emitter_ndims(v)) for _ in 1:5)

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
            @test occursin("2D localizations", sprint(show, MIME("text/plain"), s))
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
            @test occursin("3D localizations", sprint(show, MIME("text/plain"), s))
        end
    end

    @testset "Allocation parity" begin
        n = 10_000
        s2 = BasicSMLD([Emitter2DFit{Float64}(rand(), rand(), 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0)
                        for _ in 1:n], cam, 1, 1)
        s3 = BasicSMLD([Emitter3DFit{Float64}(rand(), rand(), rand(), 1000.0, 10.0, 0.01, 0.01, 0.02, 50.0, 2.0)
                        for _ in 1:n], cam, 1, 1)
        rx, ry, rz = (0.2, 0.8), (0.2, 0.8), (0.2, 0.8)
        _alloc_roi(s2, rx, ry); _alloc_ref(s2, rx, ry)
        _alloc_roi(s3, rx, ry, rz); _alloc_ref(s3, rx, ry, rz)
        @test _alloc_roi(s2, rx, ry) == _alloc_ref(s2, rx, ry)
        @test _alloc_roi(s3, rx, ry, rz) == _alloc_ref(s3, rx, ry, rz)

        t2 = BasicSMLD([Emitter2D{Float64}(rand(), rand(), 1000.0) for _ in 1:n], cam, 1, 1)
        t3 = BasicSMLD([Emitter3D{Float64}(rand(), rand(), rand(), 1000.0) for _ in 1:n], cam, 1, 1)
        _alloc_roi(t2, rx, ry); _alloc_ref(t2, rx, ry)
        _alloc_roi(t3, rx, ry, rz); _alloc_ref(t3, rx, ry, rz)
        @test _alloc_roi(t2, rx, ry) == _alloc_ref(t2, rx, ry)
        @test _alloc_roi(t3, rx, ry, rz) == _alloc_ref(t3, rx, ry, rz)
    end

    @testset "Foreign emitter types" begin
        e2 = [ForeignEmitter2D{Float64}(xs[i], ys[i], 1000.0, i, 1, 0, i) for i in 1:5]
        s2 = BasicSMLD(e2, cam, 5, 1)
        r2 = filter_roi(s2, xr, yr)
        @test [e.x for e in r2.emitters] == xs[inside2d]
        @test_throws ErrorException(msg3on2) filter_roi(s2, xr, yr, zr)
        @test occursin("2D", sprint(show, s2))
        @test occursin("2D localizations", sprint(show, MIME("text/plain"), s2))

        e3 = [ForeignEmitter3D{Float64}(xs[i], ys[i], zs[i], 1000.0, i, 1, 0, i) for i in 1:5]
        s3 = BasicSMLD(e3, cam, 5, 1)
        r3 = filter_roi(s3, xr, yr, zr)
        @test [e.x for e in r3.emitters] == xs[inside3d]
        @test [e.z for e in r3.emitters] == zs[inside3d]
        @test_throws ErrorException(msg2on3) filter_roi(s3, xr, yr)
        @test occursin("3D", sprint(show, s3))
        @test occursin("3D localizations", sprint(show, MIME("text/plain"), s3))
    end

    @testset "Non-concrete eltype" begin
        A = SMLMData.AbstractEmitter
        e2 = A[Emitter2DFit{Float64}(xs[i], ys[i], 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0) for i in 1:5]
        e3 = A[Emitter3DFit{Float64}(xs[i], ys[i], zs[i], 1000.0, 10.0, 0.01, 0.01, 0.02, 50.0, 2.0) for i in 1:5]

        s2 = BasicSMLD(e2, cam, 5, 1)
        @test [e.x for e in filter_roi(s2, xr, yr).emitters] == xs[inside2d]
        @test_throws ErrorException(msg3on2) filter_roi(s2, xr, yr, zr)

        s3 = BasicSMLD(e3, cam, 5, 1)
        @test [e.z for e in filter_roi(s3, xr, yr, zr).emitters] == zs[inside3d]
        @test_throws ErrorException(msg2on3) filter_roi(s3, xr, yr)

        mixed = BasicSMLD(A[e2[1], e3[1]], cam, 5, 1)
        @test_throws ErrorException(msg2on3) filter_roi(mixed, xr, yr)
        @test_throws ErrorException(msg3on2) filter_roi(mixed, xr, yr, zr)

        U = Union{Emitter2DFit{Float64}, Emitter3DFit{Float64}}
        union_smld = BasicSMLD(U[e2[1], e3[1]], cam, 5, 1)
        @test_throws ErrorException(msg2on3) filter_roi(union_smld, xr, yr)
        @test_throws ErrorException(msg3on2) filter_roi(union_smld, xr, yr, zr)

        empty_smld = BasicSMLD(A[], cam, 5, 1)
        @test isempty(filter_roi(empty_smld, xr, yr).emitters)
        @test isempty(filter_roi(empty_smld, xr, yr, zr).emitters)
    end

    @testset "save_smite with foreign 3D emitters" begin
        es = [ForeignEmitter3DFit{Float64}(xs[i], ys[i], zs[i], 1000.0, 10.0, 0.01, 0.01, 0.02 + i,
                                           50.0, 2.0, i, 1, 0, i) for i in 1:5]
        s = SmiteSMLD{Float64,ForeignEmitter3DFit{Float64}}(es, cam, 5, 1, Dict{String,Any}())
        mktempdir() do dir
            save_smite(s, dir, "foreign.mat")
            smd = SMLMData.MAT.matread(joinpath(dir, "foreign.mat"))["SMD"]
            @test vec(smd["Z"]) == zs
            @test vec(smd["Z_SE"]) == [0.02 + i for i in 1:5]
        end
    end

    @testset "emitter_ndims" begin
        A = SMLMData.AbstractEmitter
        mk = Dict(
            Emitter2D => (Emitter2D{Float64}(1.0, 2.0, 1000.0), 2),
            Emitter2DFit => (Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0), 2),
            Emitter3D => (Emitter3D{Float64}(1.0, 2.0, 3.0, 1000.0), 3),
            Emitter3DFit => (Emitter3DFit{Float64}(1.0, 2.0, 3.0, 1000.0, 10.0, 0.01, 0.01, 0.02, 50.0, 2.0), 3))
        for (E, (e, d)) in mk
            @test emitter_ndims(E) == d
            @test emitter_ndims(E{Float64}) == d
            @test emitter_ndims(e) == d
            @test emitter_ndims([e]) == d
            @test emitter_ndims(BasicSMLD([e], cam, 1, 1)) == d
        end

        f2 = ForeignEmitter2D{Float64}(1.0, 2.0, 1000.0, 1, 1, 0, 1)
        f3 = ForeignEmitter3D{Float64}(1.0, 2.0, 3.0, 1000.0, 1, 1, 0, 1)
        for (F, f, d) in ((ForeignEmitter2D, f2, 2), (ForeignEmitter3D, f3, 3))
            @test emitter_ndims(F) == d
            @test emitter_ndims(F{Float64}) == d
            @test emitter_ndims(f) == d
            @test emitter_ndims([f]) == d
            @test emitter_ndims(BasicSMLD([f], cam, 1, 1)) == d
        end

        e2, e3 = mk[Emitter2D][1], mk[Emitter3D][1]
        @test emitter_ndims(A[e2, e2]) == 2
        @test emitter_ndims(A[e3, e3]) == 3
        @test emitter_ndims(A[e2, e3]) === nothing
        @test emitter_ndims(A[]) === nothing
        @test emitter_ndims(Emitter3DFit{Float64}[]) == 3

        @test emitter_ndims(A) === nothing
        @test emitter_ndims(Union{Emitter2DFit{Float64}, Emitter3DFit{Float64}}) === nothing
        @test @inferred(emitter_ndims(Emitter2DFit{Float64}[])) == 2
        @test @inferred(emitter_ndims([mk[Emitter2DFit][1]])) == 2
        @test @inferred(emitter_ndims([mk[Emitter3DFit][1]])) == 3
    end

    @testset "emitter_ndims: computed z via propertynames" begin
        cam = IdealCamera(1:64, 1:64, 0.1)
        mk2(x, y, i) = PropZLoc{2,Float64}((x, y), (0.01, 0.01), 100.0, 5.0, 1.0, 1.0, 1, 1, 0, i)
        mk3(x, y, z, i) = PropZLoc{3,Float64}((x, y, z), (0.01, 0.01, 0.02 + i), 100.0, 5.0, 1.0, 1.0, 1, 1, 0, i)
        pts = [(0.5, 0.5, 0.0), (1.5, 1.0, 0.5), (5.0, 1.0, 0.0), (1.0, 1.0, 3.0)]   # first two inside the box
        p2s = [mk2(p[1], p[2], i) for (i, p) in enumerate(pts)]
        p3s = [mk3(p..., i) for (i, p) in enumerate(pts)]
        p2, p3 = p2s[1], p3s[1]

        @test emitter_ndims(p2) == 2
        @test emitter_ndims(p3) == 3
        @test emitter_ndims(p3s) == 3
        @test emitter_ndims(p2s) == 2
        s2 = BasicSMLD(p2s, cam, 1, 1)
        s3 = BasicSMLD(p3s, cam, 1, 1)
        @test emitter_ndims(s2) == 2
        @test emitter_ndims(s3) == 3
        @test emitter_ndims(PropZLoc[p3, p3]) == 3
        @test emitter_ndims(SMLMData.AbstractEmitter[p2, p3]) === nothing

        r3 = filter_roi(s3, (0.0, 2.0), (0.0, 2.0), (-1.0, 1.0))
        @test [e.id for e in r3.emitters] == [1, 2]
        @test_throws ErrorException("2D ROI cannot be applied to 3D emitter type") filter_roi(s3, (0.0, 2.0), (0.0, 2.0))
        r2 = filter_roi(s2, (0.0, 2.0), (0.0, 2.0))
        @test [e.id for e in r2.emitters] == [1, 2, 4]
        @test_throws ErrorException("3D ROI cannot be applied to 2D emitter type") filter_roi(s2, (0.0, 2.0), (0.0, 2.0), (-1.0, 1.0))

        mktempdir() do dir
            t3 = SmiteSMLD{Float64,PropZLoc{3,Float64}}(p3s, cam, 1, 1, Dict{String,Any}())
            save_smite(t3, dir, "p3.mat")
            smd = SMLMData.MAT.matread(joinpath(dir, "p3.mat"))["SMD"]
            @test vec(smd["Z"]) == [p[3] for p in pts]
            @test vec(smd["Z_SE"]) == [0.02 + i for i in 1:4]
            t2 = SmiteSMLD{Float64,PropZLoc{2,Float64}}(p2s, cam, 1, 1, Dict{String,Any}())
            save_smite(t2, dir, "p2.mat")
            smd = SMLMData.MAT.matread(joinpath(dir, "p2.mat"))["SMD"]
            @test !haskey(smd, "Z")
            @test !haskey(smd, "Z_SE")
        end

        @test occursin("2D", sprint(show, s2))
        @test occursin("3D", sprint(show, s3))
        @test occursin("2D localizations", sprint(show, MIME("text/plain"), s2))
        @test occursin("3D localizations", sprint(show, MIME("text/plain"), s3))

        # Documented limit: without an element only the fields are visible, so a computed z reads as 2.
        @test emitter_ndims(PropZLoc{3,Float64}) == 2
        @test emitter_ndims(PropZLoc{3,Float64}[]) == 2
    end

    @testset "emitter_ndims: declared type-only answer" begin
        cam = IdealCamera(1:64, 1:64, 0.1)
        d2 = DeclaredZLoc{2,Float64}((1.0, 1.0), (0.01, 0.01), 100.0, 5.0, 1.0, 1.0, 1, 1, 0, 1)
        d3 = DeclaredZLoc{3,Float64}((1.0, 1.0, 0.0), (0.01, 0.01, 0.02), 100.0, 5.0, 1.0, 1.0, 1, 1, 0, 2)
        @test emitter_ndims(DeclaredZLoc{3,Float64}) == 3
        @test emitter_ndims(DeclaredZLoc{3,Float64}[]) == 3
        @test emitter_ndims(DeclaredZLoc) === nothing
        @test emitter_ndims(DeclaredZLoc[]) === nothing
        @test emitter_ndims(DeclaredZLoc[d2, d3]) === nothing
        empty_s = BasicSMLD(DeclaredZLoc{3,Float64}[], cam, 1, 1)
        @test isempty(filter_roi(empty_s, (0.0, 2.0), (0.0, 2.0), (-1.0, 1.0)).emitters)
    end

    @testset "emitter_ndims: precedence" begin
        cam = IdealCamera(1:64, 1:64, 0.1)
        in2 = DeclaredOnlyLoc{2,Float64}((1.0, 1.0), 100.0, 1, 1, 0, 1)
        out2 = DeclaredOnlyLoc{2,Float64}((5.0, 5.0), 100.0, 1, 1, 0, 2)
        in3 = DeclaredOnlyLoc{3,Float64}((1.0, 1.0, 0.0), 100.0, 1, 1, 0, 3)
        out3 = DeclaredOnlyLoc{3,Float64}((5.0, 5.0, 5.0), 100.0, 1, 1, 0, 4)
        @test emitter_ndims(in2) == 2
        @test emitter_ndims(in3) == 3
        @test emitter_ndims([in3, out3]) == 3
        @test emitter_ndims(DeclaredOnlyLoc{3,Float64}[]) == 3
        @test emitter_ndims(DeclaredOnlyLoc[in3, out3]) == 3
        @test emitter_ndims(DeclaredOnlyLoc[in2, in3]) === nothing
        @test emitter_ndims(DeclaredOnlyLoc{2}) == 2
        s3 = BasicSMLD([in3, out3], cam, 1, 1)
        r3 = filter_roi(s3, (0.0, 2.0), (0.0, 2.0), (-1.0, 1.0))
        @test length(r3.emitters) == 1
        @test r3.emitters[1].id == 3
        s2 = BasicSMLD([in2, out2], cam, 1, 1)
        r2 = filter_roi(s2, (0.0, 2.0), (0.0, 2.0))
        @test length(r2.emitters) == 1
        @test r2.emitters[1].id == 1

        zf = ZFieldDeclared2(1.0, 1.0, 0.0, 100.0, 1, 1, 0, 1)
        @test emitter_ndims(ZFieldDeclared2) == 2
        @test emitter_ndims(zf) == 3
        @test emitter_ndims([zf, zf]) == 3

        e2 = Emitter2DFit{Float64}(1.0, 1.0, 100.0, 1.0, 0.01, 0.01, 1.0, 1.0, frame=1)
        @test emitter_ndims(SMLMData.AbstractEmitter[e2, e2]) == 2
    end
    @testset "emitter_ndims: instances of one type that differ" begin
        cam = IdealCamera(1:64, 1:64, 0.1)
        a2 = VarDimLoc([1.0, 1.0], 100.0, 1, 1, 0, 1)
        a3 = VarDimLoc([1.0, 1.0, 0.0], 100.0, 1, 1, 0, 2)
        for order in ([a2, a3], [a3, a2])
            @test order isa Vector{VarDimLoc}
            @test emitter_ndims(order) === nothing
            s = BasicSMLD(order, cam, 1, 1)
            @test emitter_ndims(s) === nothing
            @test_throws ErrorException(msg2on3) filter_roi(s, xr, yr)
            @test_throws ErrorException(msg3on2) filter_roi(s, xr, yr, zr)
            @test occursin("mixed 2D/3D", sprint(show, s))
        end
        @test emitter_ndims([a3, a3]) == 3
        @test emitter_ndims([a2, a2]) == 2
        r3 = filter_roi(BasicSMLD([a3, a3], cam, 1, 1), xr, yr, zr)
        @test length(r3.emitters) == 2
        r2 = filter_roi(BasicSMLD([a2, a2], cam, 1, 1), xr, yr)
        @test length(r2.emitters) == 2
    end

    @testset "empty Union of one dimension" begin
        cam = IdealCamera(1:64, 1:64, 0.1)
        E2 = Union{Emitter2D{Float64}, Emitter2DFit{Float64}}
        E3 = Union{Emitter3D{Float64}, Emitter3DFit{Float64}}
        @test emitter_ndims(E2[]) === nothing
        @test emitter_ndims(E3[]) === nothing
        for v in (E2[], E3[])
            s = BasicSMLD(v, cam, 1, 1)
            @test isempty(filter_roi(s, (0.0, 1.0), (0.0, 1.0)).emitters)
            @test isempty(filter_roi(s, (0.0, 1.0), (0.0, 1.0), (-1.0, 1.0)).emitters)
        end
        @test emitter_ndims(Emitter2DFit{Float64}[]) == 2
        @test emitter_ndims(Emitter3DFit{Float64}[]) == 3
    end

    @testset "foreign element scan allocates nothing" begin
        n = 10_000
        mkp2(i) = PropZLoc{2,Float64}((1.0, 2.0), (0.01, 0.01), 100.0, 5.0, 1.0, 1.0, 1, 1, 0, i)
        mkp3(i) = PropZLoc{3,Float64}((1.0, 2.0, 3.0), (0.01, 0.01, 0.02), 100.0, 5.0, 1.0, 1.0, 1, 1, 0, i)
        vs = (
            [ForeignEmitter2D{Float64}(1.0, 2.0, 1000.0, 1, 1, 0, i) for i in 1:n],
            [ForeignEmitter3D{Float64}(1.0, 2.0, 3.0, 1000.0, 1, 1, 0, i) for i in 1:n],
            [mkp2(i) for i in 1:n],
            [mkp3(i) for i in 1:n],
            [VarDimLoc([1.0, 1.0], 100.0, 1, 1, 0, i) for i in 1:n],
            [VarDimLoc([1.0, 1.0, 0.0], 100.0, 1, 1, 0, i) for i in 1:n],
        )
        for v in vs
            _nd_alloc(v)   # warm up
            @test _nd_alloc(v) == 0
        end
    end

    @testset "save_smite rejects mixed dimensions" begin
        cam = IdealCamera(1:64, 1:64, 0.1)
        A = SMLMData.AbstractEmitter
        e2 = Emitter2DFit{Float64}(1.0, 1.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0)
        e3 = Emitter3DFit{Float64}(1.0, 1.0, 0.0, 1000.0, 10.0, 0.01, 0.01, 0.02, 50.0, 2.0)
        mixed = SmiteSMLD{Float64,A}(A[e2, e3], cam, 1, 1, Dict{String,Any}())
        empty_s = SmiteSMLD{Float64,A}(A[], cam, 1, 1, Dict{String,Any}())
        mktempdir() do dir
            @test_throws ArgumentError save_smite(mixed, dir, "mixed.mat")
            save_smite(empty_s, dir, "empty.mat")
            smd = SMLMData.MAT.matread(joinpath(dir, "empty.mat"))["SMD"]
            @test !haskey(smd, "Z")
        end
    end

    @testset "show labels mixed and unknown dimensions" begin
        cam = IdealCamera(1:64, 1:64, 0.1)
        A = SMLMData.AbstractEmitter
        e2 = Emitter2DFit{Float64}(1.0, 1.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0)
        e3 = Emitter3DFit{Float64}(1.0, 1.0, 0.0, 1000.0, 10.0, 0.01, 0.01, 0.02, 50.0, 2.0)
        s = BasicSMLD(A[e2, e3], cam, 1, 1)
        @test occursin("mixed 2D/3D", sprint(show, s))
        @test occursin("mixed 2D/3D localizations", sprint(show, MIME("text/plain"), s))
        @test occursin("unknown-dimension", sprint(show, BasicSMLD(A[], cam, 1, 1)))
        ms = SmiteSMLD{Float64,A}(A[e2, e3], cam, 1, 1, Dict{String,Any}())
        @test occursin("mixed 2D/3D", sprint(show, MIME("text/plain"), ms))
    end
end
