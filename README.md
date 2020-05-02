# A benchmark of first plot time and autodiff time

## To run benchmarks
e.g.

```bash
$ julia plottime.jl GR
$ julia plottime.jl GR # run a second time to remove precompile time.
```

## Results
We benchmarked using the time of `using XXX`, and the time of first `plot(...)` in plotting packages and first `gradient(...)` in autodiff packages.

Check [Benchmarking First Plot](plottime/README.md) and [Benchmarking First Autodiff](adtime/README.md).
