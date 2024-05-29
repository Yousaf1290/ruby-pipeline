class Pipeline
  using PrivateAccessors

  class ProcessNext < StandardError; end
  class Stop < StandardError; end

  class << self
    # Combines .new and #process in a single method
    #
    # @param data [Object] input
    # @yieldparam [Pipeline] pipeline instance
    # @return [Object, nil] output
    def process(data)
      pipeline = new
      yield(pipeline)
      pipeline.process(data)
    end

    def each(data)
      pipeline = Enumerable.new
      yield(pipeline)
      pipeline.process(data)
    end
  end

  attr_reader :data, :processors
  pattr_writer :data

  def initialize
    @data = nil
    @processors = []
  end

  # Add a processor to a chain, returns +self+ to allow chaining.
  # You allowed to pass either on object responding to +#call+ or just use classic block.
  #
  # @param processor [Object] an object responding to +#call+
  # @param block [Proc] a block (have bigger priority, so if both object and block passed - the block would be executed)
  # @return [Pipeline]
  def add_processor(processor = nil, &block)
    processors << (block.presence || processor)
    self
  end
  alias add add_processor
  alias << add_processor

  # Add an enumerable sub-pipeline. The data should respond to +#map+ in order to make it work.
  # So it would use each item given by +#map+ as individual values for processors inside.
  # Returns +self+ to allow chaining
  #
  # @param block [Proc]
  # @yieldparam [Pipeline::Enumerable] enumerable pipe
  # @return [Pipeline]
  def add_enumerable(&block)
    processors << Enumerable.new.tap(&block)
    self
  end
  alias each add_enumerable

  # Run the pipeline with given +data+
  #
  # @param data [Object] input
  # @return [Object, nil] output
  def process(data)
    self.data = data
    flush
    self.data
  end
  # To make sub-pipes (such as Enumerable) work exactly the same way as processors, we expose +#call+.
  alias call process
  # But it's only for internal usage, so we make it protected.
  protected :call

  private

  def flush
    processors.each do |process|
      self.data = execute(process, arity(process))
    rescue ProcessNext
      next
    end
  end

  def execute(process, arity)
    if arity == 2
      process.call(data, Interruptor)
    else
      process.call(data)
    end
  end

  def arity(process)
    process.is_a?(Proc) ? process.arity : process.method(:call).arity
  end
end
