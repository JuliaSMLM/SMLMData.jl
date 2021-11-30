using Base
using Distributions
using StatsBase

# This file contains functions/methods related to images/image generation.

"""
    contraststretch!(image::Matrix{Float64};
                     minval::Float64 = 0.0, maxval::Float64 = 1.0)

Stretch the histogram of `image` to fill the range `minval` to `maxval`.

# Inputs
-`image`: Image to be contrast stretched.
-`minval`: Minimum value of pixels in `image` once stretched.
-`maxval`: Maximum value of pixels in `image` once stretched.
"""
function contraststretch!(image::Matrix{Float64};
    minval::Float64 = 0.0, maxval::Float64 = 1.0)
    # Stretch the image to the range [0.0, 1.0].
    image .-= StatsBase.minimum(image)
    image ./= StatsBase.maximum(image)
    image = (maxval - minval) * image .+ minval

    return image
end

"""
    outimage = contraststretch(image::Matrix{Float64};
                            minval::Float64 = 0.0, maxval::Float64 = 1.0)

Stretch the histogram of `image` to fill the range `minval` to `maxval`.

# Inputs
-`image`: Image to be contrast stretched.
-`minval`: Minimum value of pixels in `image` once stretched.
-`maxval`: Maximum value of pixels in `image` once stretched.

# Outputs
-`outimage`: Contrast stretched copy of input `image`.
"""
function contraststretch(image::Matrix{Float64};
    minval::Float64 = 0.0, maxval::Float64 = 1.0)
    return SMLMData.contraststretch!(deepcopy(image);
        minval = minval, maxval = maxval)
end

"""
    image = makegaussim(μ::Matrix{Float64},
                        σ_μ::Matrix{Float64}, 
                        datasize::Vector{Int};
                        mag::Float64 = 20.0, 
                        nsigma::Float64 = 5.0)

Make a Gaussian image of the localizations in `μ`.

# Description
This function creates an image of the localizations defined by `μ` and `σ_μ`
in which Gaussians with standard deviations `σ_μ` are added at positions `μ`.

# Inputs
-`μ`: Positions of the Gaussians. (pixels)([y x])
-`σ_μ`: Standard errors of `μ` estimates. (pixels)([y x])
-`datasize`: Size of the region of data collection. (pixels)([y; x])
-`mag`: Approximate magnfication from data coordinates to SR coordinates. 
        (Default = 20.0)
-`nsigma`: Number of standard deviations from the localization coordinate at
           which we truncate the Gaussian. (Default = 5.0)

# Outputs
-`image`: Matrix{Float64} Gaussian image in which each localization in `smld`
          is plotted as a Gaussian.
"""
function makegaussim(μ::Matrix{Float64},
    σ_μ::Matrix{Float64},
    datasize::Vector{Int};
    mag::Float64 = 20.0,
    nsigma::Float64 = 5.0)
    # Loop through emitters and add them to our output Gaussian image.
    imagesize = Int.(round.(datasize * mag))
    image = zeros(Float64, imagesize[1], imagesize[2])
    for nn = 1:size(μ, 1)
        # Prepare a normal distribution for this emitter.
        if !all(σ_μ[nn, :] .> 0.0)
            continue
        end
        Σ = [σ_μ[nn, 1]^2 0.0; 0.0 σ_μ[nn, 2]^2]
        distrib = Distributions.MvNormal(μ[nn, :], Σ)

        # Loop through pixels of the image and add this emitter.
        ystart = max(1,
            Int(round(mag * (μ[nn, 1] - nsigma * σ_μ[nn, 2] - 0.5))))
        yend = min(imagesize[1],
            Int(round(mag * (μ[nn, 1] + nsigma * σ_μ[nn, 2]))))
        xstart = max(1,
            Int(round(mag * (μ[nn, 2] - nsigma * σ_μ[nn, 1] - 0.5))))
        xend = min(imagesize[2],
            Int(round(mag * (μ[nn, 2] + nsigma * σ_μ[nn, 1]))))
        for ii = ystart:yend, jj = xstart:xend
            image[ii, jj] +=
                Distributions.pdf(distrib, ([ii; jj] .- 0.5) / mag .+ 0.5)
        end
    end

    # Normalize the image to sum to 1.0.  If any image values are NaN, set them
    # to 0.0.
    nanpixels = isnan.(image)
    if any(nanpixels)
        image[nanpixles] .= 0.0
    end
    image = image ./ sum(image)
    if !isapprox(sum(image), 1.0)
        @warn "Image is non-normalizable!  Returning flat image."
        image = ones(Float64, imagesize[1], imagesize[2]) ./ prod(imagesize)
    end

    return image
