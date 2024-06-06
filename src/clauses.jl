# Represents a disjunction of literals.
struct Clause
  vars::Vector{String}
  pol::Vector{Int}
end

function Base.:(==)(a::Clause, b::Clause)
    if length(a.vars) != length(b.vars) || length(a.pol) != length(b.pol)
        return false
    end
    indices_a = sortperm(a.vars)
    sorted_a_vars = a.vars[indices_a]
    sorted_a_pol = a.pol[indices_a]
    indices_b = sortperm(b.vars)
    sorted_b_vars = b.vars[indices_b]
    sorted_b_pol = b.pol[indices_b]
    return sorted_a_vars == sorted_b_vars && sorted_a_pol == sorted_b_pol
end

function Base.hash(a::Clause, h::UInt)
    indices = sortperm(a.vars)
    sorted_vars = a.vars[indices]
    sorted_pol = a.pol[indices]
    return hash(sorted_vars, hash(sorted_pol, hash(:Clause, h)))
end
