require "rack/deflater"

class ConditionalDeflater
  def initialize(app, &condition)
    @app, @condition = app, condition
    @deflater = Rack::Deflater.new(app)
  end

  def call(env)
    if @condition && @condition.call(env)
      @deflater.call(env)
    else
      @app.call(env)
    end
  end
end
