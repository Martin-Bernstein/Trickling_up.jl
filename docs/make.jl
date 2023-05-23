using Trickling_up
using Documenter

DocMeta.setdocmeta!(Trickling_up, :DocTestSetup, :(using Trickling_up); recursive=true)

makedocs(;
    modules=[Trickling_up],
    authors="Martin Bernstein <martinmbernstein@gmail.com> and contributors",
    repo="https://github.com/Martin-Bernstein/Trickling_up.jl/blob/{commit}{path}#{line}",
    sitename="Trickling_up.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Martin-Bernstein.github.io/Trickling_up.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Martin-Bernstein/Trickling_up.jl",
    devbranch="main",
)
