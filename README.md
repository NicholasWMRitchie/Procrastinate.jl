# Procrastinate.jl

Strategic laziness.

Procrastinate.jl does one simple thing.  It waits until the last possible moment 
to compute an object.  It is useful for expensive to compute items in a `struct` that 
may or may not be required.  It takes a return type and zero-argument closure.

# Example
```julia-repl
julia> using Procrastinate
julia> d = Deferred(String) do
    # Some expensive function
    println("Computing!")
    return "result"
end
julia> d()
Computing!
"result"
julia> d()
"result"
```
"""