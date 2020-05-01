function collect1(file)
    println("Handling $file")
    open(file) do f
        v = readline(f)
        t1 = parse(Float64, readline(f))
        t2 = parse(Float64, readline(f))
        return v, t1, t2
    end
end

function collect_items(dir)
    files = filter(x->match(r".*\.dat", x)!=nothing, readdir(dir))
    println("collected $files")
    data = map(x->collect1(joinpath(dir, x)), files)
    terms = map(x->x[1:end-4], files)
    versions = getindex.(data, 1)
    t1 = getindex.(data, 2)
    t2 = getindex.(data, 3)
    return terms, versions, t1, t2
end

function mdrow(leading, terms)
    s = "| $leading |"
    for term in terms
        s *= " $term "
        s *= "|"
    end
    return s
end

function create_table(terms, versions, t1, t2)
    nterm = length(terms)
    hlines = fill("-"^5, nterm)
    join([mdrow("Package", terms), mdrow("-----", hlines), mdrow("Version", versions), mdrow("using", t1), mdrow("plot", t2)], "\n")
end

function create_table_v(terms, versions, t1, t2)
    data = Any[]
    push!(data, mdrow("Package", ["Version", "using", "first plot"]))
    hlines = fill("-"^5, 3)
    push!(data, mdrow("-----", hlines))
    for (term, v, a, b) in zip(terms, versions, t1, t2)
        push!(data, mdrow(term, [v, a, b]))
    end
    join(data, "\n")
end

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
