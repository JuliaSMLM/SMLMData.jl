# SMLMData API overview

SMLMData (0.7.2 and later) is a container: it holds no code of its own, loads SMLMCore and SMLMio,
and exports every name SMLMData 0.7.1 exported. `using SMLMData` gives exactly those names.

## Where each name lives

- **SMLMCore** (types and operations): `AbstractEmitter`, `AbstractCamera`, `AbstractSMLD`, `SMLD`
  (an alias of `AbstractSMLD`), `AbstractSMLMConfig`, `AbstractSMLMInfo`, `Emitter2D`, `Emitter3D`,
  `Emitter2DFit`, `Emitter3DFit`, `IdealCamera`, `SCMOSCamera`, `SingleROI`, `ROIBatch`, `BasicSMLD`,
  `pixel_to_physical`, `physical_to_pixel`, `physical_to_pixel_index`, `compute_bin_edges`,
  `get_pixel_centers`, `@filter`, `filter_frames`, `filter_roi`, `emitter_ndims`, `cat_smld`,
  `merge_smld`.
- **SMLMio** (SMITE files): `SmiteSMD`, `SmiteSMLD`, `load_smite_2d`, `load_smite_3d`, `save_smite`.
  Each has a docstring (`?load_smite_2d`); the SMITE format and its units are described in SMLMio's
  manual, https://JuliaSMLM.github.io/SMLMio.jl/stable.
- **SMLMData** itself: only `api_overview()` (not exported), which returns this text followed by
  SMLMCore's overview.

Every name is the owning package's object (`SMLMData.BasicSMLD === SMLMCore.BasicSMLD`). Extend
the owner's function either way: `SMLMData.emitter_ndims(::Type{<:MyEmitter}) = 3` adds a method
to `SMLMCore.emitter_ndims`.

## Units and conventions

Lengths are in µm; pixel (1, 1) is the top-left pixel, centered at half a pixel from the camera's
origin. SMITE files store `X`, `Y`, `X_SE`, `Y_SE` in pixels; the SMITE loaders convert them to µm
and `save_smite` converts back.

## Changes from 0.7.1

Names, types and fields are unchanged. Behavior changes where SMLMCore 0.1.0 and SMLMio 0.1.0
fixed bugs (see their CHANGELOG.md files):

- `merge_smld(...; adjust_frames, adjust_datasets)` leaves its inputs unchanged; datasets of each
  input move past all earlier inputs' datasets, and `n_datasets` is the total.
- `cat_smld` / `merge_smld` refuse cameras that differ in any field (calibration included); with
  one input they return a new SMLD.
- `physical_to_pixel_index` uses half-open pixels: `x = 0` is pixel 1.
- `ROIBatch`: `adapt` moves only `data`; bad arguments throw `ArgumentError` or
  `DimensionMismatch`.
- SMITE loaders return µm (SMITE stores pixels); `save_smite` writes pixels and the camera's
  `XSize`, `YSize`, `PixelSize`, `NDims`, takes any `AbstractSMLD`, and its files load again.
  A file without `PixelSize` needs `pixel_size = ...`.
- Julia 1.10 or later.

## Installing beside SMLMCore or SMLMio

SMLMCore and SMLMio cannot be installed beside SMLMData 0.7.1 or earlier. With SMLMData 0.7.2 or
later they install together and share every type. New code can depend on SMLMCore (types only) or
SMLMio (files) directly.

## Saved results

JLD2 files written under SMLMData 0.7.1 load with SMLMData loaded (JLD2 finds each type through
SMLMData's name). Files written from 0.7.2 on record SMLMCore or SMLMio names and do not load as
the same types under SMLMData 0.7.1.
