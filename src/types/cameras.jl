"""
    AbstractCamera

Abstract base type for all camera implementations in single molecule localization microscopy (SMLM).

# Interface Requirements

Any concrete subtype of AbstractCamera must provide:

1. Field Requirements:
   - `pixel_edges_x::Vector{<:Real}`: Vector of pixel edge positions in x direction
   - `pixel_edges_y::Vector{<:Real}`: Vector of pixel edge positions in y direction

2. Units:
   - All edge positions must be in physical units (microns)
   - Origin (0,0) corresponds to the top-left corner of the camera
   - For a camera with N×M pixels, there will be N+1 x-edges and M+1 y-edges

3. Coordinate Convention:
   - Pixel (1,1) is centered at (pixel_size_x/2, pixel_size_y/2) microns
   - Edge positions define the boundaries of pixels in physical space
   - First edge position corresponds to the left/top edge of the first pixel
   - Last edge position corresponds to the right/bottom edge of the last pixel

# Notes
- Edge positions must be monotonically increasing
- The number of edges must be one more than the number of pixels in each dimension
- While pixels are typically uniform in size, this is not a requirement of the interface
"""
abstract type AbstractCamera end

"""
    compute_edges_1d(centers::AbstractUnitRange, pixel_size::T) where T<:Real

Compute pixel edges in one dimension. Maintains the numeric type of pixel_size.
The first edge starts at 0 and each pixel has width pixel_size.

# Arguments
- `centers::AbstractUnitRange`: Range of pixel center indices
- `pixel_size::T`: Size of pixels in microns

# Returns
Vector{T}: Edge positions in physical units (microns), starting at 0
"""
function compute_edges_1d(centers::AbstractUnitRange, pixel_size::T) where T<:Real
    n_centers = length(centers)
    edges = Vector{T}(undef, n_centers + 1)
    
    # First edge starts at 0
    edges[1] = zero(T)
    
    # Each subsequent edge is one pixel_size further
    for i in 1:n_centers
        edges[i + 1] = T(i) * pixel_size
    end
    
    return edges
end

"""
    compute_bin_edges(centers_x::AbstractUnitRange, centers_y::AbstractUnitRange, pixel_size::T) where T

Compute pixel edges in both dimensions. Returns vectors with same type as pixel_size.
"""
function compute_bin_edges(centers_x::AbstractUnitRange, centers_y::AbstractUnitRange, pixel_size::T) where T
    edges_x = compute_edges_1d(centers_x, pixel_size)
    edges_y = compute_edges_1d(centers_y, pixel_size)
    return edges_x, edges_y
end

"""
    compute_bin_edges(centers_x::AbstractUnitRange, centers_y::AbstractUnitRange, pixel_size::Tuple{Real, Real})

Compute pixel edges in both dimensions for rectangular pixels.

# Arguments
- `centers_x::AbstractUnitRange`: Range of pixel center indices in x
- `centers_y::AbstractUnitRange`: Range of pixel center indices in y
- `pixel_size::Tuple{Real, Real}`: Tuple of (x_size, y_size) in microns

# Returns
Tuple{Vector{Float64}, Vector{Float64}}: (edges_x, edges_y) in physical units (microns)
"""
function compute_bin_edges(centers_x::AbstractUnitRange, centers_y::AbstractUnitRange, pixel_size::Tuple{Real, Real})
    edges_x = compute_edges_1d(centers_x, pixel_size[1])
    edges_y = compute_edges_1d(centers_y, pixel_size[2])
    return edges_x, edges_y
end

"""
    IdealCamera{T} <: AbstractCamera

Represents an ideal camera with regularly spaced pixels defined by their edges in physical units (microns).

# Fields
- `pixel_edges_x::Vector{T}`: Physical positions of pixel edges in x direction (microns)
- `pixel_edges_y::Vector{T}`: Physical positions of pixel edges in y direction (microns)

The edges are computed from pixel centers, where pixel (1,1) is centered at 
(pixel_size_x/2, pixel_size_y/2) in physical coordinates.
"""
struct IdealCamera{T} <: AbstractCamera
    pixel_edges_x::Vector{T}  # pixel edges in x
    pixel_edges_y::Vector{T}  # pixel edges in y
