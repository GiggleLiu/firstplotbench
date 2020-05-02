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


