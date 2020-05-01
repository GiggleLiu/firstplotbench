using DelimitedFiles
using Pkg

which = ARGS[1]
println("Timing `$which.jl`")

const x = collect(1:100) .* 1.0
const y = x.^2

const t1 = Ref(0.0)
const t2 = Ref(0.0)
const vnum = Ref(v"0.1.0")

function installed()
    deps = Pkg.dependencies()
    installs = Dict{String, VersionNumber}()
    for (uuid, dep) in deps
        dep.is_direct_dep || continue
        dep.version === nothing && continue
        installs[dep.name] = dep.version
    end
    return installs
end

macro tryusing(sym)
    esc(quote
        pkglist = installed()
        pkg = string($(QuoteNode(sym)))
        if !haskey(pkglist, pkg)
            println("installing $(pkg)...")
            Pkg.add(pkg)
            pkglist = installed()
        end
        vnum[] = pkglist[pkg]
        t1[] = @elapsed using $sym
    end)
end

if which == "PlotlyJS" # done
    @tryusing PlotlyJS
    t2[] = @elapsed PlotlyJS.plot(x, y)
elseif which == "GR" # done
    @tryusing GR
    t2[] = @elapsed GR.plot(x, y)
elseif which == "PyPlot"
    @tryusing PyPlot # done
    t2[] = @elapsed PyPlot.plot(x, y)
elseif which == "Plots" # done
    @tryusing Plots
    t2[] = @elapsed Plots.plot(x, y)
elseif which == "UnicodePlots" # done
    @tryusing UnicodePlots
    t2[] = @elapsed UnicodePlots.lineplot(x, y)
elseif which == "Gadfly" # done
    @tryusing Gadfly
    t2[] = @elapsed Gadfly.plot(y=y)
elseif which == "VegaLite" # done
    @tryusing VegaLite
    t2[] = @elapsed eval(:(VegaLite.@vlplot(:line, x=x, y=y)))
elseif which == "Compose" # done
    @tryusing Compose
    t2[] = @elapsed Compose.draw(SVG("_tomato.svg", 4cm, 4cm), compose(compose(context(), rectangle()), fill("tomato")))
elseif which == "Makie" # done
    @tryusing Makie
    t2[] = @elapsed Makie.plot(x, y)
elseif which == "Luxor"
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
