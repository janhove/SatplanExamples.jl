# SatplanExamples

This is a [Julia](https://julialang.org/) package for generating
logical formulas in conjunctive normal form (CNF) that represent
two kinds of simple planning problems.
The first is Sussman's anomaly, a classic toy problem from the
blocks world.
The second is finding (closed and open) knight's tours in chess.

## Installation
In Julia, enter the package manager (`]`) and install the package from GitHub:

```
pkg> add https://github.com/janhove/SatplanExamples.jl
```

## Use

Exit the package manager (backspace) and load the package:

```
julia> using SatplanExamples
```

To generate a CNF representation for solving Sussman's anomaly in three moves, use

```
julia> my_cnf = sussman(3);
```

The `my_cnf` object can be exported to the DIMACS format required by SAT solvers:

```
julia> to_DIMACS(my_cnf, "sussman.cnf", "sussman.code");
```

Feed the `sussman.cnf` file to a SAT solver of your choice.
Store the solver's output, e.g., as `sussman.soln`, and put it in your Julia working directory.
Then you can extract the moves like so:

```
julia> print_moves("sussman.soln", "sussman.code");
3-element Vector{String}:
 "move C from A to table at time 1"
 "move B from table to C at time 2"
 "move A from table to B at time 3"
```

To construct a CNF representation for a closed knight's tour on a 5-by-6 board starting on C2, use

```
julia> my_cnf = knights_problem(5, 6, 5*6, [3, 2]);
julia> to_DIMACS(my_cnf, "knight5by6.cnf", "knight5by6.code");
```

The solution file can be postprocessed like so:

```
julia> print_moves("knight5by6.soln", "knight5by6.code");
30-element Vector{String}:
 "move to 2 4 at time 1"
 "move to 4 5 at time 2"
 "move to 6 4 at time 3"
 "move to 5 2 at time 4"
 "move to 3 1 at time 5"
 "move to 1 2 at time 6"
 "move to 3 3 at time 7"
 "move to 2 1 at time 8"
 "move to 1 3 at time 9"
 "move to 2 5 at time 10"
 "move to 4 4 at time 11"
 "move to 6 5 at time 12"
 "move to 5 3 at time 13"
 "move to 6 1 at time 14"
 "move to 4 2 at time 15"
 "move to 5 4 at time 16"
 "move to 6 2 at time 17"
 "move to 4 1 at time 18"
 "move to 2 2 at time 19"
 "move to 1 4 at time 20"
 "move to 3 5 at time 21"
 "move to 4 3 at time 22"
 "move to 5 1 at time 23"
 "move to 6 3 at time 24"
 "move to 5 5 at time 25"
 "move to 3 4 at time 26"
 "move to 1 5 at time 27"
 "move to 2 3 at time 28"
 "move to 1 1 at time 29"
 "move to 3 2 at time 30"
```
