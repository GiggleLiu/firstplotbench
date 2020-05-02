using DelimitedFiles
using Pkg

which = ARGS[1]
println("Timing `$which.jl`")

const t1 = Ref(0.0)
const t2 = Ref(0.0)
const vnum = Ref(v"0.1.0")

include("lib.jl")

function f(x, y)
    x + y
end

if which == "NiLang" # done
    @tryusing NiLang
    eval(:(@i function f_r(x, y)
        x += identity(y)
    end
    ))
    t2[] = @elapsed NiLang.AD.gradient(Val(1), f_r, (1.0, 2.0))
elseif which == "ForwardDiff" # done
    @tryusing ForwardDiff
    t2[] = @elapsed f(ForwardDiff.Dual(1.0, 1.0), ForwardDiff.Dual(2.0, 0.0))
elseif which == "ReverseDiff"
    @tryusing ReverseDiff # done
    t2[] = @elapsed ReverseDiff.gradient(f, 1.0, 2.0)
elseif which == "Zygote" # done
    @tryusing Zygote
    t2[] = @elapsed Zygote.gradient(f, 1.0, 2.0)
elseif which == "Flux" # done
    @tryusing Flux
    t2[] = @elapsed Flux.gradienet(f, (1.0, 2.0))
else
    error("unkown option $which")
end

println("using -> $(t1[])")
println("first ad -> $(t2[])")
writedlm("adtime/$which.dat", [vnum, t1[], t2[]])
