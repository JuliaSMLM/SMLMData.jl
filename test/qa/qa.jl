# Default QA (admiral decisions 0008, 0015, 0018): Aqua, ExplicitImports, docstring doctests
# and missing docstrings, unchanged in every package except for opt-outs written with their
# reason (the package name is read from Project.toml). Aqua, ExplicitImports and Documenter
# go in the test env.
using Test, TOML, Aqua, ExplicitImports, Documenter

const PKGNAME = Symbol(
    TOML.parsefile(joinpath(@__DIR__, "..", "..", "Project.toml"))["name"]
)
@eval using $PKGNAME
const PKG = getfield(@__MODULE__, PKGNAME)

@testset "Aqua" begin
    Aqua.test_all(PKG)
    # Opt-out: switch off one check and state the reason beside it, e.g.
    #   Aqua.test_all(PKG; ambiguities=false)
    #   # reason: ambiguities come from ForwardDiff's Dual methods
end

@testset "ExplicitImports" begin
    @test check_no_implicit_imports(PKG) === nothing
    @test check_no_stale_explicit_imports(PKG) === nothing
    # Opt-out: ignore named items and state the reason, e.g.
    #   check_no_implicit_imports(PKG; ignore=(:Foo,))
    #   # reason: Foo is re-exported on purpose
end

@testset "Docstrings" begin
    # Every public name, the module included, has a docstring (Docs.undocumented_names:
    # Julia 1.11+).
    if isdefined(Base.Docs, :undocumented_names)
        @test isempty(Base.Docs.undocumented_names(PKG))
    end
    # Every jldoctest in a docstring runs. Examples that need a GPU, data or network are
    # plain julia blocks.
    DocMeta.setdocmeta!(PKG, :DocTestSetup, :(using $PKGNAME); recursive = true)
    doctest(PKG; manual = false)
end
