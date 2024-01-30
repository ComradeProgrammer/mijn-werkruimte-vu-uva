using Distributed
using Plots
using JSON

glider() = [(1,3),(2,3),(3,3),(2,1),(3,2)]

function gun()
    [
     (5, 1), (5, 2),
     (6, 1), (6, 2),
     (3,13), (3,14),
     (4,12), (4,16),
     (5,11), (5,17),
     (6,11), (6,15),
     (6,17), (6,18),
     (7,11), (7,17),
     (8,12), (8,16),
     (9,13), (9,14),
     (1,25), (7,25),
     (2,23), (2,25),
     (3,21), (3,22),
     (4,21), (4,22),
     (5,21), (5,22),
     (6,23), (6,25),
     (3,35), (3,36),
     (4,35), (4,36)
    ]
end

# This one is a periodic pattern
function beacon()
    [
     (1,1),(1,2),(2,1),
     (3,4),(4,3),(4,4),
    ]
end

# this one is static
function block()
    [(2,2),(2,3),(3,2),(3,3)]
end

function game_serial(init_fun,m,n,steps,worldstep,irun=1)
    params = (;init_fun,m,n,steps,worldstep,irun)
    fn = "serial_$(nameof(init_fun))_$(m)_$(n)_$(steps)_$(worldstep)_run_$irun"
    if worldstep == 0 # No animation
        game_serial_impl(nothing,fn,params)
    else # Animation
        # we follow a producer-consumer model to generate the animation
        # Note that this is a regular channel, not a remote one
        chnl_anim = Channel{Matrix{Int32}}()
        t = @async begin
            # The game of life is the producer
            try
                game_serial_impl(chnl_anim,fn,params)
            finally
                close(chnl_anim)
            end
        end
        # This loop consumes chnl_anim to generate the animation
        anim = @animate for a_anim in chnl_anim
            plot_state(a_anim)
        end
        wait(t)
        gif(anim,fn*".gif",fps=25)
    end
end

function game_serial_impl(chnl_anim,fn,params)
    (;init_fun,m,n,steps,worldstep,irun) = params
    a = Matrix{Int32}(undef,m+2,n+2)
    initial_coords = init_fun()
    init!(initial_coords,a,1:m,1:n)
    a_new = similar(a)
    a_history = [similar(a),similar(a)]
    final_step = steps
    wall_time = time()
    for istep in 1:steps
        step_serial!(a_new,a)
        tmp = a
        a = a_new
        a_new = a_history[2]
        a_history[2] = a_history[1]
        a_history[1] = tmp
        if worldstep != 0 && (istep % worldstep) == 0
            put!(chnl_anim,a[2:end-1,2:end-1])
        end
        if has_cycled(a,a_history,istep)
            final_step = istep
            break
        end
    end
    wall_time = time()-wall_time
    dict = Dict{Symbol,Any}()
    dict[:m] = m
    dict[:n] = n
    dict[:steps] = steps
    dict[:worldstep] = worldstep
    dict[:irun] = irun
    dict[:init_fun] = nameof(init_fun)
    dict[:wall_time] = wall_time
    dict[:final_step] = final_step
    print_results(dict)
    fn_json = fn*".json"
    open(fn_json,"w") do f
        JSON.print(f,dict) 
    end
    @info "Results file has been generated: $fn_json"
end

function print_results(dict)
    println("Results")
    for (k,v) in sort(collect(dict), by = x->x[1])
        println("    ",k,": ",v)
        end
end

function plot_state(a;kwargs...)
    m,n = size(a)
    plt = plot(;framestyle=:box)
    yflip = true
    xmirror=true
    colorbar=:none
    c=palette(:blues,2)
    heatmap!(1:n,1:m,a;yflip,colorbar,c,xmirror,kwargs...)
    plt
end

function init!(coords,a,rows,cols)
    a .= 0
    for (gi,gj) in coords
        if gi in rows && gj in cols
            i = searchsortedfirst(rows,gi)
            j = searchsortedfirst(cols,gj)
            a[i+1,j+1] = 1
        end
    end
    a
end

function step_serial!(a_new,a)
    update_ghost_serial!(a)
    update!(a_new,a)
end

