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

