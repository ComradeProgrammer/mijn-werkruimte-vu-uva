using MPI
using JSON
MPI.Init()

function rand_distance_table(N)
  threshold = 0.2
  mincost = 3
  maxcost = 10
  infinity = 10000*maxcost
  C = fill(infinity,N,N)
  for j in 1:N
    for i in 1:N
      if rand() > threshold
        C[i,j] = rand(mincost:maxcost)
      end
    end
    C[j,j] = 0
  end
  C
end

function floyd_seq!(C)
    N = size(C, 1)
    @assert size(C, 2) == N
    t = @elapsed begin
        @inbounds for k in 1:N 
           for j in 1:N
                ckj = C[k,j]
                for i in 1:N
                    C[i, j] = min(C[i, j], C[i, k] + ckj)
                end
            end
        end
    end
    C, t
end
  
function floyd_par!(f!,C,N,comm)
    nranks = MPI.Comm_size(comm)
    rank = MPI.Comm_rank(comm)
    T = eltype(C)
    if rank == 0
        buffer_root = Vector{T}(undef,N*N)
        buffer_root[:] = transpose(C)[:]
    else
        buffer_root = Vector{T}(undef,0)
    end    
    Nw = div(N,nranks)
    buffer =  Vector{T}(undef,Nw*N)
    MPI.Scatter!(buffer_root,buffer,comm;root=0)
    Cw = Matrix{T}(undef,Nw,N)
    transpose(Cw)[:] = buffer
    MPI.Barrier(comm)
    t = @elapsed f!(Cw,comm)
    buffer[:] = transpose(Cw)[:]
    MPI.Gather!(buffer,buffer_root,comm;root=0)
    Tf = typeof(t)
    if rank == 0
        transpose(C)[:] = buffer_root[:]
        ts = Vector{Tf}(undef,nranks)
    else
        ts = Vector{Tf}(undef,0)
    end
    MPI.Gather!([t],ts,comm;root=0)
    C, ts
end

function floyd_worker_barrier!(Cw,comm)
    # Implement here your solution for method 1 of Floyd's parallel algotrithm #
    # Your MPI.Send can use any tag that you wish #
    # Your MPI.Recv! can only use  MPI.ANY_SOURCE as source, and MPI.ANY_TAG as tag values #
    # You are only allowed to use MPI.Send, MPI.Recv! and MPI.Barrier for this part#
    m,n = size(Cw)
    nranks = MPI.Comm_size(comm)
    rank = MPI.Comm_rank(comm)
    start_row = m*rank+1
    end_row = m*(rank+1)
    row_k = similar(Cw,n)
    for k in 1:n
        # find correct row k first
        if start_row<=k && k<=end_row
            @inbounds row_k.=view(Cw,k-start_row+1,:)
            # send out the row_k
            for proc in 0:(nranks-1)
                if rank != proc
                    MPI.Send(row_k,comm;dest=proc,tag=0)
                end
            end
        else
            MPI.Recv!(row_k,comm,source=MPI.ANY_SOURCE,tag=MPI.ANY_TAG)
        end
        # floyd method
        for j in 1:n
            for i in 1:m
                @inbounds Cw[i,j] = min(Cw[i,j],Cw[i,k]+row_k[j])
            end
        end
        # wait for all other processes in this round
        if k%m==0
            MPI.Barrier(comm)
        end
    end

end

function floyd_worker_bcast!(Cw,comm)
    # Implement here your solution for method 2 of Floyd's parallel algotrithm #
    # Attetion: the worker who is sending needs be the root of the Broadcast #
    # You are only allowed to use the MPI.Bcast! collective for this part #
    m,n = size(Cw)
    nranks = MPI.Comm_size(comm)
    rank = MPI.Comm_rank(comm)
    start_row = m*rank+1
    end_row = m*(rank+1)
    row_k = similar(Cw,n)
    for k in 1:n
        # find correct row k first
        if start_row<=k && k<=end_row
        @inbounds row_k.=view(Cw,k-start_row+1,:)
        end
        MPI.Bcast!(row_k,div(k-1,m),comm)
        # floyd method
        for j in 1:n
            for i in 1:m
                @inbounds Cw[i,j] = min(Cw[i,j],Cw[i,k]+row_k[j])
            end
        end
       
    end
    
