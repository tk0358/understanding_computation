ZERO  = -> p { -> x {      x     } }
ONE   = -> p { -> x {     p[x]   } }
TWO   = -> p { -> x {   p[p[x]]  } }
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
# MOD = 
#   Z[->f { -> m { -> n {
#     IF[IS_LESS_OR_EQUAL[n][m]][
#       -> x { 
#         f[SUBTRACT[m][n]][n][x]
#       }
#     ][
#       m
#     ]
#   } } }]

EMPTY    = PAIR[TRUE][TRUE]
UNSHIFT  = -> l { -> x {
             PAIR[FALSE][PAIR[x][l]]
           } }
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

TEN = MULTIPLY[TWO][FIVE]

# RANGE =
#   Z[-> f {
#     -> m { ->n { 
#       IF[IS_LESS_OR_EQUAL[m][n]][
#         -> x {
#         UNSHIFT[f[INCREMENT[m]][n]][m][x]
#         }
#       ][
#         EMPTY
#       ]
#     } }
#   }]

def decrease(m, n)
  if n <= m
    m-n
  else
    m
  end
end

MOD =
  -> m { -> n {
    m[-> x {
      IF[IS_LESS_OR_EQUAL[n][x]][
        SUBTRACT[x][n]
      ][
        x
      ]
    }][m]
  }}

def countdown(pair)
  [pair.first.unshift(pair.last), pair.last - 1]
end

COUNTDOWN = -> p { PAIR[UNSHIFT[LEFT[p]][RIGHT[p]]][DECREMENT[RIGHT[p]]] }

RANGE = -> m { -> n { LEFT[INCREMENT[SUBTRACT[n][m]][COUNTDOWN][PAIR[EMPTY][n]]] } }