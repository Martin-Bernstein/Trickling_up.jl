using Trickling_up
using Test
using TestSetExtensions

@testset "Trickling_up.jl" begin
#Test that the length of the returned paths match the original time series
a_pe, C_pe, a, C,
a1, C1, a2, C2, 
a3, C3, a_re, C_re,
a_mp, C_mp, ts = run_estimates(print=false)
as = [a_pe, a, a1, a2, a3, a_re, a_mp]
Cs = [C_pe, C, C1, C2, C3, C_re, C_mp]

for a in as
    for i in axes(a,1)
        @test length(a[i,:]) == length(ts)
    end
end
for C in Cs
    for i in axes(C,1)
        @test length(C[i,:]) == length(ts)
    end
end
end