end

function floyd_worker_status!(Cw,comm)
    # Implement here your solution for method 3 of Floyd's parallel algotrithm #
    # Your MPI.Send can use any tag that you wish #
    # Your MPI.Recv! can only use  MPI.ANY_SOURCE as source, and MPI.ANY_TAG as tag values #
    # You can use MPI.STATUS in your MPI.RECV! #
    # You are only allowed to use MPI.Send and MPI.Recv! and MPI.Status #
    m,n = size(Cw)
    nranks = MPI.Comm_size(comm)
    rank = MPI.Comm_rank(comm)
    start_row = m*rank+1
    end_row = m*(rank+1)
    row_k = similar(Cw,n)
    T = eltype(Cw)
    cache = Vector{Vector{T}}(undef,n)
    for k in 1:n
        # find correct row k first
        if start_row<=k && k<=end_row
            @inbounds row_k.=view(Cw,k-start_row+1,:)
            # send out the row_k
            for proc in 0:(nranks-1)
                if rank != proc
                    MPI.Send(row_k,comm;dest=proc,tag=k)
                end
            end
        else
            while !isassigned(cache,k)
                (_,status)=MPI.Recv!(row_k,MPI.ANY_SOURCE,MPI.ANY_TAG,comm,MPI.Status)   
                cache[status.tag]=copy(row_k)
            end
            @inbounds row_k=cache[k]
        end
        # floyd method
        for j in 1:n
            for i in 1:m
                @inbounds Cw[i,j] = min(Cw[i,j],Cw[i,k]+row_k[j])
            end
        end
        # wait for all other processes in this round

    end
    
end

const methods = (
    floyd_worker_barrier!,
    floyd_worker_bcast!,
    floyd_worker_status!)

function main_check(;N,method)
    comm = MPI.Comm_dup(MPI.COMM_WORLD)
    rank = MPI.Comm_rank(comm)
    nranks = MPI.Comm_size(comm)
    f = methods[method]
    if rank == 0
        C = rand_distance_table(N) 
    else
        C = rand_distance_table(0)
    end
    C_par, t_par = floyd_par!(f,copy(C),N,comm)
    if rank == 0
        C_seq, t_seq = floyd_seq!(copy(C))
        correct = C_seq == C_par
        if ! correct
            @warn "Incorrect result"
        end
        dict = Dict("P"=>nranks,"N"=>N,"method"=>method,"correct"=>correct)
        JSON.print(stdout,dict)
        println("")
        file="check_P_$(nranks)_N_$(N)_method_$(method).json"
        open(file,"w") do f
            JSON.print(f,dict) 
        end
    end
end

function main_run(;N,method,R)
    comm = MPI.Comm_dup(MPI.COMM_WORLD)
    rank = MPI.Comm_rank(comm)
    nranks = MPI.Comm_size(comm)
    if rank == 0
        C = rand_distance_table(N) 
    else
        C = rand_distance_table(0)
    end
    ## Run several times
    for r in 0:R
        if method != 0
            f = methods[method]
            _, t = floyd_par!(f,copy(C),N,comm)
        else
            _, t_seq = floyd_seq!(copy(C))
            t = [t_seq]
        end
        if rank == 0 && r != 0
            dict = Dict("r"=>r,"P"=>nranks,"N"=>N,"method"=>method,"time"=>t)
            JSON.print(stdout,dict)
            println("")
            file="run_r_$(r)_P_$(nranks)_N_$(N)_method_$(method).json"
            open(file,"w") do f
                JSON.print(f,dict) 
            end
        end
    end
end

