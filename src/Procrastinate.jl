module Procrastinate

export Deferred

"""
    Deferred

A struct representing a value that is computed only when needed and only once.

It is most useful for computing expensive members of `struct`s that may or may not
ever be used.  By deferring the computation, the cost is avoided if the datum is 
never used.

`Deferred` takes advantage of closures to ensure that the necessary data will be 
available when needed.   `Deferred` is thread safe.

# Example:
```julia-repl
julia> using Procrastinate
julia> d = Deferred() do
    # Some expensive computation
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
struct Deferred
    func::Function
    lock::ReentrantLock
    item::Base.RefValue{Any}

    function Deferred(f::Function) 
        @assert applicable(f) "The function passed to the Deferred constructor must take exactly zero-arguments."
        new(f, ReentrantLock(), Base.RefValue{Any}())
    end
    function Deferred(value) 
        new((x->@assert false), ReentrantLock(), value)
    end
end

function Base.show(io::IO, pc::Deferred)
    print(io, "Deferred($(repr(pc.func)), eval=$(isassigned(pc)))")
end

function (df::Deferred)()
    if !isassigned(df.item)
        lock(df.lock) do
            if !isassigned(df.item)
                df.item[] = df.func()
            end
        end
    end
    return df.item[]
end

Base.isassigned(d::Deferred) = Base.isassigned(d.item)

end
