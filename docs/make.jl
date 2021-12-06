using SMLMData
using Documenter

DocMeta.setdocmeta!(SMLMData, :DocTestSetup, :(using SMLMData); recursive=true)

makedocs(;
    modules=[SMLMData],
    sitename="SMLMData.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaSMLM.github.io/SMLMData.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Library.md"
    ],
)

deploydocs(;
    repo="github.com/JuliaSMLM/SMLMData.jl",
    devbranch = "main" 
)
