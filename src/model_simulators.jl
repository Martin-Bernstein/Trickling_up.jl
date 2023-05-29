"""
Simulates the baseline model. The model in the paper is designed to study the distribution of wealth between quantile groups over time. The function returns the paths of assets for each group and the path of aggregate consumption, across the simulation.

Arguments:
a0 is a vector of the groups' excess savings' initial shares in GDP.
m is a vector of each group's respective marginal propensity to consume.
theta is a vector with the proportion of national income earned by each group.
ts is the time-series for which the model is to be simulated.
ge is a boolean which switches general equilibrium effects on or off, enabling analysis of partial and general equilibrium separately.
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
This function extends the baseline model to include rational expectations of future income. a0, m, theta, and ts are as before. The function returns the path of assets and consumption.
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
This function extends the model to include a monetary policy response. a0, m, theta, and ts are as in `simulatebaseline`. phi is the coefficient on output in the monetary authorities policy function: the paper assumes that real rates are set according to \$r_t=\\phi Y_t\$. sigma is households elasticity of intertemporal substitution.
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