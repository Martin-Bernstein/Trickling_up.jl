"""
Auxiliary function to implement Simpson's rule, in order to integrate over the paths of consumption, to obtain the duration of total consumption \$\\int tC_t / \\int C_t\$.
"""
function simpson_weights(T)
    # get equispaced Simpson weights of 1, 4, 2, 4, 2, ..., 4, 1 all divided by 3
    @assert T % 2 == 1 "must have odd # of points, even # of intervals for standard Simpson rule"
    weights = 2 .+ 2 .*(collect(0:T-1) .% 2 .== 1)
    weights[1] -= 1
    weights[end] -= 1
    return weights ./ 3
end
"""
Implements Simpson's rule in order to integrate over the paths, using the auxiliary weights function simpson_weights.
"""
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

"""
Calculates the duration of total consumption using the "simpson" integration function.
"""
function duration(X)
    return simpson(X .* ts', ts) / simpson(X, ts)
end