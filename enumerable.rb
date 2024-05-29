# frozen_string_literal: true

class Pipeline
  # Enumerable pipeline, the only difference is that instead of giving whole input to processor,
  # it maps values to give processor each item and returns an array of results.
  class Enumerable < Pipeline
    private

    def execute(process, arity)
      if arity == 2
        data.map { |data| process.call(data, Interruptor) }
      else
        data.map { |data| process.call(data) }
      end
    end
  end
end
