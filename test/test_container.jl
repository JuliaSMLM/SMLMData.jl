using SMLMData, Test, JLD2
import SMLMCore, SMLMio

# What SMLMData is since 0.7.2: SMLMCore and SMLMio loaded, and 0.7.1's names re-exported as
# those packages' own objects.

# names(SMLMData) under SMLMData 0.7.1, the module's own name included.
const EXPORTS_071 = Symbol[
    Symbol("@filter"), :AbstractCamera, :AbstractEmitter, :AbstractSMLD, :AbstractSMLMConfig,
    :AbstractSMLMInfo, :BasicSMLD, :Emitter2D, :Emitter2DFit, :Emitter3D, :Emitter3DFit,
    :IdealCamera, :ROIBatch, :SCMOSCamera, :SMLD, :SMLMData, :SingleROI, :SmiteSMD, :SmiteSMLD,
    :cat_smld, :compute_bin_edges, :emitter_ndims, :filter_frames, :filter_roi,
    :get_pixel_centers, :load_smite_2d, :load_smite_3d, :merge_smld, :physical_to_pixel,
    :physical_to_pixel_index, :pixel_to_physical, :save_smite,
]
const IO_NAMES = (:SmiteSMD, :SmiteSMLD, :load_smite_2d, :load_smite_3d, :save_smite)

# An emitter type defined outside the three packages, extended through SMLMData's names
mutable struct ContainerTestEmitter <: SMLMData.AbstractEmitter
    x::Float64
    y::Float64
    z::Float64
end
SMLMData.emitter_ndims(::Type{<:ContainerTestEmitter}) = 3

@testset "exports are 0.7.1's" begin
    @test length(EXPORTS_071) == 32
    @test Set(names(SMLMData)) == Set(EXPORTS_071)
end

@testset "each name is the owning package's object" begin
    for n in EXPORTS_071
        n === :SMLMData && continue
        owner = n in IO_NAMES ? SMLMio : SMLMCore
        @test getfield(SMLMData, n) === getfield(owner, n)
        @test n in names(owner)
    end
    @test parentmodule(SMLMData.BasicSMLD) === SMLMCore
    @test parentmodule(SMLMData.SmiteSMLD) === SMLMio
    @test SMLMData.SmiteSMLD <: SMLMCore.AbstractSMLD
end

@testset "a method added through SMLMData is the owner's" begin
    @test ContainerTestEmitter <: SMLMCore.AbstractEmitter
    @test hasmethod(SMLMCore.emitter_ndims, Tuple{Type{ContainerTestEmitter}})
    @test SMLMCore.emitter_ndims(ContainerTestEmitter) == 3
    v = [ContainerTestEmitter(1.0, 1.0, 0.5), ContainerTestEmitter(2.0, 1.0, 0.5)]
    s = BasicSMLD(v, IdealCamera(32, 32, 0.1), 1, 1, Dict{String,Any}())
    @test s isa SMLMCore.BasicSMLD
    @test length(filter_roi(s, (0.5, 1.5), (0.5, 1.5), (0.0, 1.0)).emitters) == 1  # routed as 3D
end

@testset "api_overview" begin
    text = SMLMData.api_overview()
    @test text isa String
    @test occursin("SMLMCore", text) && occursin("SMLMio", text)
    @test endswith(text, SMLMCore.api_overview())
end

