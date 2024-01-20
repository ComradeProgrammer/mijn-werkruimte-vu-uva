using Distributed
@everywhere using Pkg
@everywhere Pkg.activate(@__DIR__,io=devnull)

using Test

@everywhere include("solution.jl")
nodes = 1




init_fun = beacon
m=6
n=6
M=1
N=1
steps=300
worldstep=1
a= game_check(init_fun,m,n,M,N,nodes,steps,worldstep)
println(a)