end

"""
    IdealCamera(pixel_centers_x::AbstractUnitRange, pixel_centers_y::AbstractUnitRange, pixel_size::T) where T<:Real

Construct an IdealCamera with square pixels given pixel center positions and a scalar pixel size.

# Arguments
- `pixel_centers_x::AbstractUnitRange`: Range of pixel center indices in x (typically 1:N)
- `pixel_centers_y::AbstractUnitRange`: Range of pixel center indices in y (typically 1:M)
- `pixel_size::Real`: Size of pixels in microns

# Returns
IdealCamera{T} where T matches the type of pixel_size

# Type Parameters
- `T`: Numeric type for all spatial measurements (e.g., Float64, Float32)

# Example
```julia
# Create a 512x512 camera with 0.1 micron square pixels
cam = IdealCamera(1:512, 1:512, 0.1)

# Create with Float32 precision
cam32 = IdealCamera(1:512, 1:512, 0.1f0)
```

Note: Pixel (1,1) is centered at (pixel_size/2, pixel_size/2) in physical coordinates.
"""
function IdealCamera(pixel_centers_x::AbstractUnitRange, 
                    pixel_centers_y::AbstractUnitRange, 
                    pixel_size::T) where T<:Real
    edges_x, edges_y = compute_bin_edges(pixel_centers_x, pixel_centers_y, pixel_size)
    return IdealCamera{T}(edges_x, edges_y)
end

"""
    IdealCamera(pixel_centers_x::AbstractUnitRange, pixel_centers_y::AbstractUnitRange, 
                pixel_size::Tuple{T, T}) where T<:Real

Construct an IdealCamera with rectangular pixels given pixel center positions and x,y pixel sizes.

# Arguments
- `pixel_centers_x::AbstractUnitRange`: Range of pixel center indices in x (typically 1:N)
- `pixel_centers_y::AbstractUnitRange`: Range of pixel center indices in y (typically 1:M)
- `pixel_size::Tuple{T, T}`: Tuple of (x_size, y_size) in microns

# Returns
IdealCamera{T} where T matches the type of the pixel sizes

# Type Parameters
- `T`: Numeric type for all spatial measurements (e.g., Float64, Float32)

# Example
```julia
# Create a 512x256 camera with rectangular pixels (0.1 x 0.15 microns)
cam = IdealCamera(1:512, 1:256, (0.1, 0.15))

# Create with Float32 precision
cam32 = IdealCamera(1:512, 1:256, (0.1f0, 0.15f0))
```

Note: Pixel (1,1) is centered at (pixel_size[1]/2, pixel_size[2]/2) in physical coordinates.
"""
function IdealCamera(pixel_centers_x::AbstractUnitRange,
                    pixel_centers_y::AbstractUnitRange,
                    pixel_size::Tuple{T, T}) where T<:Real
    edges_x = compute_edges_1d(pixel_centers_x, pixel_size[1])
    edges_y = compute_edges_1d(pixel_centers_y, pixel_size[2])
    return IdealCamera{T}(edges_x, edges_y)
end

"""
    IdealCamera(n_pixels_x::Integer, n_pixels_y::Integer, pixel_size::T) where T<:Real

Construct an IdealCamera with square pixels directly from the number of pixels and pixel size.

# Arguments
- `n_pixels_x::Integer`: Number of pixels in x dimension
- `n_pixels_y::Integer`: Number of pixels in y dimension
- `pixel_size::Real`: Size of pixels in microns

# Returns
IdealCamera{T} where T matches the type of pixel_size

# Example
```julia
# Create a 512x512 camera with 0.1 micron square pixels
cam = IdealCamera(512, 512, 0.1)

# Create with Float32 precision
cam32 = IdealCamera(512, 512, 0.1f0)
```
"""
function IdealCamera(n_pixels_x::Integer, n_pixels_y::Integer, pixel_size::T) where T<:Real
    pixel_centers_x = 1:n_pixels_x
    pixel_centers_y = 1:n_pixels_y
    return IdealCamera(pixel_centers_x, pixel_centers_y, pixel_size)
