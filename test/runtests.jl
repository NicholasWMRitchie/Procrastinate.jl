using Procrastinate
using Test

@testset "Procrastinate.jl" begin
    @testset "Basic" begin
        df = Deferred(String) do 
            "Fish or fowl"
        end
        @test !isassigned(df.item)
        @test df() == "Fish or fowl"
        @test isassigned(df.item)
        @test df() == "Fish or fowl"
        @test df() == "Fish or fowl"
        @test isassigned(df.item)
    end
    @testset "Timed" begin
        df = Deferred() do 
            sleep(1.0) # something time consuming
            "Fish or fowl"
        end
        @test !isassigned(df.item)
        stats = @timed df()
        @assert stats.time > 1.0
        stats = @timed df()
        @assert stats.time < 0.01
        stats = @timed df()
        @assert stats.time < 0.01
        @test df() == "Fish or fowl"
        @test isassigned(df.item)
    end
    @testset "In a struct" begin
        struct Demo{T, U}
            item1::Deferred{T}
            item2::Deferred{U}
            Demo(d1::Deferred{V}, d2::Deferred{W}) where { V <: Any, W <: Any } = new{V,W}(d1,d2)
        end
        fn(n) = n ∈ (0, 1) ? 1 : fn(n-2) + fn(n-1) # slow!
        n, str = 42, "It's a bird!"
        dd = Demo(Deferred() do 
                Base.sleep(2)
                str
            end, 
            Deferred() do 
                fn(n)
            end
        )
        @test !isassigned(dd.item1)
        @test dd.item1() == "It's a bird!"
        @test isassigned(dd.item1)
        @test !isassigned(dd.item2)
        @test dd.item2() == 433494437
        @test isassigned(dd.item2)
    end
end
