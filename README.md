# Pipeline

Pipeline is heavily inspired by function composition. It was built to allow you to create a sequence of "processors" to operate with input. Each "processor" in a sequence takes the result of the previous processor as its input.

## Basic Usage

```ruby
pipe = Pipeline.new
pipe.add(&:to_i)
pipe.add { |number| number * 2 }
pipe << IncrementService # passing an object requires a #call method to be present on it
pipe.process('2') # => 5
```

## Using .process Block

```ruby
Pipeline.process('2') do |pipe|
  pipe.add(&:to_i)
  pipe.add { |number| number * 2 }
  pipe << IncrementService
end # => 5
```

## With Chaining

```ruby
Pipeline.new.add(Parser).add(Multiplier).add(Incrementor).process('2')
```

## Iterating Over an Object Mid-Process

```ruby
Pipeline.process('[[1, 2], [5, 2]]') do |pipe|
  pipe.add(JSON.method(:parse))
  pipe.each do |enumerated_pipe|
    enumerated_pipe.add { |chunk| chunk.sum }
  end
end # => [3, 7]
```

Feel free to explore and extend the functionality of the Pipeline to suit your specific needs!
