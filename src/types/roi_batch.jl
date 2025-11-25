"""
ROI batch data structures for efficient parallel processing of image regions.

These types provide a standardized interface for batched ROI operations across
the JuliaSMLM ecosystem, enabling interoperability between SMLMBoxer, GaussMLE,
and other analysis packages.
"""

using StaticArrays
import Adapt

"""
    SingleROI{T}

Single region of interest (ROI) with location and frame context.

# Fields
- `data::Matrix{T}` - ROI image data (roi_size × roi_size pixels)
- `corner::SVector{2,Int32}` - ROI corner position (x, y) = (col, row) in camera pixels (1-indexed)
- `frame_idx::Int32` - Frame number in image stack (1-indexed)

# Coordinate System
- **Camera coordinates**: 1-indexed, (1,1) is top-left pixel of full image
- **Corner**: (x, y) = (col, row) position where top-left of ROI starts
- **ROI data**: (1,1) is top-left pixel within the ROI itself

# Example
```julia
# Create single ROI
roi_data = rand(Float32, 11, 11)  # 11×11 pixel ROI
roi = SingleROI(roi_data, SVector{2,Int32}(100, 200), Int32(5))

# Access fields
println("ROI at camera position: ", roi.corner)  # (100, 200) = (col, row)
println("From frame: ", roi.frame_idx)  # Frame 5
```
"""
struct SingleROI{T}
    data::Matrix{T}
    corner::SVector{2,Int32}
    frame_idx::Int32
end

# Define eltype for SingleROI
Base.eltype(::Type{SingleROI{T}}) where {T} = T
Base.eltype(::SingleROI{T}) where {T} = T

"""
    ROIBatch{T,N,A,C}

Batch of regions of interest for efficient parallel processing with camera context.

This type serves as the standard interface for ROI-based processing across the
JuliaSMLM ecosystem. ROIs are extracted by SMLMBoxer and consumed by fitting
packages like GaussMLE.

# Type Parameters
- `T`: Element type of ROI data (typically Float32 or Float64)
- `N`: Dimension of data array (always 3 for ROI batches)
- `A`: Array type (e.g., Array, CuArray for GPU)
- `C`: Camera type (AbstractCamera subtype)

# Fields
- `data::A` - ROI image stack (roi_size × roi_size × n_rois)
- `x_corners::Vector{Int32}` - X (column) coordinates of ROI corners in camera coordinates
- `y_corners::Vector{Int32}` - Y (row) coordinates of ROI corners in camera coordinates
- `frame_indices::Vector{Int32}` - Frame number for each ROI (1-indexed)
- `camera::C` - Camera object (IdealCamera or SCMOSCamera) representing full image
- `roi_size::Int` - Size of each ROI in pixels (assumed square)

# Coordinate System
- **Camera coordinates**: 1-indexed, (1,1) = top-left of full image
- **ROI corners**: (x, y) = (col, row) position in camera coordinates
- **ROI data**: Local coordinates, (1,1) = top-left within ROI
- **Frame indices**: 1-indexed, matching camera frame numbering

# Constructors

## From arrays (main constructor)
```julia
ROIBatch(data::AbstractArray{T,3}, x_corners::Vector{Int32}, y_corners::Vector{Int32},
         frame_indices::Vector{Int32}, camera::AbstractCamera)
```

## From separate x/y corner vectors
```julia
ROIBatch(data::AbstractArray{T,3}, x_corners::Vector, y_corners::Vector,
         frame_indices::Vector, camera::AbstractCamera)
```

## From vector of SingleROI
```julia
ROIBatch(rois::Vector{SingleROI{T}}, camera::AbstractCamera)
```

# Validation
- ROIs must be square (data dimensions 1 == dimension 2)
- x_corners must have length n_rois
- y_corners must have length n_rois
- Frame indices must have length n_rois
- All arrays must have consistent n_rois

# Indexing and Iteration
```julia
batch = ROIBatch(data, x_corners, y_corners, frames, camera)

# Get single ROI
roi = batch[5]  # Returns SingleROI{T}

# Iterate over all ROIs
for roi in batch
    process(roi.data, roi.corner, roi.frame_idx)
end

# Length
n = length(batch)  # Number of ROIs
```

# GPU Support
Supports GPU transfer via Adapt.jl (KernelAbstractions.jl):
```julia
using CUDA
batch_gpu = adapt(CuArray, batch)  # Transfer data to GPU
# Camera stays on host (contains metadata)
```

# Example
```julia
using SMLMData
using StaticArrays

# Create camera
camera = IdealCamera(512, 512, 0.1)  # 512×512 pixels, 0.1μm/pixel

# Create ROI batch (e.g., from SMLMBoxer.getboxes)
n_rois = 100
roi_size = 11
data = rand(Float32, roi_size, roi_size, n_rois)
x_corners = rand(Int32(1):Int32(500), n_rois)
y_corners = rand(Int32(1):Int32(500), n_rois)
frames = rand(Int32(1):Int32(10), n_rois)

batch = ROIBatch(data, x_corners, y_corners, frames, camera)

# Access
println("Batch contains \$(length(batch)) ROIs")
first_roi = batch[1]
println("First ROI at position: \$(first_roi.corner)")
```

# See Also
- [`SingleROI`](@ref) - Individual ROI type
- [`IdealCamera`](@ref), [`SCMOSCamera`](@ref) - Camera types
"""
struct ROIBatch{T,N,A<:AbstractArray{T,N},C<:AbstractCamera}
    data::A
    x_corners::Vector{Int32}
    y_corners::Vector{Int32}
    frame_indices::Vector{Int32}
    camera::C
    roi_size::Int

    function ROIBatch(data::A, x_corners::Vector{Int32}, y_corners::Vector{Int32},
                     frame_indices::Vector{Int32}, camera::C) where {T,A<:AbstractArray{T,3},C<:AbstractCamera}
        n_rois = size(data, 3)
        roi_size = size(data, 1)

        # Validation
        @assert size(data, 1) == size(data, 2) "ROIs must be square (got $(size(data, 1))×$(size(data, 2)))"
        @assert length(x_corners) == n_rois "Must have one x_corner per ROI (got $(length(x_corners)) for $n_rois ROIs)"
        @assert length(y_corners) == n_rois "Must have one y_corner per ROI (got $(length(y_corners)) for $n_rois ROIs)"
        @assert length(frame_indices) == n_rois "Must have one frame index per ROI (got $(length(frame_indices)) for $n_rois ROIs)"

        new{T,3,A,C}(data, x_corners, y_corners, frame_indices, camera, roi_size)
    end
