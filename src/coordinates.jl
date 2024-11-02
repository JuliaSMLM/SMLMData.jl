"""
    pixel_to_physical(px::Real, py::Real, pixel_size::T) where T

Convert pixel coordinates to physical coordinates (in microns).
Returns coordinates with the same type as pixel_size.
"""
function pixel_to_physical(px::Real, py::Real, pixel_size::T) where T
    x_physical = T((px - 0.5) * pixel_size)
    y_physical = T((py - 0.5) * pixel_size)
    return (x_physical, y_physical)
end

"""
    physical_to_pixel(x::Real, y::Real, pixel_size::Real)

Convert physical coordinates (in microns) to pixel coordinates.

# Arguments
- `x::Real`: x coordinate in microns (0,0 is top-left of image)
- `y::Real`: y coordinate in microns (0,0 is top-left of image)
- `pixel_size::Real`: size of a pixel in microns

# Returns
Tuple{Float64, Float64}: (px,py) pixel coordinates where (1,1) is center of top-left pixel

# Example
```julia
# For a camera with 0.1 micron pixels
px, py = physical_to_pixel(0.05, 0.05, 0.1)  # Point 0.05,0.05 microns from origin
# Returns (1.0, 1.0) - center of first pixel
```
"""
function physical_to_pixel(x::Real, y::Real, pixel_size::Real)
    # Convert from physical units to pixel coordinates
    # Add 0.5 to make (0,0) physical correspond to (0.5,0.5) pixel
    px = (x / pixel_size) + 0.5
    py = (y / pixel_size) + 0.5
    
    return (px, py)
end

"""
    physical_to_pixel_index(x::Real, y::Real, pixel_size::Real)

Convert physical coordinates (in microns) to integer pixel indices.
Returns the pixel that contains the given physical coordinate.

# Arguments
- `x::Real`: x coordinate in microns (0,0 is top-left of image)
- `y::Real`: y coordinate in microns (0,0 is top-left of image)
- `pixel_size::Real`: size of a pixel in microns

# Returns
Tuple{Int, Int}: (px,py) pixel indices where (1,1) is top-left pixel

# Example
```julia
# For a camera with 0.1 micron pixels
px, py = physical_to_pixel_index(0.05, 0.05, 0.1)  # Point at center of first pixel
# Returns (1, 1)
```
"""
function physical_to_pixel_index(x::Real, y::Real, pixel_size::Real)
    px, py = physical_to_pixel(x, y, pixel_size)
    return (round(Int, px), round(Int, py))
end

"""
    get_pixel_centers(cam::AbstractCamera)

Calculate the physical coordinates of all pixel centers for any camera type.

For each dimension, the center positions are computed as the midpoint between 
consecutive edge positions. This works for both regular (uniform pixel size) 
and irregular (varying pixel size) cameras.

# Arguments
- `cam::AbstractCamera`: Any camera type that implements the AbstractCamera interface
  with pixel_edges_x and pixel_edges_y fields in physical units (microns)

# Returns
Tuple{Vector, Vector}: (centers_x, centers_y) where each vector contains the physical 
coordinates (in microns) of pixel centers along that dimension

# Example
```julia
# For a 512x512 camera with 0.1 micron pixels
cam = IdealCamera(1:512, 1:512, 0.1)
centers_x, centers_y = get_pixel_centers(cam)

# First pixel center should be at (0.05, 0.05) microns
@assert centers_x[1] ≈ 0.05
@assert centers_y[1] ≈ 0.05
```
"""
function get_pixel_centers(cam::AbstractCamera)
    # Centers are midway between edges
    centers_x = [(cam.pixel_edges_x[i] + cam.pixel_edges_x[i+1])/2 for i in 1:length(cam.pixel_edges_x)-1]
    centers_y = [(cam.pixel_edges_y[i] + cam.pixel_edges_y[i+1])/2 for i in 1:length(cam.pixel_edges_y)-1]
    return centers_x, centers_y
end
