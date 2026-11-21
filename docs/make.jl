using SMLMData
using Documenter

DocMeta.setdocmeta!(SMLMData, :DocTestSetup, :(using SMLMData); recursive=true)

makedocs(;
    modules=[SMLMData],
    doctest = false, # QA runs every docstring jldoctest (admiral decision 0018)
    checkdocs = :exports, # SMLMData's own docstrings; the re-exported names are documented by SMLMCore and SMLMio
    sitename="SMLMData.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaSMLM.github.io/SMLMData.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaSMLM/SMLMData.jl",
    devbranch = "main"
)
