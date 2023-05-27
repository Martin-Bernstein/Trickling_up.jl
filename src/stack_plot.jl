using Plots
function stack_plot(a, title)
      # Define the colors and labels
      colors = ["#CCCCCC", "#666666", "black"]
      labels = ["Bottom 80%","Next 19%","Top 1%"]
      # plot
      plot(a[3,1:40].+a[2,1:40].+a[1,1:40],
        xlabel = "Quarters",
        ylabel = "Percent of GDP",
        title = title,
        labels = labels[1],
        color = colors[1],
        fill=true
      )
      plot!(a[3,1:40].+a[2,1:40],labels=labels[2],fill=true,color = colors[2])
      plot!(a[3,1:40],labels = labels[3],fill=true,color = colors[3])
      return current()
end