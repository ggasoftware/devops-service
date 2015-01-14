require 'json'

class FixtureFormatter

  def initialize(fixtures)
    @fixtures = fixtures
  end

  def json(path, options={})
    result = JSON.pretty_generate(get_fixture(path))
    if options[:spaces]
      result = shift_to_right(result, options[:spaces])
    end
    result
  end

  private

  def get_fixture(path)
    keys = path.split('/')
    hash = @fixtures
    keys.each do |key|
      hash = hash[key]
    end
    hash
  end

  def shift_to_right(text, spaces_count)
    buffer = ''
    first_line = true
    text.each_line do |line|
      if first_line
        first_line = false
        buffer += line
        next
      end
      buffer += (' ' * spaces_count) + line
    end
    buffer
  end
end