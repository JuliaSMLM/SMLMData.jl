"""
    @filter(smld, condition)

Filter SMLD emitters using a natural condition syntax.
Transforms expressions at compile time into efficient filtering operations.

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
    # Only replace symbols that are emitter fields
    function replace_fields(ex)
        if ex isa Expr
            if ex.head == :(.)  # Already a field access
                return ex
            else
                return Expr(ex.head, map(replace_fields, ex.args)...)
            end
        elseif ex isa Symbol && !(ex in [:&&, :||, :<, :>, :<=, :>=, :(==), :!=, :in, :∈])
            # Convert symbol to field access unless it's an operator
            return :(e.$ex)
        else
            return ex
        end
    end
    
    condition = replace_fields(expr)
    
    return quote
        local emitters = $(esc(smld)).emitters
        local keep = Bool[]
        for e in emitters
            push!(keep, $condition)
        end
        typeof($(esc(smld)))(
            emitters[keep],
            $(esc(smld)).camera,
            $(esc(smld)).n_frames,
            $(esc(smld)).n_datasets,
            copy($(esc(smld)).metadata)
        )
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
    return typeof(smld)(
        smld.emitters[keep],
        smld.camera,
        smld.n_frames,
        smld.n_datasets,
        copy(smld.metadata)
    )
end

function filter_frames(smld::SMLD, frames::Union{AbstractVector,AbstractRange})
    frame_set = Set(frames)  # Convert to Set for O(1) lookup
    keep = [e.frame ∈ frame_set for e in smld.emitters]
    return typeof(smld)(
        smld.emitters[keep],
        smld.camera,
        smld.n_frames,
        smld.n_datasets,
        copy(smld.metadata)
    )
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
        return typeof(smld)(
            smld.emitters[keep],
            smld.camera,
            smld.n_frames,
            smld.n_datasets,
            copy(smld.metadata)
        )
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
        return typeof(smld)(
            smld.emitters[keep],
            smld.camera,
            smld.n_frames,
            smld.n_datasets,
            copy(smld.metadata)
        )
    else
        error("3D ROI cannot be applied to 2D emitter type")
    end
end