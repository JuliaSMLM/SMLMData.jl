# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/JuliaSMLM/SMLMData.jl/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/JuliaSMLM/SMLMData.jl/releases/tag/v0.4.0
