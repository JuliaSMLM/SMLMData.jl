# SMLMData

Data types and SMITE file io for single molecule localization microscopy (SMLM) in Julia, as one
package. Since 0.7.2 SMLMData holds no code of its own: it loads
[SMLMCore](https://github.com/JuliaSMLM/SMLMCore.jl) and
[SMLMio](https://github.com/JuliaSMLM/SMLMio.jl) and exports every name SMLMData 0.7.1 exported.

[![CI](https://github.com/JuliaSMLM/SMLMData.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaSMLM/SMLMData.jl/actions/workflows/CI.yml)
[![Docs: stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaSMLM.github.io/SMLMData.jl/stable)

## Installation

```julia
using Pkg
Pkg.add("SMLMData")
```

## Quick start

```julia
using SMLMData

cam = IdealCamera(512, 512, 0.1)   # 512 × 512 pixels of 0.1 µm

emitters = [
    Emitter2DFit{Float64}(1.0, 2.0, 1000.0, 10.0, 0.01, 0.01, 50.0, 2.0),
    Emitter2DFit{Float64}(3.0, 4.0, 1200.0, 12.0, 0.02, 0.02, 60.0, 2.0),
]
smld = BasicSMLD(emitters, cam, 1, 1)   # 1 frame, 1 dataset

bright = @filter(smld, photons > 1100)              # the second emitter
region = filter_roi(smld, (0.0, 2.0), (1.0, 3.0))   # x and y bounds in µm: the first
```

## Where each name lives

| Names | Package | Manual |
|---|---|---|
| Emitters, cameras, `SingleROI`, `ROIBatch`, `BasicSMLD`, the abstract types (`AbstractEmitter`, `AbstractCamera`, `AbstractSMLD`, `SMLD`, `AbstractSMLMConfig`, `AbstractSMLMInfo`), coordinate conversions, `@filter`, `filter_frames`, `filter_roi`, `emitter_ndims`, `cat_smld`, `merge_smld` | SMLMCore | [SMLMCore docs](https://JuliaSMLM.github.io/SMLMCore.jl/stable) |
| `SmiteSMD`, `SmiteSMLD`, `load_smite_2d`, `load_smite_3d`, `save_smite` | SMLMio | [SMLMio docs](https://JuliaSMLM.github.io/SMLMio.jl/stable) |

Each name is the owning package's own object: `SMLMData.BasicSMLD === SMLMCore.BasicSMLD`, and a
method added to `SMLMData.filter_roi` is a method of `SMLMCore.filter_roi`. Packages built on
SMLMData, SMLMCore or SMLMio therefore pass the same objects to each other.

## Changes from 0.7.1

Names, types and their fields are unchanged. Behavior changes only where SMLMCore 0.1.0 and SMLMio
0.1.0 fixed bugs in the code they took over; their changelogs list every fix
([SMLMCore](https://github.com/JuliaSMLM/SMLMCore.jl/blob/main/CHANGELOG.md),
[SMLMio](https://github.com/JuliaSMLM/SMLMio.jl/blob/main/CHANGELOG.md)). The ones a caller sees:

- `merge_smld` with `adjust_frames` or `adjust_datasets` no longer renumbers its inputs. With
  `adjust_datasets`, each input's datasets move past all of the earlier inputs' datasets and
  `n_datasets` is their total; without it, dataset numbers stay as given and `n_datasets` is the
  largest input's, as before.
- `cat_smld` and `merge_smld` refuse cameras that differ in any field, calibration included, and
  return a new SMLD for a single input.
- `physical_to_pixel_index` puts a position in the pixel whose half-open interval holds it, so
  `x = 0` is pixel 1.
- `ROIBatch`: `Adapt.adapt` moves only `data`; invalid arguments throw `ArgumentError` or
  `DimensionMismatch` instead of `AssertionError`.
- SMITE files load with positions and their uncertainties in µm (SMITE stores pixels), and
  `save_smite` writes pixels back, with the camera's `XSize`, `YSize`, `PixelSize` and `NDims`, so
  a saved file loads again. A file without `PixelSize` needs the `pixel_size` keyword.
- A file that 0.7.1's `save_smite` wrote has no `XSize`, `YSize` or `PixelSize`, so the loaders
  refuse it with an `ArgumentError` naming what is missing (0.7.1 could not load it back either).
  Its `X` and `Y` are in µm if the SMLD was built in Julia, but in SMITE pixels if it was loaded
  from a SMITE file, and the file does not say which: adding the missing fields by hand needs to
  know where the data came from.
- Julia 1.10 or later is required (0.7.1 allowed 1.9).
- In printed output, types defined in SMLMCore or SMLMio may show those names
  (`SMLMCore.BasicSMLD`) where 0.7.1 showed `SMLMData.BasicSMLD`.

Results saved with JLD2 under SMLMData 0.7.1 load as they did there, as long as SMLMData is
loaded; JLD2 recorded their types under SMLMData's name. Results saved from 0.7.2 on record
SMLMCore's and SMLMio's names: they load with SMLMData 0.7.2, or with SMLMCore alone when they hold
only SMLMCore's types (a `SmiteSMLD` also needs SMLMio), but not with SMLMData 0.7.1.

## Moving to SMLMCore and SMLMio

New code can depend on SMLMCore, or on SMLMio for SMITE files, directly; most packages need only
SMLMCore's types and so stop loading the MATLAB file reader. The types are identical, so the
change is a dependency swap. SMLMCore and SMLMio cannot be installed beside SMLMData 0.7.1 or
earlier (which defined its own copies of the types); with SMLMData 0.7.2 they install together.

## Documentation

- [SMLMData docs](https://JuliaSMLM.github.io/SMLMData.jl/stable): this page and the container's API.
- `SMLMData.api_overview()`: an overview of the whole API as a `String`, for readers and language
  models.