end

"""
    image = makegaussim(smld::SMLMData.SMLD2D;
                        mag::Float64 = 20.0, 
                        nsigma::Float64 = 5.0)

Make a Gaussian image of the localizations in `smld`.

# Description
This function creates an image of the localizations in `smld` by placing a
Gaussian truncated to `nsigma` at the localization coordinates, where the 
standard deviation is given by `smld.σ_x` and `smld.σ_y`.  The image is then
normalized such that it sums to 1.0.  The background signal is not accounted
for in this method.

# Inputs
-`smld`: SMLMData.SMLD2D data structure containing localizations.
-`mag`: Approximate magnfication from data coordinates to SR coordinates. 
        (Default = 20.0)
-`nsigma`: Number of standard deviations from the localization coordinate at
           which we truncate the Gaussian. (Default = 5.0)

# Outputs
-`image`: Matrix{Float64} Gaussian image in which each localization in `smld`
          is plotted as a Gaussian.
"""
function makegaussim(smld::SMLMData.SMLD2D;
    mag::Float64 = 20.0,
    nsigma::Float64 = 5.0)
    return SMLMData.makegaussim([smld.y smld.x], [smld.σ_y smld.σ_x],
        smld.datasize; mag = mag, nsigma = nsigma)
end

"""
    image = makebinim(coords::Matrix{Float64}, 
                      datasize::Vector{Float64},
                      mag::Float64 = 20.0)

Make a binary image of the localizations in `coords`.

# Description
This function creates an image of the localizations in `coords` by placing a
hot pixel at the coordinates of each localization.

# Inputs
-`coords`: Localization coordinates. ([y x])
-`datasize`: Size of the data image. ([ysize xsize])
-`mag`: Approximate magnfication from data coordinates to SR coordinates. 
        (Default = 20.0)

# Outputs
-`image`: Matrix{Float64} binary image of localizations.
"""
function makebinim(coords::Matrix{Float64},
    datasize::Vector{Int},
    mag::Float64 = 20.0)
    # Loop through localizations and add them to our output binary image.
    imagesize = Int.(round.(datasize * mag))
    image = zeros(Float64, imagesize[1], imagesize[2])
    inds = max.(1.0, (coords .- 0.5) * mag)
    inds[:, 1] = min.(imagesize[1], inds[:, 1])
    inds[:, 2] = min.(imagesize[2], inds[:, 2])
    inds = Int.(round.(inds))
    for nn = 1:size(coords, 1)
        image[inds[nn, 1], inds[nn, 2]] = 1.0
    end

    # Normalize the image to sum to 1.0.
    image = image ./ max(sum(image), 1.0)
    if !isapprox(sum(image), 1.0)
        @warn "Image is non-normalizable!  Returning flat image."
        image = ones(Float64, imagesize[1], imagesize[2]) ./ prod(imagesize)
    end

    return image
end

"""
    image = makebinim(smld::SMLMData.SMLD2D, mag::Float64 = 20.0)

Make a binary image of the localizations in `smld`.

# Description
This function creates an image of the localizations in `smld` by placing a
hot pixel at the coordinates of each localization.

# Inputs
-`smld`: SMLMData.SMLD2D data structure containing localizations.
-`mag`: Approximate magnfication from data coordinates to SR coordinates. 
        (Default = 20.0)

# Outputs
-`image`: Matrix{Float64} binary image of localizations.
"""
function makebinim(smld::SMLMData.SMLD2D, mag::Float64 = 20.0)
    return makebinim([smld.y smld.x], smld.datasize, mag)
end

