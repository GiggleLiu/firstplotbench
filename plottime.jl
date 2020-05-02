using DelimitedFiles
using Pkg

which = ARGS[1]
println("Timing `$which.jl`")

const x = collect(1:100) .* 1.0
const y = x.^2

const t1 = Ref(0.0)
const t2 = Ref(0.0)
const vnum = Ref(v"0.1.0")

include("lib.jl")

if which == "PlotlyJS" # done!
    @tryusing PlotlyJS
    t2[] = @elapsed (p=PlotlyJS.plot(x, y); display(p))
elseif which == "GR" # done!
    @tryusing GR
    t2[] = @elapsed GR.plot(x, y)
elseif which == "PyPlot" # done!
    @tryusing PyPlot
    t2[] = @elapsed (p=PyPlot.plot(x, y); PyPlot.ion(); PyPlot.show())
elseif which == "Plots" # done!
    @tryusing Plots
    t2[] = @elapsed (p=Plots.plot(x, y); display(p))
elseif which == "UnicodePlots" # done!
    @tryusing UnicodePlots
    t2[] = @elapsed (p=UnicodePlots.lineplot(x, y); display(p))
elseif which == "Gadfly" # done!
    @tryusing Gadfly
    t2[] = @elapsed (p=Gadfly.plot(y=y); display(p))
elseif which == "VegaLite" # done?
    @tryusing VegaLite
    t2[] = @elapsed eval(:(VegaLite.@vlplot(:line, x=x, y=y))) |> display
elseif which == "Compose" # done!
    @tryusing Compose
    t2[] = @elapsed Compose.draw(SVG("_tomato.svg", 4cm, 4cm), compose(compose(context(), rectangle()), fill("tomato")))
elseif which == "Makie" # done!
    @tryusing Makie
    t2[] = @elapsed (p=Makie.plot(x, y); display(p))
elseif which == "Luxor" # done!
    @tryusing Luxor
    t2[] = @elapsed eval(:(@png begin
        Luxor.circle(Point(0, 0), 200, :stroke)
    end))
else
    error("unkown option $which")
end

println("using -> $(t1[])")
println("first plot -> $(t2[])")
writedlm("plottime/$which.dat", [vnum, t1[], t2[]])
