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

#-> m { -> n { n[ADD[m]][ZERO] } }[-> p { -> x { p[p[x]] } }][-> p { -> x { p[p[p[p[p[x]]]]]}}],-> m { -> n { n[ADD[m]][ZERO] } }[-> p { -> x { p[p[x]] } }][-> p { -> x { p[p[p[p[p[x]]]]]}}],F,I,ZED以外

solution =
-> k { -> f { -> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[-> f { -> l { -> x { -> g { -> b { b }[-> p { p[-> x { -> y { x } } ] }[l]][x][-> y { g[f[-> l { -> p { p[-> x { -> y { y } } ]}[-> p { p[-> x { -> y { y } } ]}[l]] }[l]][x][g]][-> l { -> p { p[-> x { -> y { x } } ] }[-> p { p[-> x { -> y { y } } ]}[l]] }[l]][y] } ] } } } }][k][-> x { -> y { -> f { f[x][y] } } }[-> x { -> y { x } }][-> x { -> y { x } }]][-> l { -> x { -> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[l][f[x]] } } ]  } }[-> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[-> f {-> m { ->n { -> b { b }[-> m { -> n { -> n { n[-> x { -> x { -> y { y } } }][-> x { -> y { x } }] }[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }][m] } }[m][n]] } }[m][n]][-> x { -> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[f[-> n { -> p { -> x { p[n[p][x]] } } }[m]][n]][m][x] } ][-> x { -> y { -> f { f[x][y] } } }[-> x { -> y { x } }][-> x { -> y { x } }]] } } }][-> p { -> x { p[x] } }][-> p { -> x { p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]}}]][-> n {
  -> b { b }[-> n { n[-> x { -> x { -> y { y } } }][-> x { -> y { x } }] }[-> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[->f { -> m { -> n { -> b { b }[-> m { -> n { -> n { n[-> x { -> x { -> y { y } } }][-> x { -> y { x } }] }[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }][m] } }[m][n]] } }[n][m]][-> x { f[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }][m] } }[m][n]][n][x] } ][m] } } }][n][-> p { -> x { p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]]]]]]}}]]][
    -> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> x { -> y { -> f { f[x][y] } } }[-> x { -> y { x } }][-> x { -> y { x } }]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][-> n { -> p { -> x { p[n[p][x]] } } }[I]]][-> m { -> n { n[ADD[m]][ZERO] } }[-> p { -> x { p[p[x]] } }][-> p { -> x { p[p[p[p[p[x]]]]]}}]]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][I]][F]
  ][-> b { b }[-> n { n[-> x { -> x { -> y { y } } }][-> x { -> y { x } }] }[-> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[->f { -> m { -> n { -> b { b }[-> m { -> n { -> n { n[-> x { -> x { -> y { y } } }][-> x { -> y { x } }] }[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }][m] } }[m][n]] } }[n][m]][-> x { f[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }][m] } }[m][n]][n][x] } ][m] } } }][n][-> p { -> x { p[p[p[x]]] } }]]][
    -> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> x { -> y { -> f { f[x][y] } } }[-> x { -> y { x } }][-> x { -> y { x } }]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][I]][F]
  ][-> b { b }[-> n { n[-> x { -> x { -> y { y } } }][-> x { -> y { x } }] }[-> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[->f { -> m { -> n { -> b { b }[-> m { -> n { -> n { n[-> x { -> x { -> y { y } } }][-> x { -> y { x } }] }[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }][m] } }[m][n]] } }[n][m]][-> x { f[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }][m] } }[m][n]][n][x] } ][m] } } }][n][-> p { -> x { p[p[p[p[p[x]]]]]}}]]][
    -> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> x { -> y { -> f { f[x][y] } } }[-> x { -> y { x } }][-> x { -> y { x } }]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][-> n { -> p { -> x { p[n[p][x]] } } }[-> n { -> p { -> x { p[n[p][x]] } } }[I]]]][-> n { -> p { -> x { p[n[p][x]] } } }[I]]][-> m { -> n { n[ADD[m]][ZERO] } }[-> p { -> x { p[p[x]] } }][-> p { -> x { p[p[p[p[p[x]]]]]}}]]
  ][
    -> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[-> f { -> n { -> l { -> x { -> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[-> f { -> l { -> x { -> g { -> b { b }[-> p { p[-> x { -> y { x } } ] }[l]][x][-> y { g[f[-> l { -> p { p[-> x { -> y { y } } ]}[-> p { p[-> x { -> y { y } } ]}[l]] }[l]][x][g]][-> l { -> p { p[-> x { -> y { x } } ] }[-> p { p[-> x { -> y { y } } ]}[l]] }[l]][y] } ] } } } }][l][-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }[-> x { -> y { -> f { f[x][y] } } }[-> x { -> y { x } }][-> x { -> y { x } }]][x]][-> l { -> x { -> x { -> y { -> f { f[x][y] } } }[-> x { -> y { y } }][-> x { -> y { -> f { f[x][y] } } }[x][l]] } }]  }  }[-> b { b }[-> m { -> n { -> n { n[-> x { -> x { -> y { y } } }][-> x { -> y { x } }] }[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }][m] } }[m][n]] } }[n][-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }[-> m { -> n { n[ADD[m]][ZERO] } }[-> p { -> x { p[p[x]] } }][-> p { -> x { p[p[p[p[p[x]]]]]}}]]]][-> x { -> y { -> f { f[x][y] } } }[-> x { -> y { x } }][-> x { -> y { x } }]][-> x { f[-> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[-> f { -> m { -> n { -> b { b }[-> m { -> n { -> n { n[-> x { -> x { -> y { y } } }][-> x { -> y { x } }] }[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }][m] } }[m][n]] } }[n][m]][-> x { -> n { -> p { -> x { p[n[p][x]] } } }[f[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }][m] } }[m][n]][n]][x] } ][-> p { -> x { x } }] } } }][n][-> m { -> n { n[ADD[m]][ZERO] } }[-> p { -> x { p[p[x]] } }][-> p { -> x { p[p[p[p[p[x]]]]]}}]]][x] } ] ][-> f { -> x { f[-> y { x[x][y] }] }[-> x { f[->y { x[x][y] }] }] }[->f { -> m { -> n { -> b { b }[-> m { -> n { -> n { n[-> x { -> x { -> y { y } } }][-> x { -> y { x } }] }[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }][m] } }[m][n]] } }[n][m]][-> x { f[-> m { -> n { n[-> n { -> p { p[-> x { -> y { x } } ] }[n[-> p { -> x { -> y { -> f { f[x][y] } } }[-> p { p[-> x { -> y { y } } ]}[p]][-> n { -> p { -> x { p[n[p][x]] } } }[-> p { p[-> x { -> y { y } } ]}[p]]] }][-> x { -> y { -> f { f[x][y] } } }[-> p { -> x { x } }][-> p { -> x { x } }]]] }][m] } }[m][n]][n][x] } ][m] } } }][n][-> m { -> n { n[ADD[m]][ZERO] } }[-> p { -> x { p[p[x]] } }][-> p { -> x { p[p[p[p[p[x]]]]]}}]]] } }][n]
  ]]] 
}]

to_array(solution).each do |p|
  puts to_string(p)
end; nil