end

"""
    IdealCamera(n_pixels_x::Integer, n_pixels_y::Integer, pixel_size::Tuple{T, T}) where T<:Real

Construct an IdealCamera with rectangular pixels directly from the number of pixels and x,y pixel sizes.

# Arguments
- `n_pixels_x::Integer`: Number of pixels in x dimension
- `n_pixels_y::Integer`: Number of pixels in y dimension
- `pixel_size::Tuple{T, T}`: Tuple of (x_size, y_size) in microns

# Returns
IdealCamera{T} where T matches the type of the pixel sizes

# Example
```julia
# Create a 512x256 camera with rectangular pixels (0.1 x 0.15 microns)
cam = IdealCamera(512, 256, (0.1, 0.15))

# Create with Float32 precision
cam32 = IdealCamera(512, 256, (0.1f0, 0.15f0))
```
"""
function IdealCamera(n_pixels_x::Integer, n_pixels_y::Integer, pixel_size::Tuple{T, T}) where T<:Real
    pixel_centers_x = 1:n_pixels_x
    pixel_centers_y = 1:n_pixels_y
    return IdealCamera(pixel_centers_x, pixel_centers_y, pixel_size)
end


# Standard show method (used in arrays and collections)
function Base.show(io::IO, camera::IdealCamera{T}) where T
    n_pixels_x = length(camera.pixel_edges_x) - 1
    n_pixels_y = length(camera.pixel_edges_y) - 1
    pixel_size_x = round(camera.pixel_edges_x[2] - camera.pixel_edges_x[1], digits=4)
    pixel_size_y = round(camera.pixel_edges_y[2] - camera.pixel_edges_y[1], digits=4)
    
    if pixel_size_x ≈ pixel_size_y
        print(io, "IdealCamera{$T}($(n_pixels_x)×$(n_pixels_y), $(pixel_size_x)μm)")
    else
        print(io, "IdealCamera{$T}($(n_pixels_x)×$(n_pixels_y), $(pixel_size_x)×$(pixel_size_y)μm)")
    end
end

# Detailed show method (used at REPL and when explicitly showing)
function Base.show(io::IO, ::MIME"text/plain", camera::IdealCamera{T}) where T
    n_pixels_x = length(camera.pixel_edges_x) - 1
    n_pixels_y = length(camera.pixel_edges_y) - 1
    pixel_size_x = round(camera.pixel_edges_x[2] - camera.pixel_edges_x[1], digits=4)
    pixel_size_y = round(camera.pixel_edges_y[2] - camera.pixel_edges_y[1], digits=4)
    
    x_size = round(camera.pixel_edges_x[end] - camera.pixel_edges_x[1], digits=2)
    y_size = round(camera.pixel_edges_y[end] - camera.pixel_edges_y[1], digits=2)
    
    println(io, "IdealCamera{$T} with:")
    println(io, "  Dimensions: $(n_pixels_x) × $(n_pixels_y) pixels")
    
    if pixel_size_x ≈ pixel_size_y
        println(io, "  Pixel size: $(pixel_size_x) μm")
    else
        println(io, "  Pixel size: $(pixel_size_x) × $(pixel_size_y) μm")
    end
    
    print(io, "  Field of view: $(x_size) × $(y_size) μm")
end

