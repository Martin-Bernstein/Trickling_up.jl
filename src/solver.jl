using DifferentialEquations
using LinearAlgebra
using Plots
"""
(Very) lightweight solver for linear rational expectations models in continuous time

Suppose our model is given by the linear ODE
\\[
    \\begin{pmatrix}\\dot{x}\\\\\\dot{y}\\end{pmatrix}
    =
    \\begin{pmatrix}A_{xx} & A_{xy} \\\\ A_{yx} & A_{yy}\\end{pmatrix}
    \\begin{pmatrix}x\\\\y\\end{pmatrix}
\\]
where \$x\$ is a predetermined `state' vector of length \$N\$,
\$y\$ is vector of 'jump' variables,
and the four blocks \$A\$ form a matrix \$\\mathbf{A}\$. For there to be a unique solution for \$y\$ given
the state \$x\$, there must be \$N\$ stable eigenvalues (i.e. with negative real part) of \$\\mathbf{A}\$.

Let \$\\mathbf{A} = QUQ'\$ be the Schur decomposition of \$\\mathbf{A}\$, where Q is unitary and U is upper triangular.
Assuming that this is decomposition is made such that the stable eigenvalues of U are at the top left,
we can write:
\\[
    U=\\begin{pmatrix}U_{ss}&U_{su}\\\\0&U_{uu}\\end{pmatrix}
    \\hspace{1cm}
    Q=\\begin{pmatrix}Q_{xs} & Q_{xu} \\\\ Q_{ys} & Q_{yu}\\end{pmatrix}
\\]
where the \$N\$-by-\$N\$ upper left block \$U_ss\$ maps the stable subspace to itself, the \$N\$-by-\$N\$
\$Q_{xs}\$ maps the stable subspace to \$x\$, etc.

Given any state \$x\$, we can obtain the rotated stable state by solving \$s = Q_{xs}^{-1}*x\$.
Then \$\\dot{s} = U_{ss}*s\$, and \$\\dot{x} = Q_{xs}*\\dot{s} = Q_{xs}*U_{ss}*Q_{xs}^{-1}\$. 
The jump variables \$y\$ can be obtained from \$s\$ by \$y = Q_{yx}*s = Q_{yx}*Q_{xs}^{-1}*x\$.

Summing up, our model will have law of motion
\\[
\\dot{x} = B*x
\\hspace{1cm}
y = F*x
\\]
where \$B = Q_{xs}*U_{ss}*Q_{xs}^{-1}\$ and \$F = Q_{yx}*Q_{xs}^{-1}\$.
"""
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