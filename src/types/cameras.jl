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
    compute_edges_1d(centers::AbstractUnitRange, pixel_size::Real)

Compute pixel edges in physical units (microns) for a given range of pixel centers and pixel size.

# Arguments
- `centers::AbstractUnitRange`: Range of pixel center indices (typically 1:N)
- `pixel_size::Real`: Size of pixels in microns

# Returns
Vector{Float64}: Edge positions in physical units (microns)

Note: Returns N+1 edges for N pixels, with edges positioned half a pixel before 
first center and half a pixel after last center.
"""
function compute_edges_1d(centers::AbstractUnitRange, pixel_size::Real)
    # Convert first and last center positions to physical coordinates
    first_center = pixel_to_physical(first(centers), 1, pixel_size)[1]
    last_center = pixel_to_physical(last(centers), 1, pixel_size)[1]
    
    # Create edge array extending half a pixel beyond centers
    edges = range(first_center - pixel_size/2, last_center + pixel_size/2, 
                 length=length(centers) + 1)
    
    return collect(edges)
end

"""
    compute_bin_edges(centers_x::AbstractUnitRange, centers_y::AbstractUnitRange, pixel_size::Real)

Compute pixel edges in both dimensions for square pixels.

# Arguments
- `centers_x::AbstractUnitRange`: Range of pixel center indices in x
- `centers_y::AbstractUnitRange`: Range of pixel center indices in y
- `pixel_size::Real`: Size of pixels in microns

# Returns
Tuple{Vector{Float64}, Vector{Float64}}: (edges_x, edges_y) in physical units (microns)
"""
function compute_bin_edges(centers_x::AbstractUnitRange, centers_y::AbstractUnitRange, pixel_size::Real)
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
    IdealCamera(pixel_centers_x::AbstractUnitRange, pixel_centers_y::AbstractUnitRange, pixel_size::Real)

Construct an IdealCamera with square pixels given pixel center positions and a scalar pixel size.

# Arguments
- `pixel_centers_x::AbstractUnitRange`: Range of pixel center indices in x (typically 1:N)
- `pixel_centers_y::AbstractUnitRange`: Range of pixel center indices in y (typically 1:M)
- `pixel_size::Real`: Size of pixels in microns

# Returns
IdealCamera: Camera with computed pixel edges

# Example
```julia
# Create a 512x256 camera with 0.1 micron square pixels
cam = IdealCamera(1:512, 1:256, 0.1)
```
"""
function IdealCamera(pixel_centers_x::AbstractUnitRange, pixel_centers_y::AbstractUnitRange, pixel_size::Real)
    T = promote_type(typeof(pixel_size), Float64)
    edges_x, edges_y = compute_bin_edges(pixel_centers_x, pixel_centers_y, pixel_size)
    return IdealCamera{T}(edges_x, edges_y)
end

"""
    IdealCamera(pixel_centers_x::AbstractUnitRange, pixel_centers_y::AbstractUnitRange, pixel_size::Tuple{Real, Real})

Construct an IdealCamera with rectangular pixels given pixel center positions and x,y pixel sizes.

# Arguments
- `pixel_centers_x::AbstractUnitRange`: Range of pixel center indices in x (typically 1:N)
- `pixel_centers_y::AbstractUnitRange`: Range of pixel center indices in y (typically 1:M)
- `pixel_size::Tuple{Real, Real}`: Tuple of (x_size, y_size) in microns

# Returns
IdealCamera: Camera with computed pixel edges

# Example
```julia
# Create a 512x256 camera with rectangular pixels (0.1 x 0.15 microns)
cam = IdealCamera(1:512, 1:256, (0.1, 0.15))
```
"""
function IdealCamera(pixel_centers_x::AbstractUnitRange, pixel_centers_y::AbstractUnitRange, pixel_size::Tuple{Real, Real})
    T = promote_type(typeof(pixel_size[1]), typeof(pixel_size[2]), Float64)
    edges_x, edges_y = compute_bin_edges(pixel_centers_x, pixel_centers_y, pixel_size)
    return IdealCamera{T}(edges_x, edges_y)
end