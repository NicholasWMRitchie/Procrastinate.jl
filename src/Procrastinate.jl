module Procrastinate

export Deferred


"""
    Deferred{T}

A struct representing a `struct` that is computed only when needed and only once.

It is most useful for computing expensive members of `struct`s that may or may not
be used.  By deferring the computation until later, the computation is avoided if
it is never needed.

`Deferred` takes advantage of the way in which all the necessary data items are 
attached to a closure to ensure that it has what it need to compute the value when
it gets around to computing the value.

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
    item::Ref{T}

    Deferred(f::Function, ::Type{T}=Any) where {T<:Any} = new{T}(f, Ref{T}())
    Deferred(item::T) where { T <: Any} = new{T}(()->@assert false, Ref(item))
end

Base.show(io::IO, pc::Deferred) = print(io, "$(repr(typeof(pc)))(eval=$(isassigned(pc.item)))")

function (pc::Deferred{T})()::T where {T<:Any}
    if !isassigned(pc.item)
        pc.item[] = pc.func()
    end
    return pc.item[]
end

end
