# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

SMLMData.jl is a Julia package for handling Single Molecule Localization Microscopy (SMLM) data. It provides types for representing fluorophore localizations, camera geometries, and complete SMLM datasets, along with tools for coordinate conversion, filtering, and I/O operations.

## Development Commands

### Running Tests
```bash
# Full test suite
julia --project=. -e 'using Pkg; Pkg.test()'

# Direct test execution
julia --project=. test/runtests.jl

# Single test file
julia --project=. test/test_emitters.jl
```

### Building Documentation
```bash
# Build and open documentation
julia dev/build_docs.jl
```

### Package Management
```bash
# Install dependencies
julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Update dependencies
julia --project=. -e 'using Pkg; Pkg.update()'
```

## Architecture

### Type Hierarchy
- **Abstract Types**: `AbstractEmitter`, `AbstractCamera`, `SMLD` define interfaces
- **Emitter Types**: `Emitter2D`, `Emitter3D`, `Emitter2DFit`, `Emitter3DFit` represent localizations
- **Container Types**: `BasicSMLD`, `SmiteSMLD` store collections of emitters
- **Camera Types**: `IdealCamera` defines pixel-to-physical coordinate mapping

### Core Modules
1. **Coordinates** (`src/core/coordinates.jl`): Conversions between pixel and physical coordinates
2. **Filters** (`src/core/filters.jl`): `@filter` macro and spatial/temporal selection functions
3. **Operations** (`src/core/operations.jl`): Dataset concatenation and merging
4. **I/O** (`src/io/smite/`): SMITE format support for MATLAB interoperability

### Key Design Patterns
- All spatial coordinates are in microns
- Parametric types `{T}` for numeric precision flexibility
- Immutable structs for basic types, mutable for fit results
- Operations return new SMLD objects (functional style)
- Macro-based filtering syntax for intuitive API

### Testing Structure
Tests are organized by component in separate files:
- `test_emitters.jl`: Emitter type tests
- `test_cameras.jl`: Camera and coordinate tests
- `test_smld.jl`: Container type tests
- `test_filters.jl`: Filtering functionality
- `test_operations.jl`: Dataset operations
- `test_smite.jl`: SMITE format I/O

All tests use `@testset` blocks for organization and run via `runtests.jl`.