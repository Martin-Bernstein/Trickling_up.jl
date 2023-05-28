using Trickling_up
using Printf
using LaTeXStrings
"""
This auxiliary function calls the model simulation functions for a variety of specifications and calibrations. The replicator should adjust the calibrations made inside of the function definition if they wish to experiment with different model specifications. The specifications used in the paper are run and are returned.
    
(These calibrations are: partial equilibrium; baseline general equilibrium; three alternate general equilibrium calibrations; a rational expectations extension; and a tight monetary policy extension.) 
"""
function run_estimates(;print)
    
#300 quarters
ts = range(0, stop=300, length=500)

#Baseline calibration
a₀  =   [0.6,0.3,0.1]       #Initial excess savings shares
θ   =   [0.47, 0.38,0.15]   #Income shares (add to 1)
mpcs=   [0.4,0.2,0]         #Quarterly MPCs
m   =   -log.(1 .- mpcs)    #Converted to continuous time
labels = ["Bottom 80%","Next 19%","Top 1%"]

#Baeline partial equilibrium
a_pe, C_pe = Trickling_up.simulate_baseline(a₀, m, θ, ts, ge = false)
#Baseline general equilibrium
a, C = Trickling_up.simulate_baseline(a₀, m, θ, ts)

#Other scenarios:
#Lower MPCs
mpcs_1 = [0.3, 0.1, 0]
m1 = -log.(1 .- mpcs_1)   # convert to continuous time
a1, C1 = Trickling_up.simulate_baseline(a₀, m1, θ, ts)
#More excess savings for the rich
a02 = [0.45, 0.45, 0.1]
a2, C2 = Trickling_up.simulate_baseline(a02, m, θ, ts)
#More earnings for the rich 
θ₃ = [0.3, 0.55, 0.15]
a3, C3 = Trickling_up.simulate_baseline(a₀, m, θ₃, ts)

#Extensions:
#Rational expectations
a_re, C_re = Trickling_up.simulate_re(a₀, m, θ, ts)
#Monetary policy
ϕ = 1.5
a_mp, C_mp = Trickling_up.simulate_monetary(a₀, 1/0.5, m, θ, ϕ, ts)

#300 quarters
ts = range(0, stop=300, length=500)
if(print)
#Print results to screen
println(@sprintf(" PE C           = %d Q  | a0 = %d Q  | a1 = %d Q", Trickling_up.duration(C_pe), Trickling_up.duration(a_pe[1,:]'), Trickling_up.duration(a_pe[2,:]')))
println(@sprintf(" Benchmark C    = %d Q | a0 = %d Q | a1 = %d Q ", Trickling_up.duration(C), Trickling_up.duration(a[1,:]'), Trickling_up.duration(a[2,:]')))
println(@sprintf(" Scenario #1 C  = %d Q | a0 = %d Q | a1 = %d Q  ", Trickling_up.duration(C1), Trickling_up.duration(a1[1,:]'), Trickling_up.duration(a1[2,:]')))
println(@sprintf(" Scenario #2 C  = %d Q | a0 = %d Q | a1 = %d Q  ", Trickling_up.duration(C2), Trickling_up.duration(a2[1,:]'), Trickling_up.duration(a2[2,:]')))
println(@sprintf(" Scenario #3 C  = %d Q | a0 = %d Q | a1 = %d Q ", Trickling_up.duration(C3), Trickling_up.duration(a3[1,:]'), Trickling_up.duration(a3[2,:]')))
println(@sprintf(" Rational E C   = %d Q  | a0 = %d Q  | a1 = %d Q ", Trickling_up.duration(C_re), Trickling_up.duration(a_re[1,:]'), Trickling_up.duration(a_re[2,:]')))
println(@sprintf(" Tight mp C     = %d Q  | a0 = %d Q  | a1 = %d Q", Trickling_up.duration(C_mp), Trickling_up.duration(a_mp[1,:]'), Trickling_up.duration(a_mp[2,:]')))


# Write table to latex string
latex_output = """
\\documentclass[11pt]{article}
\\usepackage[utf8]{inputenc}
\\usepackage[english]{babel}
\\usepackage{textcomp}
\\usepackage{amsmath}
\\usepackage{amssymb}
\\begin{document}
\\begin{tabular}{llll}
\\hline
& \\multicolumn{3}{c}{Duration of output and excess savings} \\\\
\\hline
Scenario & Output \$Y\$ & Middle class \$a_1\$ & Rich \$a_2\$ \\\\
\\hline\\hline
Partial Equilibrium & $(Int(round(Trickling_up.duration(C_pe)))) & $(Int(round(Trickling_up.duration(a_pe[1,:]')))) & $(Int(round(Trickling_up.duration(a_pe[2,:]')))) \\\\

Benchmark & $(Int(round(Trickling_up.duration(C)))) & $(Int(round(Trickling_up.duration(a[1,:]')))) & $(Int(round(Trickling_up.duration(a[2,:]')))) \\\\

Lower MPCs (\$mpc_1=$(mpcs_1[1])\$,
\$mpc_2=$(mpcs_1[2])\$)
& $(Int(round(Trickling_up.duration(C1)))) & $(Int(round(Trickling_up.duration(a1[1,:]')))) & $(Int(round(Trickling_up.duration(a1[2,:]')))) \\\\

More excess savings to rich (\$a_{10}=a_{20}=$(a02[1])B\$)
& $(Int(round(Trickling_up.duration(C2)))) & $(Int(round(Trickling_up.duration(a2[1,:]')))) & $(Int(round(Trickling_up.duration(a2[2,:]')))) \\\\

More earnings to rich (\$\\theta_1=$(θ₃[1]),\\theta_2=$(θ₃[2])\$)
& $(Int(round(Trickling_up.duration(C3)))) & $(Int(round(Trickling_up.duration(a3[1,:]')))) & $(Int(round(Trickling_up.duration(a3[2,:]')))) \\\\

Rational Expectations & $(Int(round(Trickling_up.duration(C_re)))) & $(Int(round(Trickling_up.duration(a_re[1,:]')))) & $(Int(round(Trickling_up.duration(a_re[2,:]')))) \\\\

Tight Monetary Policy (\$\\Phi = $(ϕ)\$)
& $(Int(round(Trickling_up.duration(C_mp)))) & $(Int(round(Trickling_up.duration(a_mp[1,:]')))) & $(Int(round(Trickling_up.duration(a_mp[2,:]')))) \\\\
\\hline
\\end{tabular}
\\end{document}
"""

# Write the output to a .tex file
open("output/table1.tex", "w") do f
    write(f, latex_output)
end

# Generate a .pdf from the file.
run(`latexmk -pdf -outdir=output output/table1.tex`)
# Clean up auxiliary files
run(`latexmk -c -outdir=output output/table1.tex`)

end


return a_pe, C_pe, a, C, a1, C1, a2, C2, a3, C3, a_re, C_re, a_mp, C_mp, ts
end