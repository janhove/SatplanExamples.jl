# Represents a disjunction of literals.
struct Clause
  vars::Vector{String}
  pol::Vector{Int}
end

# Clauses are the same (and hash the same) if they 
# contains the same literals (in the same order).
Base.:(==)(a::Clause, b::Clause) = a.vars == b.vars && a.pol == b.pol
Base.hash(a::Clause, h::UInt) = hash(a.vars, hash(a.pol, hash(:Clause, h)))
