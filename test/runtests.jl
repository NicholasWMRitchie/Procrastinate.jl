using Procrastinate
using Test

@testset "Procrastinate.jl" begin
    @testset "Basic" begin
        df = Deferred() do 
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
    @testset "Errors" begin
        @test_throws AssertionError Deferred(n->n^2)
        @test_throws AssertionError Deferred((n,m)->n*m)
    end
    @testset "In a struct" begin
        struct Demo
            item1::Deferred
            item2::Deferred
            Demo(d1::Deferred, d2::Deferred) = new(d1,d2)
        end
        fn(n) = n <= 1 ? one(typeof(n)) : fn(n-2) + fn(n-1) # slow!
        n, str = 42, "It's a bird!"
        dd = Demo(Deferred() do 
                Base.sleep(2)
                str
            end, 
            Deferred(()->fn(n)) # takes on the order of a second
        )
        @test !isassigned(dd.item1)
        @test dd.item1() == "It's a bird!"
        @test typeof(dd.item1()) == String
        @test isassigned(dd.item1)
        @test !isassigned(dd.item2)
        @test typeof(dd.item2()) == Int
        @test dd.item2() == 433494437
        @test isassigned(dd.item2)
    end
end
