# frozen_string_literal: true

# Pipeline is heavily inspired by function composition. It was built to allow you to make a sequence of "processors"
# to operate with input. Each "processor" in a sequence takes a result of a previous as an input.
#
# @example Basic usage
#   pipe = Pipeline.new
#   pipe.add(&:to_i)
#   pipe.add { |number| number * 2 }
#   pipe << IncrementService # passing on object requires a #call method to be present on it
#   pipe.process('2') # => 5
#
# @example Using +.process+ block:
#   Pipeline.process('2') do |pipe|
#     pipe.add(&:to_i)
#     pipe.add { |number| number * 2 }
#     pipe << IncrementService
#   end # => 5
#
# @example With chaining:
#   Pipeline.new.add(Parser).add(Multiplier).add(Incrementor).process('2')
#
# @example When input is single value, but you wanna iterate over object in a middle, use +#each+:
#   Pipeline.process('[[1, 2], [5, 2]]') do |pipe|
#     pipe.add(JSON.method(:parse))
#     pipe.each do |enumerated_pipe|
#       enumerated_pipe.add { |chunk| chunk.sum }
#     end
#   end # => [3, 7]