end

"""
    ROIBatch(data, x_corners, y_corners, frame_indices, camera)

Construct ROIBatch from separate x and y corner vectors.

# Arguments
- `data::AbstractArray{T,3}` - ROI stack (roi_size × roi_size × n_rois)
- `x_corners::Vector` - X (column) coordinates of ROI corners
- `y_corners::Vector` - Y (row) coordinates of ROI corners
- `frame_indices::Vector` - Frame number for each ROI
- `camera::AbstractCamera` - Camera object for full image

# Example
```julia
batch = ROIBatch(data, x_corners, y_corners, frames, camera)
```
"""
function ROIBatch(data::AbstractArray{T,3}, x_corners::Vector, y_corners::Vector,
                  frame_indices::Vector, camera::C) where {T,C<:AbstractCamera}
    # Convert to Int32 and call inner constructor
    ROIBatch(data, Int32.(x_corners), Int32.(y_corners), Int32.(frame_indices), camera)
end

"""
    ROIBatch(rois::Vector{SingleROI{T}}, camera)

Construct ROIBatch from vector of SingleROI objects.

# Arguments
- `rois::Vector{SingleROI{T}}` - Vector of individual ROIs
- `camera::AbstractCamera` - Camera object for full image

# Returns
ROIBatch{T,3,Array{T,3},typeof(camera)}

# Example
```julia
rois = [SingleROI(rand(Float32, 11, 11), SVector{2,Int32}(i*10, i*10), Int32(i))
        for i in 1:100]
batch = ROIBatch(rois, camera)
```
"""
function ROIBatch(rois::Vector{SingleROI{T}}, camera::C) where {T,C<:AbstractCamera}
    if isempty(rois)
        # Empty batch - use provided camera
        return ROIBatch(zeros(T, 0, 0, 0), Int32[], Int32[], Int32[], camera)
    end

    roi_size = size(first(rois).data, 1)
    n_rois = length(rois)

    # Pre-allocate arrays
    data = Array{T,3}(undef, roi_size, roi_size, n_rois)
    x_corners = Vector{Int32}(undef, n_rois)
    y_corners = Vector{Int32}(undef, n_rois)
    frame_indices = Vector{Int32}(undef, n_rois)

    # Fill arrays
    for (i, roi) in enumerate(rois)
        data[:, :, i] = roi.data
        x_corners[i] = roi.corner[1]
        y_corners[i] = roi.corner[2]
        frame_indices[i] = roi.frame_idx
    end

    ROIBatch(data, x_corners, y_corners, frame_indices, camera)
