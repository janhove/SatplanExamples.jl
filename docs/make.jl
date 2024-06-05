using SatplanExamples
using Documenter

DocMeta.setdocmeta!(SatplanExamples, :DocTestSetup, :(using SatplanExamples); recursive=true)

makedocs(;
    modules=[SatplanExamples],
    authors="Jan Vanhove <janvanhove@gmail.com>",
    sitename="SatplanExamples.jl",
    format=Documenter.HTML(;
        canonical="https://janhove.github.io/SatplanExamples.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/janhove/SatplanExamples.jl",
    devbranch="main",
)
