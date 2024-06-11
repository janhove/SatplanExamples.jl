function extract_turn(s::String)
    number = match(r"\d+$", s)
    
    return number !== nothing ? parse(Int, number.match) : 0
end

"""
    get_moves(solution, codebook)
    
Extract moves from SAT solver's solution.

The solution is a plain text file with the SAT solver's output.
The codebook is the one created when outputting the CNF to the DIMACS format.
"""
function get_moves(solution, codebook)
  state = get_fullsolution(solution, codebook)
  moves = state[first.(state, 4) .== "move"]
  
  return sort(moves, by = extract_turn)
end

"""
    print_moves(solution, codebook)
    
Print all moves from SAT solver's solution to the prompt.

The solution is a plain text file with the SAT solver's output.
The codebook is the one created when outputting the CNF to the DIMACS format.
"""
function print_moves(solution, codebook)
  soln = get_moves(solution, codebook)
  show(stdout, "text/plain", soln)
end

"""
    print_state(solution, codebook, turn)
    
Print the SAT solver's solution's state at the indicated turn to the prompt.

The solution is a plain text file with the SAT solver's output.
The codebook is the one created when outputting the CNF to the DIMACS format.
"""
function print_state(solution, codebook, turn)
  show(stdout, "text/plain", get_state(solution, codebook, turn))
end

"""
    get_fullsolution(solution, codebook)
    
Extract the full solution from the SAT solver's output.

The solution is a plain text file with the SAT solver's output.
The codebook is the one created when outputting the CNF to the DIMACS format.
"""
function get_fullsolution(solution, codebook)
  variables = [line for line in eachline(codebook)]
  soln = read(solution, String)
  soln = parse.(Int, split(soln))[1:end .!= end] # throw away final 0
  state = variables[soln .> 0]
  
  return state
end

"""
    print_fullsolution(solution, codebook)
    
Print the full solution from the SAT solver's output to the prompt.

The solution is a plain text file with the SAT solver's output.
The codebook is the one created when outputting the CNF to the DIMACS format.
"""
function print_fullsolution(solution, codebook)
  soln = get_fullsolution(solution, codebook)
  show(stdout, "text/plain", soln)
end

"""
    get_state(solution, codebook, turn)
    
Extract the SAT solver's solution's state at the indicated turn.

The solution is a plain text file with the SAT solver's output.
The codebook is the one created when outputting the CNF to the DIMACS format.
"""
function get_state(solution, codebook, turn)
  state = get_fullsolution(solution, codebook)
  state_at_turn = state[extract_turn.(state) .== turn .&& first.(state, 4) .!= "move"]
  
  return state_at_turn
end
