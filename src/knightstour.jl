"""
    knights_problem_old(nr_ranks = 8, nr_files = 8, nr_moves = nr_files * nr_ranks, start_square = [1, 1]; open_tour = false)
    
Generates (inefficient) CNF representation of the knight's tour problem.

When generating the CNF representation for an open tour, set `nr_moves` to `nr_files * nr_ranks - 1`.
"""
function knights_problem_old(
  nr_ranks = 8, nr_files = 8, nr_moves = nr_files * nr_ranks, 
  start_square = [1, 1]; open_tour = false
  )
  # Preliminaries --------------------------------------------------------------
  max_t = nr_moves + 1
  
  # Check if start_square is valid
  if !(start_square[1] in 1:nr_files) | !(start_square[2] in 1:nr_ranks)
    error("start square not on board")
  end
  
  # For creating readable variable names
  function paste(args...)
    return join(args, " ")
  end
  
  function move(x0, y0, x1, y1, time)
    return paste("move", "from", x0, y0, "to", x1, y1, "at time", time)
  end
  
  function on(x, y, time)
    return paste("on", x, y, "at time", time)
  end
  
  function visited(x, y, time)
    return paste("visisted", x, y, "at time", time)
  end
  
  # Move logic -----------------------------------------------------------------
  
  # Permissible knight moves
  knight_moves = hcat([
    [x0, y0, x1, y1]
    for x0 in 1:nr_files
    for y0 in 1:nr_ranks
    for x1 in 1:nr_files
    for y1 in 1:nr_ranks
    if abs(x1 - x0) >= 1 && abs(y1 - y0) >= 1 && abs(x1 - x0) + abs(y1 - y0) == 3
  ]...)'
  
  x0 = knight_moves[:, 1] 
  y0 = knight_moves[:, 2]
  x1 = knight_moves[:, 3] 
  y1 = knight_moves[:, 4]
  
  cnf = []
  
  for t in 1:(max_t - 1)
    # At least one move per turn -----------------------------------------------
    push!(cnf
    , Clause([move(x0[i], y0[i], x1[i], y1[i], t) for i in 1:length(x0)]
             , repeat([1], length(x0))))
    
    # At most one move per turn ------------------------------------------------
    for i in 1:(length(x0) - 1)
      for j in (i + 1):length(x0)
        push!(cnf
        , Clause([move(x0[i], y0[i], x1[i], y1[i], t)
                 , move(x0[j], y0[j], x1[j], y1[j], t)]
                 , [0, 0]))
      end
    end 
    
    for i in 1:length(x0)
      # Moves imply preconditions and effects ----------------------------------
      # note: We encode later that the knight can only be on one square at a
      # time, so we don't need to specify here that it's not on the source
      # square any longer.
      push!(cnf
      , Clause([move(x0[i], y0[i], x1[i], y1[i], t)
               , on(x0[i], y0[i], t)]
               , [0, 1]))
      push!(cnf
      , Clause([move(x0[i], y0[i], x1[i], y1[i], t)
              , on(x1[i], y1[i], t + 1)]
               , [0, 1]))
    end
    
    for x in unique(x0)
      for y in unique(y0)
      # Visited remains visited ------------------------------------------------
      push!(cnf
      , Clause([visited(x, y, t)
               , visited(x, y, t + 1)]
               , [0, 1]))
      
      # Newly visited implies on -----------------------------------------------
      # Prevents squares from becoming visited for no reason.
      push!(cnf
      , Clause([visited(x, y, t)
               , visited(x, y, t + 1)
               , on(x, y, t + 1)]
               , [1, 0, 1]))
      end
    end
  end
  
  # Square logic ---------------------------------------------------------------
  squares = hcat([[x, y] for x in 1:nr_files for y in 1:nr_ranks]...)'
  x = squares[:, 1]
  y = squares[:, 2]
  
  for t in 1:max_t
    # # Needs to be on a square --------------------------------------------------
    # # These clauses are superfluous (implied by initial state + 
    # # newly visited implies on)
    # push!(cnf
    # , Clause([paste("on", x[i], y[i], t) for i in 1:length(x)]
    #          , repeat([1], length(x))))
    
    # Only on one square -------------------------------------------------------
    for i in 1:(size(squares)[1] - 1)
      for j in (i+1):size(squares)[1]
        push!(cnf
        , Clause([on(x[i], y[i], t)
                 , on(x[j], y[j], t)]
                 , [0, 0]))
      end
    end
    
    # On implies visited -------------------------------------------------------
    for my_x in unique(x)
      for my_y in unique(y)
        push!(cnf
              , Clause([on(my_x, my_y, t)
                       , visited(my_x, my_y, t)]
                       , [0, 1]))
      end
    end
  end
  
  # Initial conditions ---------------------------------------------------------
  for i in 1:size(squares)[1]
    if (squares[i, :] == start_square)
      push!(cnf
      , Clause([on(x[i], y[i], 1)], [1]))
    else
      push!(cnf
      , Clause([visited(x[i], y[i], 1)], [0]))
    end
  end
  
  # Goal conditions ------------------------------------------------------------
  for i in 1:size(squares)[1]
    push!(cnf
    , Clause([visited(x[i], y[i], max_t)], [1]))
  end
  
  if (!open_tour)
    push!(cnf, Clause([on(start_square[1], start_square[2], max_t)], [1]))
  end

  return unique(cnf)
