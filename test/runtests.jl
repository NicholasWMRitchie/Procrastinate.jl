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
        df = Deferred(String) do 
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
end
