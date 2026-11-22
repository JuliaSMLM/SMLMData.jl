"""
    SMLMData

Single molecule localization microscopy (SMLM) data types and SMITE file io, as one package.

Since 0.7.2 SMLMData holds no code of its own: it loads [SMLMCore](https://github.com/JuliaSMLM/SMLMCore.jl)
(emitters, cameras, ROI batches, SMLD containers, coordinates, filters and operations) and
[SMLMio](https://github.com/JuliaSMLM/SMLMio.jl) (SMITE files) and exports every name SMLMData 0.7.1
exported. Each name is the owning package's own object, so `SMLMData.BasicSMLD === SMLMCore.BasicSMLD`
and a method added to `SMLMData.filter_roi` is a method of `SMLMCore.filter_roi`. New code can depend
on SMLMCore, or on SMLMio for files, directly.

# Example
```julia
using SMLMData

cam = IdealCamera(512, 512, 0.1)  # 512 x 512 pixels of 0.1 µm
emitters = [
    Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0),
    Emitter2DFit{Float64}(3.0, 4.0, 1200.0, 12.0, 0.01, 0.01, 60.0, 2.0),
]
smld = BasicSMLD(emitters, cam, 1, 1)
bright = @filter(smld, photons > 1100)
```

`SMLMData.api_overview()` returns an overview of the whole API as a `String`.
"""
module SMLMData

using SMLMCore: SMLMCore,
    AbstractEmitter, AbstractCamera, AbstractSMLD, SMLD,
    AbstractSMLMConfig, AbstractSMLMInfo,
    Emitter2D, Emitter3D, Emitter2DFit, Emitter3DFit,
    IdealCamera, SCMOSCamera,
    SingleROI, ROIBatch,
    BasicSMLD,
    pixel_to_physical, physical_to_pixel, physical_to_pixel_index,
    compute_bin_edges, get_pixel_centers,
    @filter, filter_frames, filter_roi, emitter_ndims, cat_smld, merge_smld
using SMLMio: SMLMio,
    SmiteSMD, SmiteSMLD, load_smite_2d, load_smite_3d, save_smite

# Every name SMLMData 0.7.1 exported, and no other.
export
    # Abstract types
    AbstractEmitter,
    AbstractCamera,
    AbstractSMLD,
    SMLD,  # Alias of AbstractSMLD

    # Ecosystem abstract types (tuple pattern)
    AbstractSMLMConfig,
    AbstractSMLMInfo,

    # Concrete emitter types
    Emitter2D,
    Emitter3D,
    Emitter2DFit,
    Emitter3DFit,

    # Camera types
    IdealCamera,
    SCMOSCamera,

    # ROI batch types
    SingleROI,
    ROIBatch,

    # SMLD types
    BasicSMLD,
    SmiteSMLD,
    SmiteSMD

# Coordinates and conversions
export
    pixel_to_physical,
    physical_to_pixel,
    physical_to_pixel_index,
    compute_bin_edges,
    get_pixel_centers

# Filtering and operations
export
    @filter,
    filter_frames,
    filter_roi,
    emitter_ndims,
    cat_smld,
    merge_smld

# SMITE functionality
export
    load_smite_2d,
    load_smite_3d,
    save_smite

"""
    api_overview() -> String

An overview of the API for readers and language models: SMLMData's own `api_overview.md`, which
says where each name lives and what changed in 0.7.2, followed by `SMLMCore.api_overview()`. The
SMITE functions are documented by their docstrings (`?load_smite_2d`) and SMLMio's manual.
"""
function api_overview()
    own = read(joinpath(pkgdir(SMLMData), "api_overview.md"), String)
    return own * "\n\n" * SMLMCore.api_overview()
end

end
