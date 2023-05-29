using Trickling_up
using XLSX
using DataFrames
using CSV
using Dates
using Statistics
using Plots

function data_fig1()
    
    #Import savings rate from FRED, calculate mean
    df = DataFrame(XLSX.readtable("./auclert_original/replication/Data/PSAVERT.xlsx","FRED Graph"))
    rename!(df,["date","savings_rate"])
    df[:,1] = Date.(df[:,1])
    df = df[df[:,1] .> Date("2014"),:] #Keep observations after 2014

    avg = mean(df[df[:,1] .< Date("2019-01-01"),2])

    #Import excess savings stock from Fed Board
    df2 = DataFrame(XLSX.readtable("./auclert_original/replication/Data/Excess_Savings.xlsx","Data"))
    df2[!,"date"] = Date.(df2[!,"date"])

    #Plot figure
    d1 = plot(df[:,1],df[:,2],
        color="black",label="Actual")
    plot!(df[:,1],df[:,2]./df[:,2].*avg,color="black",
    title = "U.S. personal savings rate",linestyle=:dash,label="2014-2019 average",
    legend = :topleft)
    ylabel!("Percent of GDP")
    xlabel!("")

    d2 = plot(df2[:,1],df2[:,2],
    color="black",legend=:none,
    title = "Estimated stock of excess savings")
    ylabel!("Billions of USD")

    return d1, d2
end