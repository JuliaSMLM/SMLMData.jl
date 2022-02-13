# SMLMData

Data types and utilities for SMLM coordinate data. 

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliasmlm.github.io/SMLMData.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliasmlm.github.io/SMLMData.jl/dev)
[![Build Status](https://github.com/juliasmlm/SMLMData.jl/workflows/CI/badge.svg)](https://github.com/juliasmlm/SMLMData.jl/actions)
[![Coverage](https://codecov.io/gh/juliasmlm/SMLMData.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/juliasmlm/SMLMData.jl)

## Overview
SMLMData provides a type for storing SMLM data as well as visualization tools and utilty functions.  SMLMData Types should inherit from `SMLD`.  The 2D data type is:

```
mutable struct SMLD2D <: SMLD
    connectID::Vector{Int}
    x::Vector{Float64}
    y::Vector{Float64}
    σ_x::Vector{Float64}
    σ_y::Vector{Float64}
    photons::Vector{Float64}
    σ_photons::Vector{Float64}
    bg::Vector{Float64}
    σ_bg::Vector{Float64}
    framenum::Vector{Int}
    datasetnum::Vector{Int}
    datasize::Vector{Int}
    nframes::Int
    ndatasets::Int
    datafields::NTuple{11, Symbol}
    SMLD2D() = new()
end
```


## Visualization Tools

## Utilities

