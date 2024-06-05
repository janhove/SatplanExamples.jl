module SatplanExamples

include("clauses.jl")

export sussman
include("blocksworld.jl")

export knights_problem_old
export knights_problem
include("knightstour.jl")

export to_DIMACS
include("toDIMACS.jl")

export get_moves
export print_moves
export get_state
export print_state
export get_fullsolution
include("postprocessing.jl")

end
