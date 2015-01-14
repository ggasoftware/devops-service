class Validators::Base

  def initialize(model, options={})
    @model = model
    @options = options
  end

  def validate!
    raise InvalidRecord.new(message) unless valid?
  end

  def valid?
    raise 'override me'
  end

  def message
    raise 'override me'
  end
end