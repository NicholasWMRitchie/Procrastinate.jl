module Procrastinate

export Deferred


"""
    Deferred{T}

A struct representing a `T` that is computed only as needed and only once.

It is most useful for computing expensive members of `struct`s that may or may not
ever be used.  By deferring the computation, the cost is avoided if the datum is 
never used.

`Deferred` takes advantage of closures to ensure that the necessary data will be 
available when needed.

# Example:
```julia-repl
julia> d = Deferred(String) do
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
struct Deferred{T}
    func::Function
    item::Base.RefValue{T}

    function Deferred(f::Function, ::Type{T}=Base._return_type(f, ())) where {T<:Any}
        new{T}(f, Base.RefValue{T}())
    end
    Deferred(t::T) where {T<:Any} = new{T}((() -> @assert false), Base.RefValue(t))
end

function Base.show(io::IO, pc::Deferred)
    print(io, "$(repr(typeof(pc)))(eval=$(isassigned(pc.item)))")
end

function (pc::Deferred{T})()::T where {T<:Any}
    if !isassigned(pc.item)
        pc.item[] = pc.func()
    end
    return pc.item[]
end

Base.isassigned(d::Deferred) = Base.isassigned(d.item)

end
