module Trickling_up
    using DifferentialEquations
    using LinearAlgebra
    using Plots
    
    #300 quarters
    ts = range(0, stop=300, length=500)
    
    #Auxiliary functions
    include("solver.jl")
    include("model_simulators.jl")
    include("simpson.jl")

end