require 'treetop'
require './lambda_calculus'

parser= LambdaCalculusParser.new
result = parser.parse('-> x { x[x] } [-> y { y }]')
p result.get