ZERO  = -> p { -> x { x } }
ONE   = -> p { -> x { p[x] } }
TWO   = -> p { -> x { p[p[x]] } }
THREE = -> p { -> x { p[p[p[x]]] } }
FIVE    = -> p { -> x { p[p[p[p[p[x]]]]]}}
FIFTEEN = -> p { -> x { p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]]]]]]}}
HUNDRED = -> p { -> x { p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]}}

def to_integer(proc)
  proc[-> n { n + 1 }][0]
end

TRUE  = -> x { -> y { x } }
FALSE = -> x { -> y { y } }

def to_boolean(proc)
  IF[proc][true][false]
end

IF = -> b { b }

IS_ZERO = -> n { n[-> x { FALSE }][TRUE] }

PAIR  = -> x { -> y { -> f { f[x][y] } } }
LEFT  = -> p { p[-> x { -> y { x } } ] }
RIGHT = -> p { p[-> x { -> y { y } } ]}

INCREMENT = -> n { -> p { -> x { p[n[p][x]] } } }

SLIDE     = -> p { PAIR[RIGHT[p]][INCREMENT[RIGHT[p]]] }
DECREMENT = -> n { LEFT[n[SLIDE][PAIR[ZERO][ZERO]]] }

ADD      = -> m { -> n { n[INCREMENT][m] } }
SUBTRACT = -> m { -> n { n[DECREMENT][m] } }
MULTIPLY = -> m { -> n { n[ADD[m]][ZERO] } }
POWER    = -> m { -> n { n[MULTIPLY[m]][ONE] } }

IS_LESS_OR_EQUAL = -> m { -> n { IS_ZERO[SUBTRACT[m][n]] } }

Z = -> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }
MOD = Z[->f { -> m { -> n { IF[IS_LESS_OR_EQUAL[n][m]][-> x { f[SUBTRACT[m][n]][n][x] } ][m] } } }]

EMPTY    = PAIR[TRUE][TRUE]
UNSHIFT  = -> l { -> x { PAIR[FALSE][PAIR[x][l]] } }
IS_EMPTY = LEFT
FIRST    = -> l { LEFT[RIGHT[l]] }
REST     = -> l { RIGHT[RIGHT[l]] }

def to_array(proc)
  array = []

  until to_boolean(IS_EMPTY[proc])
    array.push(FIRST[proc])
    proc = REST[proc]
  end

  array
end

RANGE = Z[-> f {-> m { ->n { IF[IS_LESS_OR_EQUAL[m][n]][-> x { UNSHIFT[f[INCREMENT[m]][n]][m][x] } ][EMPTY] } } }]

FOLD = Z[-> f { -> l { -> x { -> g { IF[IS_EMPTY[l]][x][-> y { g[f[REST[l]][x][g]][FIRST[l]][y] } ] } } } }]

MAP = -> k { -> f { FOLD[k][EMPTY][-> l { -> x { UNSHIFT[l][f[x]] } } ]  } }

TEN = MULTIPLY[TWO][FIVE]
B   = TEN
F   = INCREMENT[B]
I   = INCREMENT[F]
U   = INCREMENT[I]
ZED = INCREMENT[U]

FIZZ     = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][I]][F]
BUZZ     = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][U]][B]
FIZZBUZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[BUZZ][ZED]][ZED]][I]][F]

def to_char(c)
  '0123456789BFiuz'.slice(to_integer(c))
end

def to_string(s)
  to_array(s).map { |c| to_char(c) }.join
end

DIV = Z[-> f { -> m { -> n { IF[IS_LESS_OR_EQUAL[n][m]][-> x { INCREMENT[f[SUBTRACT[m][n]][n]][x] } ][ZERO] } } }]

PUSH = -> l { -> x { FOLD[l][UNSHIFT[EMPTY][x]][UNSHIFT]  }  }

TO_DIGITS = Z[-> f { -> n { PUSH[IF[IS_LESS_OR_EQUAL[n][DECREMENT[TEN]]][EMPTY][-> x { f[DIV[n][TEN]][x] } ] ][MOD[n][TEN]] } }]
#PAIRまで

