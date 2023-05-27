module Trickling_up
    using DifferentialEquations
    using LinearAlgebra
    using Plots

"""
Solver for linear rational expectations models in continuous time
"""
#300 quarters
ts = range(0, stop=300, length=500)
function solver(A, N)
    # Schur decomposition A = Q U Q' with stable (negative real part)
    # eigenvalues ordered first in U 
    F = schur(A)
    U, Q, eigs = ordschur(F, F.values .< 0)
    n_neg = sum(eigs.<0)
    # check the Blanchard-Kahn condition
    if n_neg != N
        error("Fails Blanchard-Kahn condition, $N states but $n_neg negative eigenvalues")
    end
    # obtain B = Q_xs*U_ss*Q_xs^(-1), F = Q_yx*Q_xs^(-1), transposing
    # twice for both to avoid calculating matrix inverse
    B = (Q[1:N, 1:N]' \ ((Q[1:N, 1:N] * U[1:N, 1:N])'))'
    F = (Q[1:N, 1:N]' \ Q[N+1:end, 1:N]')'
    return B, F
end

"""
Simulates a baseline model
"""
function simulate_baseline(a0, m, theta, ts; ge=true)
    # define matrix B so that adot = Ba, use matrix exponential as solution for each t
    # not the most efficient approach, but fine for this purpose
    B = -Diagonal(m) + (ge ? theta * m' : zeros(size(m,1), size(m,1)))
    # Solve system for each time point
    a = [exp(t * B) * a0 for t in ts]
    # Transpose a to match the output shape in the Python function
    a = hcat(a...)
    # return N*T matrix giving asset ("excess savings") path, T vector giving agg C
    return a, m' * a
end

"""
Extends the model to include rational expectations of future income
"""
function simulate_re(a0, m, theta, ts)
    # drop last type (assume Ricardian), remember total assets
    atotal          = sum(a0)
    a0, m, theta    = a0[1:end-1],m[1:end-1],theta[1:end-1]
    # build A matrix
    N   =   length(m)
    A   =   [zeros(N,N) theta*ones(N)' - I;
            Diagonal(-m.^2) zeros(N,N) ]
    # obtain solution: adot = B*a, c=F*a
    B, F    =   solver(A,N)
    a       =   [exp(t*B)*a0 for t in ts]
    a       =   hcat(a...)
    C       =   sum(F, dims=1) * a
    #add back final type's assets 
    a       =   vcat(a, atotal .- sum(a, dims=1))
    return a, C
end

"""
Extends the model to include a monetary policy response.
"""
function simulate_monetary(a0, sigma, m, theta, phi, ts)
    N = length(m)
    # build A matrix
    A = [(theta*m') - Diagonal(m) theta*ones(N)' - I;
     phi/sigma * theta*m' Diagonal(m) + phi/sigma * theta*ones(N)']
    # delete row and column for Ricardian assets to avoid unit root (doesn't affect spending)
    A = A[[1:N-1; N+1:end], [1:N-1; N+1:end]]
    # obtain solution: adot = B*a, cP = F*a, c = cP + m'a
    B, F = solver(A, N-1)
    a = hcat([(exp(t*B) * a0[1:end-1]) for t in ts]...)
    C = (sum(F, dims=1) .+ m[1:end-1]') * a
    # add back final type's assets
    a = vcat(a, sum(a0) .- sum(a, dims=1))
    return a, C
end

function simpson_weights(T)
    # get equispaced Simpson weights of 1, 4, 2, 4, 2, ..., 4, 1 all divided by 3
    @assert T % 2 == 1 "must have odd # of points, even # of intervals for standard Simpson rule"
    weights = 2 .+ 2 .*(collect(0:T-1) .% 2 .== 1)
    weights[1] -= 1
    weights[end] -= 1
    return weights ./ 3
end

function simpson(y, x)
    # Integrate y(x) using Simpson's rule, assuming x is equispaced
    T = length(x)
    if T % 2 == 1
        # standard case with odd # of points, even # of intervals
        return (x[2] - x[1])*dot(simpson_weights(T), y)
    else
    # even # of points, odd # of intervals, use Simpson's 3/8 rule on final 3 intervals as fix
    final_weights = (3/8)*[1, 3, 3, 1]
    return (x[2] - x[1])*(dot(simpson_weights(T-3), y[1:end-3]) + dot(final_weights, y[end-3:end]))
    end
end

function duration(X)
    return simpson(X .* ts', ts) / simpson(X, ts)
end

end