"""
    SCMOSCamera{T<:Real} <: AbstractCamera

sCMOS camera with pixel-dependent calibration parameters matching spec sheets.

# Fields
- `pixel_edges_x::Vector{T}`: Physical pixel edges in x (μm)
- `pixel_edges_y::Vector{T}`: Physical pixel edges in y (μm)
- `offset::Union{T, Matrix{T}}`: Dark level (ADU)
- `gain::Union{T, Matrix{T}}`: Conversion gain (e⁻/ADU)
- `readnoise::Union{T, Matrix{T}}`: Read noise (e⁻ rms)
- `qe::Union{T, Matrix{T}}`: Quantum efficiency (0-1)

# Units

Calibration parameters follow camera specification sheet conventions:

- **offset**: ADU (analog-to-digital units)
  - Typical values: 100-500 ADU
  - Dark level with no illumination

- **gain**: e⁻/ADU (electrons per ADU)
  - Typical values: 0.1-2.0 e⁻/ADU depending on readout mode
  - Example: ORCA-Flash4.0: 0.46 e⁻/ADU (12-bit), 0.11 e⁻/ADU (16-bit)

- **readnoise**: e⁻ rms (electrons, root-mean-square)
  - Typical values: 0.3-5.0 e⁻ rms
  - Example: ORCA-Flash4.0 V3: 1.6 e⁻ rms
  - Example: ORCA-Quest qCMOS: 0.27 e⁻ rms

- **qe**: dimensionless (0 to 1)
  - Typical values: 0.5-0.95 at peak wavelength
  - Example: ORCA-Flash4.0 V2: 0.72 at 550nm
  - Example: ORCA-Fusion BT: 0.95 (back-thinned)

# Physical Signal Chain

Photons → Electrons → ADU:
```
Incident photons (N)
  ↓ [× QE]
Photoelectrons (N × QE)
  ↓ [+ readnoise (Gaussian)]
Signal electrons (N × QE + ε), where ε ~ N(0, readnoise²)
  ↓ [÷ gain, + offset]
ADU readout = (N × QE + ε)/gain + offset
```

# Scalar vs Matrix Parameters

Each calibration parameter can be:
- **Scalar** (T): Uniform across sensor (approximation or post-calibration)
- **Matrix** (Matrix{T}): Per-pixel calibration map (size must match pixel grid)

Use matrices for:
- Precision SMLM (2-5% variations can affect results)
- Quantitative imaging
- Artifact correction

Use scalars for:
- Quick analysis
- Post-calibrated data
- Uniform approximation

# Constructors

```julia
# Minimal - most common case (requires readnoise, others default to 0, 1, 1)
cam = SCMOSCamera(512, 512, 0.1, 1.6)

# With additional parameters
cam = SCMOSCamera(512, 512, 0.1, readnoise_map,
                  offset=100.0, gain=0.46, qe=0.72)

# Custom edges (advanced)
cam = SCMOSCamera(custom_edges_x, custom_edges_y,
                  readnoise=noise_map, gain=gain_map)
```

# Examples

```julia
# Example 1: From spec sheet (ORCA-Flash4.0 V3, 12-bit mode)
cam = SCMOSCamera(
    2048, 2048, 0.065,  # 2048×2048 pixels, 65nm pixel size
    1.6,                 # From spec: 1.6 e⁻ rms readnoise
    offset = 100.0,      # Typical offset
    gain = 0.46,         # From spec: 0.46 e⁻/ADU
    qe = 0.72            # 72% QE at 550nm
)

# Example 2: With calibration maps (precision SMLM)
readnoise_map = load("camera_noise.mat")  # 512×512 measured values
gain_map = load("camera_gain.mat")
qe_map = load("camera_qe.mat")

cam = SCMOSCamera(
    512, 512, 0.1, readnoise_map,
    gain = gain_map,
    qe = qe_map
)

# Example 3: Minimal (variance-only approximation)
# Common when you only have noise map, assume ideal otherwise
cam = SCMOSCamera(512, 512, 0.1, readnoise_map)

# Example 4: Ultra-low noise camera (ORCA-Quest)
cam = SCMOSCamera(
    2304, 4096, 0.0044,  # 4.4μm pixels
    0.27,                 # Incredible 0.27 e⁻ rms!
    offset = 100.0,
    gain = 0.5,
    qe = 0.85
)

# Example 5: Rectangular pixels
cam = SCMOSCamera(512, 256, (0.1, 0.15), 1.8)

# Example 6: Mixed scalar/matrix parameters
cam = SCMOSCamera(
    512, 512, 0.1, readnoise_map,  # Per-pixel noise
    offset = 100.0,                 # Uniform offset
    gain = 0.5,                     # Uniform gain
    qe = qe_map                     # Per-pixel QE
)
```

# See Also
[`IdealCamera`](@ref) for Poisson-only noise (readnoise=0)
"""
struct SCMOSCamera{T<:Real} <: AbstractCamera
    pixel_edges_x::Vector{T}
    pixel_edges_y::Vector{T}
    offset::Union{T, Matrix{T}}
    gain::Union{T, Matrix{T}}
    readnoise::Union{T, Matrix{T}}
    qe::Union{T, Matrix{T}}
