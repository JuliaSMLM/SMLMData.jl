"""
    @filter(smld, condition)

Filter SMLD emitters using a natural condition syntax.
Transforms expressions at compile time into efficient filtering operations.

# Arguments
- `smld`: SMLD object to filter
- `condition`: Expression defining the filter condition

# Examples
```julia
# Simple conditions
bright = @filter(smld, photons > 1000)
early = @filter(smld, frame < 10)

# Compound conditions
good_fits = @filter(smld, σ_x < 0.02 && σ_y < 0.02)
roi = @filter(smld, 1.0 <= x <= 5.0 && 1.0 <= y <= 5.0)
```
"""
macro filter(smld, expr)
    # Transform the expression into an efficient filter operation
    filter_expr = build_filter_expr(smld, expr)
    return esc(filter_expr)
end

# Helper function to build the optimized filter expression
function build_filter_expr(smld, expr)
    # Convert user expression into an efficient array operation
    # This runs at compile time
    filter_code = quote
        emitters = $(smld).emitters
        keep = similar(emitters, Bool)
        @inbounds for i in eachindex(emitters)
            e = emitters[i]
            keep[i] = $(transform_condition(expr))
        end
        subset_smld($(smld), keep)
    end
    return filter_code
end

# Transform condition expressions
function transform_condition(expr)
    if expr.head == :call
        # Handle basic operations (<, >, ==, etc.)
        op = expr.args[1]
        if length(expr.args) == 3
            # Binary operation
            left = transform_term(expr.args[2])
            right = transform_term(expr.args[3])
            return :($left $op $right)
        end
    elseif expr.head == :&&
        # Handle compound conditions
        left = transform_condition(expr.args[1])
        right = transform_condition(expr.args[2])
        return :($left && $right)
    elseif expr.head == :||
        # Handle OR conditions
        left = transform_condition(expr.args[1])
        right = transform_condition(expr.args[2])
        return :($left || $right)
    elseif expr.head == :comparison
        # Handle range comparisons (a <= x <= b)
        terms = [transform_term(arg) for arg in expr.args[1:2:end]]
        ops = expr.args[2:2:end]
        return Expr(:comparison, terms..., ops...)
    end
    error("Unsupported expression: $expr")
end

# Transform individual terms
function transform_term(term)
    if term isa Symbol
        # Convert field access (e.g., x → e.x)
        return :(e.$term)
    else
        # Keep literals and other expressions as is
        return term
    end
end

"""
    filter_frames(smld::SMLD, frame::Integer)
    filter_frames(smld::SMLD, frames::Union{AbstractVector,AbstractRange})

Efficiently select emitters from specified frames.

# Arguments
- `smld::SMLD`: Input SMLD structure
- `frames`: Single frame number, vector of frame numbers, or range of frames

# Returns
New SMLD containing only emitters from specified frames

# Examples
```julia
# Single frame
frame_5 = filter_frames(smld, 5)

# Range of frames
early = filter_frames(smld, 1:10)

# Multiple specific frames
selected = filter_frames(smld, [1,3,5,7])
```
"""
function filter_frames(smld::SMLD, frame::Integer)
    keep = [e.frame == frame for e in smld.emitters]
    return subset_smld(smld, keep)
end

function filter_frames(smld::SMLD, frames::Union{AbstractVector,AbstractRange})
    frame_set = Set(frames)  # Convert to Set for O(1) lookup
    keep = [e.frame ∈ frame_set for e in smld.emitters]
    return subset_smld(smld, keep)
end

"""
    filter_roi(smld::SMLD, x_range, y_range)
    filter_roi(smld::SMLD, x_range, y_range, z_range)

Efficiently select emitters within a region of interest.

# Arguments
- `smld::SMLD`: Input SMLD structure
- `x_range`: Range or tuple for x coordinates (microns)
- `y_range`: Range or tuple for y coordinates (microns)
- `z_range`: Optional range or tuple for z coordinates (microns)

# Returns
New SMLD containing only emitters within the specified ROI

# Examples
```julia
# 2D ROI
region = filter_roi(smld, 1.0:5.0, 2.0:6.0)
region = filter_roi(smld, (1.0, 5.0), (2.0, 6.0))

# 3D ROI
volume = filter_roi(smld, 1.0:5.0, 2.0:6.0, -1.0:1.0)
```
"""
function filter_roi(smld::SMLD, x_range, y_range)
    x_min, x_max = extrema(x_range)
    y_min, y_max = extrema(y_range)
    
    if eltype(smld.emitters) <: Union{Emitter2D, Emitter2DFit}
        keep = [x_min ≤ e.x ≤ x_max && y_min ≤ e.y ≤ y_max for e in smld.emitters]
        return subset_smld(smld, keep)
    else
        error("2D ROI cannot be applied to 3D emitter type")
    end
end

function filter_roi(smld::SMLD, x_range, y_range, z_range)
    x_min, x_max = extrema(x_range)
    y_min, y_max = extrema(y_range)
    z_min, z_max = extrema(z_range)
    
    if eltype(smld.emitters) <: Union{Emitter3D, Emitter3DFit}
        keep = [x_min ≤ e.x ≤ x_max && 
                y_min ≤ e.y ≤ y_max && 
                z_min ≤ e.z ≤ z_max for e in smld.emitters]
        return subset_smld(smld, keep)
    else
        error("3D ROI cannot be applied to 2D emitter type")
    end
end

# Helper function used by all filters
function subset_smld(smld::SMLD, keep::AbstractVector{Bool})
    return typeof(smld)(
        smld.emitters[keep],
        smld.camera,
        smld.n_frames,
        smld.n_datasets,
        copy(smld.metadata)
    )
end