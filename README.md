# Procrastinate.jl

Strategic laziness.

The `Deferred` datatype in Procrastinate.jl does one simple thing.  It waits until the 
last possible moment to compute an object.  It is useful for expensive to compute items 
in a `struct` that may or may not ever be required.  It takes a return type and 
*zero-argument* closure.

### Minimal Example
```julia-repl
julia> using Procrastinate
julia> d = Deferred() do
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

### More typical usage
```julia
struct Demo
    item1::Deferred
    item2::Deferred
    Demo(d1::Deferred, d2::Deferred) = new(d1,d2)
end
fn(n) = n ∈ (0, 1) ? 1 : fn(n-2) + fn(n-1) # slow!
n, str = 42, "It's a bird!"
dd = Demo(
    Deferred() do 
        Base.sleep(2)
        str
    end, 
    Deferred(()->fn(n)) # takes a few seconds
)
dd.item1() # returns "It's a bird!" after a couple seconds
dd.item2() # returns 433494437 after a few seconds
dd.item1() # returns "It's a bird!" almost immediately
dd.item2() # returns 433494437 almost immediately
```
