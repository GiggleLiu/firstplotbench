using
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

function analyze(dir)
    terms, versions, t1, t2 = collect_items(dir)
    tbl = create_table(terms, versions, t1, t2)
    open(joinpath(@__DIR__, "README.md"); write=true) do f
        write(f, tbl)
    end
    println(tbl)
end

analyze(@__DIR__)
