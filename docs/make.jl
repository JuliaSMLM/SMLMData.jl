using SMLMData
using Documenter

DocMeta.setdocmeta!(SMLMData, :DocTestSetup, :(using SMLMData); recursive=true)

makedocs(;
    modules=[SMLMData],
    authors="klidke@unm.edu",
    repo="https://github.com/JuliaSMLM/SMLMData.jl/blob/{commit}{path}#{line}",
    sitename="SMLMData.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaSMLM.github.io/SMLMData.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/kalidke/SMLMData.jl",
    devbranch = "main" 
)