end

"""
    SCMOSCamera(nx, ny, pixel_size, readnoise; offset=0, gain=1, qe=1)

Construct sCMOS camera from pixel dimensions and calibration parameters.

# Arguments
- `nx::Integer`: Number of pixels in x
- `ny::Integer`: Number of pixels in y
- `pixel_size::Union{T, Tuple{T,T}}`: Pixel size in μm (scalar or (x_size, y_size))
- `readnoise::Union{T, Matrix{T}}`: Read noise in e⁻ rms (required)

# Keywords
- `offset::Union{T, Matrix{T}} = 0`: Dark level in ADU
- `gain::Union{T, Matrix{T}} = 1`: Conversion gain in e⁻/ADU
- `qe::Union{T, Matrix{T}} = 1`: Quantum efficiency (0-1)

Each parameter can be scalar (uniform) or Matrix{T} with size (nx, ny).

# Examples
```julia
# Minimal: just readnoise (assumes calibrated data: offset=0, gain=1, qe=1)
cam = SCMOSCamera(512, 512, 0.1, 1.6)

# From spec sheet (ORCA-Flash4.0 V3)
cam = SCMOSCamera(2048, 2048, 0.065, 1.6, offset=100.0, gain=0.46, qe=0.72)

# With calibration maps
cam = SCMOSCamera(512, 512, 0.1, readnoise_map,
                  offset=offset_map, gain=gain_map, qe=qe_map)

# Rectangular pixels
cam = SCMOSCamera(512, 256, (0.1, 0.15), 1.8)
```
"""
function SCMOSCamera(
    nx::Integer,
    ny::Integer,
    pixel_size::Union{T, Tuple{T,T}},
    readnoise::Union{T, Matrix{T}};
    offset::Union{T, Matrix{T}} = zero(T),
    gain::Union{T, Matrix{T}} = one(T),
    qe::Union{T, Matrix{T}} = one(T)
) where T<:Real

    # Compute pixel edges
    if pixel_size isa Tuple
        edges_x = collect(range(zero(T), nx * pixel_size[1], length=nx+1))
        edges_y = collect(range(zero(T), ny * pixel_size[2], length=ny+1))
    else
        edges_x = collect(range(zero(T), nx * pixel_size, length=nx+1))
        edges_y = collect(range(zero(T), ny * pixel_size, length=ny+1))
    end

    # Validate dimensions
    _validate_camera_param(offset, nx, ny, "offset")
    _validate_camera_param(gain, nx, ny, "gain")
    _validate_camera_param(readnoise, nx, ny, "readnoise")
    _validate_camera_param(qe, nx, ny, "qe")

    return SCMOSCamera{T}(edges_x, edges_y, offset, gain, readnoise, qe)
end

