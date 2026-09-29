using SMLMData, Test

# Docs.hasdoc is Julia 1.11+; a docstring is an entry for the name's binding in its module's docs.
_hasdoc(m, s) = (b = Base.Docs.Binding(m, s); haskey(Base.Docs.meta(b.mod), b))

@testset "every exported name has a docstring" begin
    # ?name and the @autodocs API page need each exported name's docstring attached to it.
    undocumented = [n for n in names(SMLMData) if n !== :SMLMData && !_hasdoc(SMLMData, n)]
    @test undocumented == Symbol[]
end
