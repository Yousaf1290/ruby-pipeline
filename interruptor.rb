# frozen_string_literal: true

class Pipeline
  module Interruptor
    module_function

    def next! = raise ProcessNext

    def stop!(message = nil) = raise Stop, message || 'pipeline processing was interrupted!'
  end
end