end

"""
    knights_problem(nr_ranks = 8, nr_files = 8, nr_moves = nr_files * nr_ranks, start_square = [1, 1]; open_tour = false)
    
Generates (more efficient) CNF representation of the knight's tour problem.

When generating the CNF representation for an open tour, set `nr_moves` to `nr_files * nr_ranks - 1`.
"""
function knights_problem(
  nr_ranks = 8, nr_files = 8, nr_moves = nr_files * nr_ranks, 
  start_square = [1, 1]; open_tour = false
  )
  # Preliminaries --------------------------------------------------------------
  max_t = nr_moves + 1
  
  # Check if start_square is valid
  if !(start_square[1] in 1:nr_files) | !(start_square[2] in 1:nr_ranks)
    error("start square not on board")
  end
  
  # Readable variable names
  function paste(args...)
    return join(args, " ")
  end
  
  function to(x1, y1, time)
    return paste("move to", x1, y1, "at time", time)
  end
  
  function on(x, y, time)
    return paste("on", x, y, "at time", time)
  end
  
  # Move logic *****************************************************************
  squares = hcat([
    [x, y]
    for x in 1:nr_files
    for y in 1:nr_ranks
  ]...)'
  
  x = squares[:, 1];
  y = squares[:, 2];
  cnf = []
  
  for t in 1:(max_t - 1)
    # At least one move per turn -----------------------------------------------             
    push!(cnf, Clause([to(x[i], y[i], t) for i in 1:length(x)]
                      , repeat([1], length(x))))             
    
    # At most one move per turn ------------------------------------------------
    for i in 1:(length(x) - 1)
      for j in (i + 1):length(x)
        push!(cnf, Clause([to(x[i], y[i], t), to(x[j], y[j], t)]
                          , [0, 0]))
      end
    end 
    
    for i in 1:length(x)
      # Effect -----------------------------------------------------------------
      # Note: We encode later that the knight can only be on one square at a
      # time, so we don't need to specify here that it's not on the source
      # square any longer.
      push!(cnf, Clause([to(x[i], y[i], t), on(x[i], y[i], t + 1)]
                        , [0, 1]))
      
      # Precondition (possible sources) ---------------------------------------- 
      sources = hcat([
        [x0, y0]
        for x0 in 1:nr_files
        for y0 in 1:nr_ranks
        if abs(x[i] - x0) >= 1 && abs(y[i] - y0) >= 1 && abs(x[i] - x0) + abs(y[i] - y0) == 3
      ]...)'
      source_x = sources[:, 1]
      source_y = sources[:, 2]
      
      push!(cnf, Clause(reduce(vcat, [to(x[i], y[i], t), on.(source_x, source_y, t)])
                        , reduce(vcat, [0, repeat([1], length(source_x))])))
    end
  end
  
  # Square logic ***************************************************************
  for t in 1:max_t
    # Knight can only be on one square -----------------------------------------
    # Note: We don't need to specify that the knight be on at least one square,
    # since this is implied by the initial state (knight on start square)
    # and the move logic (knight on some square after move).
    for i in 1:(length(x) - 1)
      for j in (i+1):length(x)
        push!(cnf, Clause([on(x[i], y[i], t), on(x[j], y[j], t)]
                          , [0, 0]))
      end
    end
  end
  
  # Initial conditions *********************************************************
  push!(cnf, Clause([on(start_square[1], start_square[2], 1)], [1]))
  
  # Goal conditions ************************************************************
  for i in 1:length(x)
    push!(cnf, Clause([on(x[i], y[i], t) for t in 1:max_t]
                      , repeat([1], max_t)))  
  end
  
  if (!open_tour)
    push!(cnf, Clause([on(start_square[1], start_square[2], max_t)], [1]))
  end

  return cnf
end