"""
    image = makehistim(coords::Matrix{Float64},
                       datasize::Vector{Int},
                       mag::Float64 = 20.0)

Make a histogram image of the localizations in `coords`.

# Description
This function creates an image of the localizations in `coords` by adding 1.0
to a pixel for each localization present within that pixel.  The final image
is then scaled so that it sums to 1.0.

# Inputs
-`coords`: Localization coordinates. ([y x])
-`datasize`: Size of the data image. ([ysize xsize])
-`mag`: Approximate magnfication from data coordinates to SR coordinates. 
        (Default = 20.0)

# Outputs
-`image`: Matrix{Float64} histogram image of localizations.
"""
function makehistim(coords::Matrix{Float64},
    datasize::Vector{Int},
    mag::Float64 = 20.0)
    # Loop through localizations and add them to our output image.
    imagesize = Int.(round.(datasize * mag))
    image = zeros(Float64, imagesize[1], imagesize[2])
    inds = max.(1.0, (coords .- 0.5) * mag)
    inds[:, 1] = min.(imagesize[1], inds[:, 1])
    inds[:, 2] = min.(imagesize[2], inds[:, 2])
    inds = Int.(round.(inds))
    for nn = 1:size(coords, 1)
        image[inds[nn, 1], inds[nn, 2]] += 1.0
    end

    # Normalize the image to sum to 1.0.
    image = image ./ max(sum(image), 1.0)
    if !isapprox(sum(image), 1.0)
        @warn "Image is non-normalizable!  Returning flat image."
        image = ones(Float64, imagesize[1], imagesize[2]) ./ prod(imagesize)
    end

    return image
end

"""
    image = makehistim(smld::SMLMData.SMLD2D, mag::Float64 = 20.0)

Make a histogram image of the localizations in `smld`.

# Description
This function creates an image of the localizations in `smld` by adding 1.0
to a pixel for each localization present within that pixel.  The final image
is then scaled so that it sums to 1.0.

# Inputs
-`smld`: SMLMData.SMLD2D data structure containing localizations.
-`mag`: Approximate magnfication from data coordinates to SR coordinates. 
        (Default = 20.0)

# Outputs
-`image`: Matrix{Float64} histogram image of localizations.
"""
function makehistim(smld::SMLMData.SMLD2D, mag::Float64 = 20.0)
    return makehistim([smld.y smld.x], smld.datasize, mag)
end

"""
    image = makecircleim(coords::Matrix{Float64},
                         σ::Vector{Float64},
                         datasize::Vector{Int},
                         mag::Float64 = 20.0)

Make a circle image of the localizations in `coords`.

# Description
This function creates an image of the localizations in `coords` by adding a
circle centered at the locations `coords` with radii `σ`.

# Inputs
-`coords`: Localization coordinates. ([y x])
-`σ`: Standard error of localizations in `coords`. (nlocx1)
-`datasize`: Size of the data image. ([ysize xsize])
-`mag`: Approximate magnfication from data coordinates to SR coordinates. 
        (Default = 20.0)

# Outputs
-`image`: Matrix{Float64} histogram image of localizations.
"""
function makecircleim(coords::Matrix{Float64},
    σ::Vector{Float64},
    datasize::Vector{Int},
    mag::Float64 = 20.0)
    # Rescale the coordinates based on `mag`.
    coords = mag * (coords .- 0.5) .+ 0.5
    σ *= mag

    # Loop through localizations and add them to our output image.
    imagesize = Int.(round.(datasize * mag))
    image = zeros(Float64, imagesize[1], imagesize[2])
    for nn = 1:size(coords, 1)
        # If σ[nn] isn't positive, skip this localization.
        if !(σ[nn] > 0.0)
            continue
        end

        # Define the pixel locations that fall along the circle.
        # NOTE: The extra factor of 4 improves circle appearance.
        θ = range(0, 2 * pi, length = max(4, Int(ceil(4 * (2 * pi * σ[nn])))))
        rows = Int.(round.(coords[nn, 1] .+ σ[nn] * sin.(θ)))
        cols = Int.(round.(coords[nn, 2] .+ σ[nn] * cos.(θ)))
        validind = findall((rows .>= 1) .* (rows .< imagesize[1]) .*
                           (cols .>= 1) .* (cols .< imagesize[1]))

        # Set the pixels of the output image to 1.0 wherever met by the circle.
        for ii in validind
            image[rows[ii], cols[ii]] = 1.0
        end
    end

    return image
end

"""
    image = makecircleim(smld::SMLMData.SMLD2D, mag::Float64 = 20.0)

Make a circle image of the localizations in `smld`.

# Description
This function creates an image of the localizations in `smld` by adding a
circle for each localization.

# Inputs
-`smld`: SMLMData.SMLD2D data structure containing localizations.
-`mag`: Approximate magnfication from data coordinates to SR coordinates. 
        (Default = 20.0)

# Outputs
-`image`: Matrix{Float64} circle image of localizations.
"""
function makecircleim(smld::SMLMData.SMLD2D, mag::Float64 = 20.0)
    coords = [smld.y smld.x]
    σ = vec(mean([smld.σ_y smld.σ_x], dims = 2))
    return SMLMData.makecircleim(coords, σ, smld.datasize, mag)
end