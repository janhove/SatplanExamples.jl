"""
    sussman(nr_moves = 3)
    
Generate CNF representation of Sussman's anomaly, to be solved in the desired number of moves.
"""
function sussman(nr_moves = 3)

  NR_BLOCKS = 3
  
  function paste(args...)
    return join(args, " ")
  end
  
  function move(block, from, to, time)
    return paste("move", block, "from", from, "to", to, "at time", time)
  end
  
  function on(top, bottom, time)
    return paste(top, "on", bottom, "at time", time)
  end
  
  function clear(block, time)
    return paste(block, "clear at time", time)
  end
  
  # Possible moves -------------------------------------------------------------
  # Change this if you want to create blocks world problems with more than
  # three blocks.
  moves = permutedims(hcat([
    [x, y, z]
    for x in ["A", "B", "C"]
    for y in ["A", "B", "C", "table"]
    for z in ["A", "B", "C", "table"]
    if x != y && x != z && y != z
  ]...))
  
  x = moves[:, 1] 
  y = moves[:, 2]
  z = moves[:, 3] 
  
  cnf = []
  
  for t in 1:nr_moves
    # At least one move per turn -----------------------------------------------
    push!(cnf
    , Clause([move(x[i], y[i], z[i], t) for i in 1:length(x)]
             , repeat([1], length(x))))
             
    # At most one move per turn ------------------------------------------------
    for i in 1:(length(x) - 1)
      for j in (i+1):length(x)
        push!(cnf
        , Clause([move(x[i], y[i], z[i], t), move(x[j], y[j], z[j], t)]
                 , [0, 0]))
      end
    end
    
    # Table is always clear.
    push!(cnf
    , Clause([clear("table", t)], [1]))
    
    for i in 1:length(x)
      # Moves imply preconditions and effects ----------------------------------

      # Object should be clear -------------------------------------------------
      push!(cnf
      , Clause([move(x[i], y[i], z[i], t), clear(x[i], t)]
               , [0, 1]))
      
      # Target should be clear -------------------------------------------------
      push!(cnf
      , Clause([move(x[i], y[i], z[i], t), clear(z[i], t)]
               , [0, 1]))
               
      # Object should be on source ---------------------------------------------
      push!(cnf
      , Clause([move(x[i], y[i], z[i], t), on(x[i], y[i], t)]
               , [0, 1]))
               
      # Source should be clear afterwards --------------------------------------
      push!(cnf
      , Clause([move(x[i], y[i], z[i], t), clear(y[i], t + 1)]
               , [0, 1]))
      
      # Target shouldn't be clear afterwards, except if table ------------------
      if (z[i] == "table")
      else 
        push!(cnf
        , Clause([move(x[i], y[i], z[i], t), clear(z[i], t + 1)]
                 , [0, 0]))
      end
               
      # Object should be on target afterwards ----------------------------------
      push!(cnf
      , Clause([move(x[i], y[i], z[i], t), on(x[i], z[i], t + 1)]
               , [0, 1]))
               
      # Object shouldn't be on source afterwards -------------------------------
      push!(cnf
      , Clause([move(x[i], y[i], z[i], t), on(x[i], y[i], t + 1)]
               , [0, 0]))
    end
    
    for i in 1:length(x)
      # Changes imply moves ----------------------------------------------------
      # on, then not on: move away
      top = x[i]
      bottom = y[i]
      possible_targets = unique(z[(x .== x[i]) .& (y .== y[i])])
      push!(cnf
      , Clause(reduce(vcat, [on(top, bottom, t), on(top, bottom, t + 1)
                            , move.(top, bottom, possible_targets, t)]), 
               reduce(vcat, [0, 1, repeat([1], length(possible_targets))])))
      
      # not on, then on: move to
      possible_sources = possible_targets
      push!(cnf
      , Clause(reduce(vcat, [on(top, bottom, t), on(top, bottom, t + 1)
                            , move.(top, possible_sources, bottom, t)]), 
               reduce(vcat, [1, 0, repeat([1], length(possible_sources))])))
    
      # not clear, then clear: move away
      possible_targets = z[y .== y[i]]
      possible_sources = possible_targets
      possible_objects = x[y .== y[i]]
      push!(cnf
      , Clause(reduce(vcat, [clear(bottom, t), clear(bottom, t + 1)
                            , move.(possible_objects, bottom, possible_targets, t)]), 
               reduce(vcat, [1, 0, repeat([1], length(possible_targets))])))
               
      # clear, then not clear: move to
      push!(cnf
      , Clause(reduce(vcat, [clear(bottom, t), clear(bottom, t + 1)
                            , move.(possible_objects, possible_sources, bottom, t)]), 
               reduce(vcat, [0, 1, repeat([1], length(possible_sources))])))
    end
  end
  
  # Initial state --------------------------------------------------------------
  push!(cnf, Clause([on("A", "table", 1)], [1]))
  push!(cnf, Clause([on("A", "B", 1)], [0]))
  push!(cnf, Clause([on("A", "C", 1)], [0]))
  push!(cnf, Clause([clear("A", 1)], [0]))
  
  push!(cnf, Clause([on("B", "table", 1)], [1]))
  push!(cnf, Clause([on("B", "A", 1)], [0]))
  push!(cnf, Clause([on("B", "C", 1)], [0]))
  push!(cnf, Clause([clear("B", 1)], [1]))
  
  push!(cnf, Clause([on("C", "table", 1)], [0]))
  push!(cnf, Clause([on("C", "A", 1)], [1]))
  push!(cnf, Clause([on("C", "B", 1)], [0]))
  push!(cnf, Clause([clear("C", 1)], [1]))
  
  push!(cnf, Clause([clear("table", 1)], [1]))
  
  # Goal state ------------------------------------------------------------------
  push!(cnf, Clause([on("A", "B", nr_moves + 1)], [1]))
  push!(cnf, Clause([on("A", "C", nr_moves + 1)], [0]))
  push!(cnf, Clause([on("A", "table", nr_moves + 1)], [0]))
  push!(cnf, Clause([clear("A", nr_moves + 1)], [1]))
  
  push!(cnf, Clause([on("B", "A", nr_moves + 1)], [0]))
  push!(cnf, Clause([on("B", "C", nr_moves + 1)], [1]))
  push!(cnf, Clause([on("B", "table", nr_moves + 1)], [0]))
  push!(cnf, Clause([clear("B", nr_moves + 1)], [0]))
  
  push!(cnf, Clause([on("C", "A", nr_moves + 1)], [0]))
  push!(cnf, Clause([on("C", "B", nr_moves + 1)], [0]))
  push!(cnf, Clause([on("C", "table", nr_moves + 1)], [1]))
  push!(cnf, Clause([clear("B", nr_moves + 1)], [0]))
  
  push!(cnf, Clause([clear("table", nr_moves + 1)], [1]))
  
  # Return ---------------------------------------------------------------------
  return cnf
end