"""
    SCMOSCamera(pixel_edges_x, pixel_edges_y; offset=0, gain=1, readnoise, qe=1)

Construct sCMOS camera with custom pixel edge positions.

# Arguments
- `pixel_edges_x::Vector{T}`: Pixel edge positions in x (μm), length nx+1
- `pixel_edges_y::Vector{T}`: Pixel edge positions in y (μm), length ny+1

# Keywords
- `readnoise::Union{T, Matrix{T}}`: Read noise in e⁻ rms (required)
- `offset::Union{T, Matrix{T}} = 0`: Dark level in ADU
- `gain::Union{T, Matrix{T}} = 1`: Conversion gain in e⁻/ADU
- `qe::Union{T, Matrix{T}} = 1`: Quantum efficiency (0-1)

Matrix parameters must have size (nx, ny) where nx = length(pixel_edges_x) - 1.

# Example
```julia
# Custom non-uniform pixel grid
edges_x = [0.0, 0.1, 0.21, 0.33, 0.46]  # Non-uniform spacing
edges_y = [0.0, 0.1, 0.2, 0.3]
cam = SCMOSCamera(edges_x, edges_y, readnoise=1.5, gain=0.5)
```
"""
function SCMOSCamera(
    pixel_edges_x::Vector{T},
    pixel_edges_y::Vector{T};
    readnoise::Union{T, Matrix{T}},
    offset::Union{T, Matrix{T}} = zero(T),
    gain::Union{T, Matrix{T}} = one(T),
    qe::Union{T, Matrix{T}} = one(T)
) where T<:Real

    nx = length(pixel_edges_x) - 1
    ny = length(pixel_edges_y) - 1

    # Validate dimensions
    _validate_camera_param(offset, nx, ny, "offset")
    _validate_camera_param(gain, nx, ny, "gain")
    _validate_camera_param(readnoise, nx, ny, "readnoise")
    _validate_camera_param(qe, nx, ny, "qe")

    return SCMOSCamera{T}(pixel_edges_x, pixel_edges_y, offset, gain, readnoise, qe)
end

# Validation helper
function _validate_camera_param(param::AbstractMatrix, nx, ny, name)
    size(param) == (nx, ny) ||
        throw(DimensionMismatch("$name size $(size(param)) must match ($nx, $ny)"))
end
_validate_camera_param(param::Real, nx, ny, name) = nothing

# Display methods
function Base.show(io::IO, cam::SCMOSCamera{T}) where T
    nx = length(cam.pixel_edges_x) - 1
    ny = length(cam.pixel_edges_y) - 1
    px = round(cam.pixel_edges_x[2] - cam.pixel_edges_x[1], digits=4)
    py = round(cam.pixel_edges_y[2] - cam.pixel_edges_y[1], digits=4)

    psize_str = px ≈ py ? "$(px)μm" : "$(px)×$(py)μm"
    print(io, "SCMOSCamera{$T}($(nx)×$(ny), $(psize_str))")
end

function Base.show(io::IO, ::MIME"text/plain", cam::SCMOSCamera{T}) where T
    nx = length(cam.pixel_edges_x) - 1
    ny = length(cam.pixel_edges_y) - 1
    px = round(cam.pixel_edges_x[2] - cam.pixel_edges_x[1], digits=4)
    py = round(cam.pixel_edges_y[2] - cam.pixel_edges_y[1], digits=4)

    println(io, "SCMOSCamera{$T} with:")
    println(io, "  Dimensions: $(nx) × $(ny) pixels")

    if px ≈ py
        println(io, "  Pixel size: $(px) μm")
    else
        println(io, "  Pixel size: $(px) × $(py) μm")
    end

    # Show parameter types (scalar vs matrix)
    offset_type = cam.offset isa T ? "uniform" : "per-pixel"
    gain_type = cam.gain isa T ? "uniform" : "per-pixel"
    readnoise_type = cam.readnoise isa T ? "uniform" : "per-pixel"
    qe_type = cam.qe isa T ? "uniform" : "per-pixel"

    println(io, "  Offset: $(offset_type)")
    println(io, "  Gain: $(gain_type)")
    println(io, "  Read noise: $(readnoise_type)")
    print(io, "  QE: $(qe_type)")
end

