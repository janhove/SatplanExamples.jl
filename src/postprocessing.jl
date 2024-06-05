function extract_turn(s::String)
    number = match(r"\d+$", s)
    
    return number !== nothing ? parse(Int, number.match) : 0
end

"""
    get_moves(solution, codebook)
    
Extract moves from SAT solver's solution.
"""
function get_moves(solution, codebook)
  state = get_fullsolution(solution, codebook)
  moves = state[first.(state, 4) .== "move"]
  
  return sort(moves, by = extract_turn)
end

function print_moves(solution, codebook)
  soln = get_moves(solution, codebook)
  show(stdout, "text/plain", soln)
end

function print_state(solution, codebook, turn)
  show(stdout, "text/plain", get_state(solution, codebook, turn))
end

function get_fullsolution(solution, codebook)
  variables = [line for line in eachline(codebook)]
  soln = read(solution, String)
  soln = parse.(Int, split(soln))[1:end .!= end] # throw away final 0
  state = variables[soln .> 0]
  
  return state
end

function get_state(solution, codebook, turn)
  state = get_fullsolution(solution, codebook)
  state_at_turn = state[extract_turn.(state) .== turn .&& first.(state, 4) .!= "move"]
  
  return state_at_turn
end
