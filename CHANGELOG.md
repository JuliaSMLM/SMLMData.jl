# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- SMLMData is now a container: its code moved, with its git history, to
  [SMLMCore](https://github.com/JuliaSMLM/SMLMCore.jl) (types, coordinates, filters, operations)
  and [SMLMio](https://github.com/JuliaSMLM/SMLMio.jl) (SMITE files). SMLMData loads both and
  exports the same names as 0.7.1, each the owning package's own object, so code using SMLMData,
  SMLMCore or SMLMio shares one copy of every type.
- Requires Julia 1.10 or later (0.7.1 allowed 1.9), SMLMCore 0.1 and SMLMio 0.1. MAT, Adapt and
  StaticArrays are no longer direct dependencies.
- `SMLMData.api_overview()` returns a short overview of the container followed by SMLMCore's.
- Types print with their owning module's name (`SMLMCore.BasicSMLD`) where a module is shown.

### Fixed
Fixed in SMLMCore 0.1.0 and SMLMio 0.1.0, and so in SMLMData; their changelogs give every case:
- `merge_smld` with `adjust_frames` or `adjust_datasets` no longer changes its inputs' emitters;
  with `adjust_datasets` it moves each input's datasets past the earlier inputs' total
  `n_datasets` and reports that total.
- `cat_smld` and `merge_smld` refuse cameras that differ in any field, calibration included, and
  return a new SMLD for one input.
- `physical_to_pixel_index` returns the pixel whose half-open interval holds the position, so
  `x = 0` is in pixel 1; `physical_to_pixel` keeps Float32 input as Float32.
- `Adapt.adapt` on an `ROIBatch` moves only `data`; invalid arguments throw `ArgumentError` or
  `DimensionMismatch` instead of `AssertionError`.
- `load_smite_2d` and `load_smite_3d` convert SMITE's pixel positions and uncertainties to µm,
  load files whose optional fields are per dataset or empty, need `pixel_size` for a file without
  `PixelSize`, and no longer require `ZSize`; `save_smite` writes pixels and the camera's size, so
  its files load again, and takes any `AbstractSMLD`. Files that 0.7.1's `save_smite` wrote have
  no `XSize`, `YSize` or `PixelSize` and are refused with an `ArgumentError` (0.7.1 could not
  load them back either); their `X` and `Y` are µm if the SMLD was built in Julia and SMITE
  pixels if it came from a SMITE file.

### Removed
- Internal names that 0.7.1 defined but did not export (`SMLMData.MAT`, `SMLMData.Adapt`,
  `is_same_camera`, `format_with_commas` and other helpers) are gone; no exported name changed.

## [0.4.0] - 2025-01-13

### Added
- **SCMOSCamera type** for sCMOS camera support with pixel-dependent calibration parameters
  - `offset`: Dark level in ADU (scalar or per-pixel matrix)
  - `gain`: Conversion gain in e⁻/ADU (scalar or per-pixel matrix)
  - `readnoise`: Read noise in e⁻ rms (scalar or per-pixel matrix)
  - `qe`: Quantum efficiency 0-1 (scalar or per-pixel matrix)
  - Units match camera specification sheets for easy parameterization
  - Supports mixed scalar and matrix parameters for flexible calibration
  - Two constructor forms: `(nx, ny, pixel_size, readnoise; kwargs...)` and `(edges_x, edges_y; kwargs...)`
- Accessor functions for SCMOSCamera parameters: `get_offset`, `get_gain`, `get_readnoise`, `get_qe`, `get_readnoise_var`
- Custom display methods showing parameter types (uniform vs per-pixel)
- Comprehensive test suite with 91 new tests covering:
  - Scalar and matrix parameter construction
  - Type stability (Float32/Float64)
  - Dimension validation
  - Accessor functions
  - Realistic use cases (ORCA-Flash4.0, ORCA-Quest specifications)

### Changed
- Updated type hierarchy documentation to include SCMOSCamera
- Enhanced README.md with SCMOSCamera examples
- Expanded api_overview.md with detailed SCMOSCamera usage patterns
- Version bumped to 0.4.0 (minor version for backward-compatible new feature)

### Notes
- No breaking changes - purely additive feature
- IdealCamera remains the default for Poisson-only noise models
- SCMOSCamera designed for compatibility with future SMLMCamera.jl calibration package

## [0.3.1] - Previous releases

See git history for earlier changes.

[Unreleased]: https://github.com/JuliaSMLM/SMLMData.jl/compare/v0.7.1...HEAD
[0.4.0]: https://github.com/JuliaSMLM/SMLMData.jl/releases/tag/v0.4.0