function update_ghost_serial!(a)
    m,n = size(a)
    for i in 2:(m-1)
        a[i,1] = a[i,end-1]
        a[i,end] = a[i,2]
    end
    for j in 2:(n-1)
        a[1,j] = a[end-1,j]
        a[end,j] = a[2,j]
    end
    a[1,1] = a[end-1,end-1]
    a[1,end] = a[end-1,2]
    a[end,1] = a[2,end-1]
    a[end,end] = a[2,2]
    a
end

function update!(a_new,a)
    @inbounds for j in 2:(size(a,2)-1)
        for i in 2:(size(a,1)-1)
            a_new[i,j] = rules(a,i,j)
        end
    end
end

Base.@propagate_inbounds function rules(a,i,j)
    X = a[i,j]
    N = a[i+0,j-1]
    S = a[i+0,j+1]
    E = a[i+1,j+0]
    W = a[i-1,j+0]
    NE = a[i+1,j-1]
    NW = a[i-1,j-1]
    SE = a[i+1,j+1]
    SW = a[i-1,j+1]
    n_live_neigs = N+S+E+W+NE+NW+SE+SW
    if n_live_neigs == 3
        return Int32(1)
    elseif n_live_neigs == 2
        return Int32(X)
    else
        return Int32(0)
    end
end

function sum_interior_cells(a)
    s = zero(eltype(a))
    @inbounds for j in 2:(size(a,2)-1)
        for i in 2:(size(a,1)-1)
            s += a[i,j]
        end
    end
    s
end

function has_cycled(a,a_history,istep)
    r1 = interior_cells_are_equal(a,a_history[1])
    r1 || (istep>1 && interior_cells_are_equal(a,a_history[2]))
end

function interior_cells_are_equal(a,b)
    @inbounds for j in 2:(size(a,2)-1)
        for i in 2:(size(a,1)-1)
            if a[i,j] != b[i,j]
                return false
            end
        end
    end
    return true
end

function game_parallel(init_fun,m,n,M,N,nodes,steps,worldstep,irun=1)
    params = (;init_fun,m,n,M,N,nodes,steps,worldstep,irun)
        fn = "parallel_$(nameof(init_fun))_$(m)_$(n)_$(M)_$(N)_$(nodes)_$(steps)_$(worldstep)_run_$irun"
    if worldstep == 0 # No animation
        game_parallel_impl(nothing,fn,params)
    else # Animation
        # we follow a producer-consumer model to generate the animation
        # Note that this is a regular channel, not a remote one
        chnl_anim = Channel{Matrix{Int32}}()
        t = @async begin
            # The game of life is the producer
            try
                game_parallel_impl(chnl_anim,fn,params)
            finally
                close(chnl_anim)
            end
        end
        # This loop consumes chnl_anim to generate the animation
        anim = @animate for a_anim in chnl_anim
            plot_state(a_anim)
        end
        wait(t)
        gif(anim,fn*".gif",fps=25)
    end
end

function game_parallel_impl(chnl_anim,fn,params)
    (;init_fun,m,n,M,N,nodes,steps,worldstep,irun) = params
    check_input(m,n,M,N)
    ftrs_chnls = create_channels(M,N)
    chnl_world = RemoteChannel(()->Channel{Any}(1))
    chnl_ides=Matrix{Any}(undef,M,N)
    ftrs_results = Matrix{Future}(undef,M,N)
    for J in 1:N
        for I in 1:M
            chnl_ide=RemoteChannel(()->Channel{Any}()) 
            chnl_ides[I,J]=chnl_ide
            channels = (;ftrs_chnls,chnl_world,chnl_ide)
            p = LinearIndices(ftrs_chnls)[I,J]
            w = workers()[p]
            ftrs_results[I,J] = @spawnat w begin
                game_worker(I,J,fn,params,channels)
            end
        end
    end
    final_step = steps
    for istep in 1:steps
        identical=true
        identical2=true
        if worldstep != 0 && (istep % worldstep) == 0
            a = Matrix{Int32}(undef,m,n)
            for _ in 1:(M*N)
                my_a, my_rows, my_cols = take!(chnl_world)
                a[my_rows,my_cols] = my_a
            end
            put!(chnl_anim,a)
        end

        for J in 1:N
            for I in 1:M
                ide,ide2=take!(chnl_ides[I,J])
                identical=identical&& ide
                identical2=identical2&& ide2
            end
        end

        if identical || identical2
            close(chnl_world)
            break
        end
    end
    wall_time = fetch.(ftrs_results[:])
    # print/output the results in JSON format
    dict = Dict{Symbol,Any}()
    dict[:m] = m
    dict[:n] = n
    dict[:M] = M
    dict[:N] = N
    dict[:nodes] = nodes
    dict[:steps] = steps
    dict[:worldstep] = worldstep
    dict[:wall_time] = wall_time
    dict[:final_step] = final_step
    dict[:irun] = irun
    dict[:init_fun] = nameof(init_fun)
    print_results(dict)
    fn_json = fn*".json"
    open(fn_json,"w") do f
        JSON.print(f,dict) 
    end
    @info "Results file has been generated: $fn_json"
