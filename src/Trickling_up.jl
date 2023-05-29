module Trickling_up
    using DifferentialEquations
    using LinearAlgebra
    using Plots
    using LaTeXStrings
    using TestSetExtensions
    #300 quarters
    ts = range(0, stop=300, length=500)
    
    #Auxiliary functions
    include("solver.jl")
    include("model_simulators.jl")
    include("simpson.jl")

    include("/test/runtests.jl")

end