solution =
-> k { -> f { -> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[-> f { -> l { -> x { -> g { IF[-> p { p[-> x { -> y { x } } ] }[l]][x][-> y { g[f[-> l { -> p { p[-> x { -> y { y } } ]}[-> p { p[-> x { -> y { y } } ]}[l]] }[l]][x][g]][-> l { -> p { p[-> x { -> y { x } } ] }[-> p { p[-> x { -> y { y } } ]}[l]] }[l]][y] } ] } } } }][k][-> x { -> y { -> f { f[x][y] } } }[TRUE][TRUE]][-> l { -> x { -> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[l][f[x]] } } ]  } }[-> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[-> f {-> m { ->n { IF[-> m { -> n { IS_ZERO[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }][m] } }[m][n]] } }[m][n]][-> x { -> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[f[-> n { -> p { -> x { p[n[p][x]] } } }[m]][n]][m][x] } ][-> x { -> y { -> f { f[x][y] } } }[TRUE][TRUE]] } } }][ONE][HUNDRED]][-> n {
  IF[-> n { n[-> x { FALSE }][TRUE] }[-> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[->f { -> m { -> n { IF[-> m { -> n { IS_ZERO[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }][m] } }[m][n]] } }[n][m]][-> x { f[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }][m] } }[m][n]][n][x] } ][m] } } }][n][FIFTEEN]]][
    -> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> x { -> y { -> f { f[x][y] } } }[TRUE][TRUE]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][-> n { -> p { -> x { p[n[p][x]] } } }[I]]][B]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][I]][F]
  ][IF[-> n { n[-> x { FALSE }][TRUE] }[-> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[->f { -> m { -> n { IF[-> m { -> n { IS_ZERO[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }][m] } }[m][n]] } }[n][m]][-> x { f[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }][m] } }[m][n]][n][x] } ][m] } } }][n][THREE]]][
    -> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> x { -> y { -> f { f[x][y] } } }[TRUE][TRUE]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][I]][F]
  ][IF[-> n { n[-> x { FALSE }][TRUE] }[-> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[->f { -> m { -> n { IF[-> m { -> n { IS_ZERO[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }][m] } }[m][n]] } }[n][m]][-> x { f[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }][m] } }[m][n]][n][x] } ][m] } } }][n][FIVE]]][
    -> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> x { -> y { -> f { f[x][y] } } }[TRUE][TRUE]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][-> n { -> p { -> x { p[n[p][x]] } } }[I]]][B]
  ][
    -> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[-> f { -> n { -> l { -> x { -> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[-> f { -> l { -> x { -> g { IF[-> p { p[-> x { -> y { x } } ] }[l]][x][-> y { g[f[-> l { -> p { p[-> x { -> y { y } } ]}[-> p { p[-> x { -> y { y } } ]}[l]] }[l]][x][g]][-> l { -> p { p[-> x { -> y { x } } ] }[-> p { p[-> x { -> y { y } } ]}[l]] }[l]][y] } ] } } } }][l][-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> x { -> y { -> f { f[x][y] } } }[TRUE][TRUE]][x]][-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[FALSE][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }]  }  }[IF[-> m { -> n { IS_ZERO[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }][m] } }[m][n]] } }[n][-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }[TEN]]][-> x { -> y { -> f { f[x][y] } } }[TRUE][TRUE]][-> x { f[-> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[-> f { -> m { -> n { IF[-> m { -> n { IS_ZERO[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }][m] } }[m][n]] } }[n][m]][-> x { -> n { -> p { -> x { p[n[p][x]] } } }[f[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }][m] } }[m][n]][n]][x] } ][-> p { -> x { x } }] } } }][n][TEN]][x] } ] ][-> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[->f { -> m { -> n { IF[-> m { -> n { IS_ZERO[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }][m] } }[m][n]] } }[n][m]][-> x { f[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[ZERO][ZERO]]] }][m] } }[m][n]][n][x] } ][m] } } }][n][TEN]] } }][n]
  ]]] 
}]

to_array(solution).each do |p|
  puts to_string(p)
end; nil