# Results saved with JLD2 by SMLMData 0.7.1. SMLMData 0.7.1 itself writes them, at test time, in
# a temporary environment of its own (no data file is tracked): SMLDs built from seeded random
# values, with a plain copy of every value beside them. JLD2 records each type under SMLMData's
# name; loaded here, each must come back as the same type, not a reconstruction.
const WRITER_071 = raw"""
using SMLMData, JLD2, Random
pkgversion(SMLMData) == v"0.7.1" || error("expected SMLMData 0.7.1, got $(pkgversion(SMLMData))")
rng = Xoshiro(20261121)
u(a, b) = a + (b - a) * rand(rng)
fit2(i) = Emitter2DFit{Float64}(u(0, 3.2), u(0, 3.2), u(500, 5000), u(1, 20), u(0.005, 0.03),
    u(0.005, 0.03), u(10, 80), u(0.5, 3); σ_xy = u(-1e-4, 1e-4), frame = rand(rng, 1:10),
    dataset = rand(rng, 1:2), track_id = rand(rng, 0:5), id = i)
fit3(i) = Emitter3DFit{Float64}(u(0, 3.2), u(0, 3.2), u(-0.5, 0.5), u(500, 5000), u(1, 20),
    u(0.005, 0.03), u(0.005, 0.03), u(0.01, 0.06), u(10, 80), u(0.5, 3);
    σ_xy = u(-1e-4, 1e-4), σ_xz = u(-1e-4, 1e-4), σ_yz = u(-1e-4, 1e-4),
    frame = rand(rng, 1:20), track_id = rand(rng, 0:5), id = i)
cam2 = IdealCamera(32, 32, 0.1)
readnoise = [1.2 + 0.01 * (i + j) for i in 1:32, j in 1:32]      # (ny, nx) maps
gain = [0.5 + 0.001 * i for i in 1:32, j in 1:32]
cam3 = SCMOSCamera(32, 32, 0.1, readnoise; offset = 100.0, gain = gain, qe = 0.82)
meta(kind) = Dict{String,Any}("kind" => kind, "seed" => 20261121)
e2 = [fit2(i) for i in 1:60]
smld2d = BasicSMLD(e2, cam2, 10, 2, meta("2D"))
smld3d = BasicSMLD([fit3(i) for i in 1:40], cam3, 20, 1, meta("3D"))
smite2d = SmiteSMLD{Float64,Emitter2DFit{Float64}}(e2[1:20], cam2, 10, 2, meta("SMITE 2D"))
function plain(s)
    E, cam = eltype(s.emitters), s.camera
    Dict{String,Any}(
        "smld_type" => string(nameof(typeof(s))),
        "emitter_type" => string(nameof(E)),
        "emitter_fields" => Dict{String,Any}(string(f) => [getfield(e, f) for e in s.emitters]
                                             for f in fieldnames(E)),
        "camera_fields" => Dict{String,Any}(string(f) => getfield(cam, f) for f in fieldnames(typeof(cam))),
        "n_frames" => s.n_frames, "n_datasets" => s.n_datasets, "metadata" => s.metadata,
    )
end
jldsave(ARGS[1]; smld2d, smld3d, smite2d,
        plain2d = plain(smld2d), plain3d = plain(smld3d), plainsmite = plain(smite2d),
        written_by = "SMLMData $(pkgversion(SMLMData)), JLD2 $(pkgversion(JLD2)), Julia $(VERSION)")
"""

function write_with_smlmdata071(file)
    env = mktempdir()
    script = joinpath(env, "write.jl")
    write(script, WRITER_071)
    specs = "[PackageSpec(name = \"SMLMData\", version = \"0.7.1\"), " *
            "PackageSpec(name = \"JLD2\", version = \"$(pkgversion(JLD2))\")]"
    julia = `$(Base.julia_cmd()) --startup-file=no --project=$env`
    # Only the temporary environment and the standard library: never this package's test env.
    withenv("JULIA_LOAD_PATH" => "@:@stdlib", "JULIA_PROJECT" => nothing) do
        run(`$julia -e "using Pkg; Pkg.add($specs; io = devnull)"`)
        run(`$julia $script $file`)
    end
    return file
end

@testset "SMLDs saved with JLD2 by 0.7.1 load and equal the original" begin
    file = write_with_smlmdata071(joinpath(mktempdir(), "smld_v071.jld2"))
    data = @test_logs min_level = Base.CoreLogging.Warn load(file)
    @test startswith(data["written_by"], "SMLMData 0.7.1,")
    for (key, pkey, T, E, C) in (
        ("smld2d", "plain2d", BasicSMLD, Emitter2DFit{Float64}, IdealCamera{Float64}),
        ("smld3d", "plain3d", BasicSMLD, Emitter3DFit{Float64}, SCMOSCamera{Float64}),
        ("smite2d", "plainsmite", SmiteSMLD, Emitter2DFit{Float64}, IdealCamera{Float64}),
    )
        s, p = data[key], data[pkey]
        @test s isa T{Float64,E}
        @test s.emitters isa Vector{E}
        @test s.camera isa C
        @test string(nameof(typeof(s))) == p["smld_type"]
        @test string(nameof(E)) == p["emitter_type"]
        @test !isempty(s.emitters)
        for f in fieldnames(E)
            @test isequal([getfield(e, f) for e in s.emitters], p["emitter_fields"][string(f)])
        end
        @test sort(collect(keys(p["emitter_fields"]))) == sort(string.(collect(fieldnames(E))))
        for f in fieldnames(C)
            @test isequal(getfield(s.camera, f), p["camera_fields"][string(f)])
        end
        @test s.n_frames == p["n_frames"]
        @test s.n_datasets == p["n_datasets"]
        @test s.metadata == p["metadata"]
        # The loaded SMLD works with the current functions
        @test emitter_ndims(s) == (E <: Emitter3DFit ? 3 : 2)
        @test length(@filter(s, photons > 0)) == length(s.emitters)
    end
end