end

function step_send!(a,send_chnls)
    x_size=size(a,1)
    y_size=size(a,2)
    @sync begin
    @async @inbounds put!(send_chnls[1,1],view(a,2,2))# NW
    @async @inbounds put!(send_chnls[1,2],view(a,2,2:y_size-1))# N
    @async @inbounds put!(send_chnls[1,3],view(a,2,y_size-1))# NE

    @async @inbounds put!(send_chnls[2,1],view(a,2:x_size-1,2)) #W
    @async @inbounds put!(send_chnls[2,3],view(a,2:x_size-1,y_size-1))#W

    @async @inbounds put!(send_chnls[3,1],view(a,x_size-1,2))# SW
    @async @inbounds put!(send_chnls[3,2],view(a,x_size-1,2:y_size-1))# S
    @async @inbounds put!(send_chnls[3,3],view(a,x_size-1,y_size-1))# SE
    end
end

function game_worker(I,J,fn,params,channels)
    (;init_fun,m,n,M,N,steps,worldstep) = params
    (;ftrs_chnls,chnl_world,chnl_ide) = channels
    chnls_snd, chnls_rcv = create_chnls_snd_and_rcv(M,N,I,J,ftrs_chnls)
    my_rows = local_range(I,m,M)
    my_cols = local_range(J,n,N)
    my_m = length(my_rows)
    my_n = length(my_cols)
    a = Matrix{Int32}(undef,my_m+2,my_n+2)
    initial_coords = init_fun()
    init!(initial_coords,a,my_rows,my_cols)
    # we need to send edge information at initial stage
    # println("start, ",a)
    step_send!(a,chnls_snd)
    a_new = similar(a)
    a_history = [similar(a),similar(a)]
    wall_time = time()
    for istep in 1:steps
        step_worker!(a_new,a,chnls_snd,chnls_rcv)
        # check whether it is identical
        identical= interior_cells_are_equal(a_new,a) 
        identical2= interior_cells_are_equal(a_new,a_history[1])

        #identical=(view(a_new,2:size(a,1)-1,2:size(a,2)-1)==view(a,2:size(a,1)-1,2:size(a,2)-1))
        #identical2=(view(a_new,2:size(a,1)-1,2:size(a,2)-1)==view(a_history[1],2:size(a,1)-1,2:size(a,2)-1))
        tmp = a
        a = a_new
        a_new = a_history[2]
        a_history[2] = a_history[1]
        a_history[1] = tmp
        if !isopen(chnl_world)
            break
        end

        try
            if worldstep != 0 && (istep % worldstep) == 0
                put!(chnl_world,(a[2:end-1,2:end-1],my_rows,my_cols))
            end
        catch
            break
        end
        put!(chnl_ide,(identical,identical2))
    end
    wall_time = time()-wall_time
    return wall_time
end

function check_input(m,n,M,N)
    if mod(m,M) != 0
        error("m=$m should be multiple of M=$M")
    end
    if mod(n,N) != 0
        error("n=$n should be multiple of N=$N")
    end
    if nworkers() < N*M
        error("Not enough workers. M*N=$(M*N) but nworkers()=$(nworkers())")
    end
end

function create_channels(M,N)
    ftrs_chnls = Matrix{Future}(undef,M,N)
    @sync for J in 1:N
        for I in 1:M
            p = LinearIndices(ftrs_chnls)[I,J]
            w = workers()[p]
            ftrs_chnls[I,J] = @spawnat w begin
                buffer = 10
                f = () -> Channel{Any}(buffer)
                [RemoteChannel(f) for i in -1:1, j in -1:1]
            end
        end
    end
    ftrs_chnls
