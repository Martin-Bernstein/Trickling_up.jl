using Plots
"""
Auxiliary function to produce stack plots of asset holdings over time. a is an \$N \\times T\$ vector tracking the distribution of assets over time, where \$N\$ is the number of groups and \$T\$ is the number of periods. title is the desired title of the graph. If the replicator wishes to adjust the style of the plots, they should change the colors and labels parameters directly inside of this plot. The default is also to plot assets over 40 periods; this can be adjusted by the replicator by changing the default_time parameter inside the function.
"""
function stack_plot(a, title)
      # Define the colors and labels
      colors        = ["#CCCCCC", "#666666", "black"]
      labels        = ["Bottom 80%","Next 19%","Top 1%"]
      default_time  = 40
      # plot
      plot(a[3,1:default_time].+a[2,1:default_time].+a[1,1:default_time],
        xlabel = "Quarters",
        ylabel = "Percent of GDP",
        title = title,
        labels = labels[1],
        color = colors[1],
        fill=true
      )
      plot!(a[3,1:default_time].+a[2,1:default_time],labels=labels[2],fill=true,color = colors[2])
      plot!(a[3,1:default_time],labels = labels[3],fill=true,color = colors[3])
      return current()
end