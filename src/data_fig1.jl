using Trickling_up
using XLSX
using DataFrames
using CSV

function data_fig1()
    df = DataFrame(XLSX.readtable("./auclert_original/replication/Data/PSAVERT.xlsx","FRED Graph"))
    rename!(df,["date","savings_rate"])
    df[:,1]
    df = df[]
end