end

function local_range(p,n,np)
    @assert mod(n,np) == 0
    load = div(n,np)
    offset = load*(p-1)
    start = offset + 1
    stop = offset + load
    start:stop
end

function periodic(i,n)
    i < 1 && return n-i
    i > n && return i-n
    i
end

function create_chnls_snd_and_rcv(M,N,I,J,ftrs_chnls)
    chnls_rcv = fetch(ftrs_chnls[I,J])
    chnls_snd = similar(chnls_rcv)
    # Implement here
    dx=[-1,0,1,-1,1,-1,0,1]
    dy=[-1,-1,-1,0,0,1,1,1]
    for i in 1:size(dx)[1]
        neighbor_x=(I+dx[i])%M
        if neighbor_x<=0
            neighbor_x+=M
        end
        neighbor_y=(J+dy[i])%N
        if neighbor_y<=0
            neighbor_y+=N
        end
        chnls_neighbor_rcv = fetch(ftrs_chnls[neighbor_x,neighbor_y])
        chnls_snd[2+dx[i],2+dy[i]]=chnls_neighbor_rcv[2-dx[i],2-dy[i]]
    end
    chnls_snd, chnls_rcv
end

function step_worker!(a_new,a,chnls_snd,chnls_rcv)
    # Implement here
    # read from the channels
    #println("a: ",a)
    @sync begin
        @async @inbounds a[1,1]=take!(chnls_rcv[1,1])[1]# NW
        @async @inbounds a[1,2:end-1]=take!(chnls_rcv[1,2])[1:end] # N
        @async @inbounds a[1,end]=take!(chnls_rcv[1,3])[1]# NE
        @async @inbounds a[2:end-1,1]=take!(chnls_rcv[2,1])[1:end] #W
        @async @inbounds a[2:end-1,end]=take!(chnls_rcv[2,3])[1:end] #E
        @async @inbounds a[end,1]=take!(chnls_rcv[3,1])[1]# SW
        @async @inbounds a[end,2:end-1]=take!(chnls_rcv[3,2])[1:end] # S
        @async @inbounds a[end,end]=take!(chnls_rcv[3,3])[1]# SE
        @async begin
            @inbounds for j in 3:(size(a,2)-2)
                for i in 3:(size(a,1)-2)
                    a_new[i,j] = rules(a,i,j)
                end
            end
        end
    end
    # println("a: ",a)
    # calculate
    #update!(a_new,a)
    @inbounds for j in 2:(size(a,2)-1)
        for i in [2,size(a,1)-1]
            a_new[i,j] = rules(a,i,j)
        end
    end
    @inbounds for j in [2,size(a,2)-1]
        for i in 2:(size(a,1)-1)
            a_new[i,j] = rules(a,i,j)
        end
    end
    step_send!(a_new,chnls_snd)
    # println("a_new: ",a_new)

end

function game_check(init_fun,m,n,M,N,nodes,steps,worldstep,irun=1)
    worldstep = 1
    params = (;init_fun,m,n,M,N,nodes,steps,worldstep,irun)
    chnl_serial = Channel{Matrix{Int32}}()
    t = @async begin
        try
            fn = "test_serial_$(nameof(init_fun))_$(m)_$(n)_$(steps)_$(worldstep)_run_$irun"
            game_serial_impl(chnl_serial,fn,params)
        finally
            close(chnl_serial)
        end
    end
    a_serial = [ copy(i) for i in chnl_serial ]
    wait(t)
    chnl_parallel = Channel{Matrix{Int32}}()
    t = @async begin
        try
            fn = "test_parallel_$(nameof(init_fun))_$(m)_$(n)_$(M)_$(N)_$(steps)_$(worldstep)_run_$irun"
            game_parallel_impl(chnl_parallel,fn,params)
        finally
            if isopen(chnl_parallel)
                close(chnl_parallel)
            end
        end
    end
    a_parallel = [ copy(i) for i in chnl_parallel ]
    wait(t)
    #println("a_parallel ",a_parallel)
    #println("a_parallel ",size(a_parallel))
    #println("a_serial ",a_serial)
    #println("a_serial ",size(a_serial))

    a_parallel == a_serial
end