end

# ===== Indexing and Iteration =====

"""
    getindex(batch::ROIBatch, i::Int) -> SingleROI

Get the i-th ROI from the batch.

Returns a SingleROI containing the data, corner position, and frame index.
"""
Base.getindex(batch::ROIBatch, i::Int) = SingleROI(
    batch.data[:, :, i],
    SVector{2,Int32}(batch.x_corners[i], batch.y_corners[i]),
    batch.frame_indices[i]
)

"""
    length(batch::ROIBatch) -> Int

Number of ROIs in the batch.
"""
Base.length(batch::ROIBatch) = size(batch.data, 3)

"""
    size(batch::ROIBatch) -> Tuple{Int}

Size of the batch (returns tuple for consistency with iteration protocol).
"""
Base.size(batch::ROIBatch) = (length(batch),)

"""
    iterate(batch::ROIBatch, [state]) -> Union{Nothing, Tuple{SingleROI, Int}}

Iterate over ROIs in the batch.

# Example
```julia
for roi in batch
    println("Processing ROI at ", roi.corner)
end
```
"""
Base.iterate(batch::ROIBatch, state=1) = state > length(batch) ? nothing : (batch[state], state + 1)

# ===== GPU Adaptation =====

"""
    Adapt.adapt_structure(to, batch::ROIBatch)

Adapt ROIBatch for GPU execution via KernelAbstractions.jl/CUDA.jl.

Transfers data, x_corners, y_corners, and frame_indices to the target device.
Camera remains on the host (contains metadata and variance maps).

# Example
```julia
using CUDA
batch_gpu = adapt(CuArray, batch)
# Process on GPU...
batch_cpu = adapt(Array, batch_gpu)  # Transfer back
```
"""
function Adapt.adapt_structure(to, batch::ROIBatch)
    ROIBatch(
        Adapt.adapt(to, batch.data),
        Adapt.adapt(to, batch.x_corners),
        Adapt.adapt(to, batch.y_corners),
        Adapt.adapt(to, batch.frame_indices),
        batch.camera  # Camera stays on host
    )
end

# ===== Display Methods =====

"""
    show(io::IO, roi::SingleROI)

Compact display of SingleROI.
"""
function Base.show(io::IO, roi::SingleROI{T}) where T
    print(io, "SingleROI{$T}($(size(roi.data, 1))×$(size(roi.data, 2)), ")
    print(io, "corner=($(roi.corner[1]), $(roi.corner[2])), ")
    print(io, "frame=$(roi.frame_idx))")
end

"""
    show(io::IO, ::MIME"text/plain", roi::SingleROI)

Detailed display of SingleROI.
"""
function Base.show(io::IO, ::MIME"text/plain", roi::SingleROI{T}) where T
    println(io, "SingleROI{$T}:")
    println(io, "  Size: $(size(roi.data, 1)) × $(size(roi.data, 2)) pixels")
    println(io, "  Corner: ($(roi.corner[1]), $(roi.corner[2])) = (col, row)")
    print(io, "  Frame: $(roi.frame_idx)")
end

"""
    show(io::IO, batch::ROIBatch)

Compact display of ROIBatch.
"""
function Base.show(io::IO, batch::ROIBatch{T}) where T
    n_rois = length(batch)
    print(io, "ROIBatch{$T}($(batch.roi_size)×$(batch.roi_size), $n_rois ROIs)")
end

"""
    show(io::IO, ::MIME"text/plain", batch::ROIBatch)

Detailed display of ROIBatch.
"""
function Base.show(io::IO, ::MIME"text/plain", batch::ROIBatch{T,N,A,C}) where {T,N,A,C}
    n_rois = length(batch)

    println(io, "ROIBatch{$T} with:")
    println(io, "  ROI size: $(batch.roi_size) × $(batch.roi_size) pixels")
    println(io, "  Number of ROIs: $n_rois")
    println(io, "  Data type: $A")
    println(io, "  Camera: $C")

    if n_rois > 0
        # Frame statistics
        frame_range = extrema(batch.frame_indices)
        n_frames = frame_range[2] - frame_range[1] + 1
        println(io, "  Frames: $(frame_range[1]) to $(frame_range[2]) (spanning $n_frames frames)")

        # Corner statistics
        x_range = extrema(batch.x_corners)
        y_range = extrema(batch.y_corners)
        print(io, "  Corner range: x=$(x_range[1]) to $(x_range[2]), y=$(y_range[1]) to $(y_range[2])")
    end
end
