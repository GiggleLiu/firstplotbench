include("../lib.jl")

function analyze(dir)
    terms, versions, t1, t2 = collect_items(dir)
    head = "# Benchmark Results\nUbuntu 18.04, Julia 1.4 \n\nCPU: Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz\n\n"
    tbl = create_table_v(terms, versions, t1, t2)
    open(joinpath(@__DIR__, "README.md"); write=true) do f
        write(f, head *tbl)
    end
    println(tbl)
end

analyze(@__DIR__)
