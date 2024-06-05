function to_DIMACS(cnf, file, codebook)
    n = length(cnf)
    
    # Dictionary for variable indices
    variables = unique(vcat([clause.vars for clause in cnf]...))
    variable_indices = Dict(zip(variables, 1:length(variables)))  

    # Write codebook
    open(codebook, "w") do io
        write(io, join(variables, "\n"))
    end

    # Write CNF formula
    open(file, "w") do io
        write(io, "p cnf $(length(variables)) $n\n")

        for clause in cnf
            line = [clause.pol[l] == 1 ? variable_indices[clause.vars[l]] : -variable_indices[clause.vars[l]] 
                    for l in 1:length(clause.vars)]
            write(io, join(line, " "), " 0\n")
        end
    end
end

"""
	to_DIMACS(my_cnf, "my_cnf.cnf", "my_cnf.code")
Exports set of clauses to its DIMACS representation. 
Feed the .cnf file to a SAT solver and use the .code file to during postprocessing.
"""
