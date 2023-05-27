using Trickling_up
using Plots

include("src/run_estimates.jl")

# Unpack the results
a_pe, C_pe, a, C, a1, C1, a2, C2, a3, C3, a_re, C_re, a_mp, C_mp, ts = run_estimates()

# Define a function for stack plots
include("src/stack_plot.jl")

level = 6.7 # Excess savings in 2022Q1 = 6.7% of GDP
# Generate the stack plots
plt1 = stack_plot(a_pe*level, "Excess savings: partial equilibrium")
plt2 = stack_plot(a*level, "Excess savings: easy monetary policy")
plt3 = stack_plot(a_mp*level, "Excess savings: tight monetary policy")
# Plot for Consumption
plt4 = plot(ts, level*C_pe', 
    label="Partial equilibrium", linewidth = 2, color="black", 
    xlims = (0, 40), 
    xlabel = "Quarters", 
    ylabel = "Percent of GDP", 
    title = "Consumption"
)
plot!(ts, level*C', label="Easy monetary policy", linewidth = 2, color="black", linestyle = :dash)
plot!(ts, level*C_mp', label="Tight monetary policy", linewidth = 2, color="black", linestyle = :dashdot, 
  legend = :topright, legendalpha = 0)

# Combine the plots
p = plot(plt1, plt2, plt3, plt4, layout = (2, 2),size = (1200,800))

# Save
savefig(p, "./output/Figure4.pdf")