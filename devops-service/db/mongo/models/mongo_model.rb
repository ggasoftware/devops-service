require "providers/provider_factory"
require "db/exceptions/invalid_record"
require "json"

class MongoModel

  def to_json
    JSON.pretty_generate self.to_hash
  end

  def to_hash
    h = to_hash_without_id
    h["id"] = self.id
    h
  end

  def to_mongo_hash
    h = to_hash_without_id
    h["_id"] = self.id
    h
  end

  def is_empty? val
    val.nil? or val.strip.empty?
  end

  def check_string! val
    raise ArgumentError unless val.is_a?(String)
    val.strip!
    raise ArgumentError if val.empty?
  end

  def check_array! val, type, empty=false
    raise ArgumentError unless val.is_a?(Array)
    raise ArgumentError if !empty and val.empty?
    val.each do |v|
      raise ArgumentError unless v.is_a?(type)
    end
  end

  def check_name_value val
    raise ArgumentError.new "Invalid name, it should contains 0-9, a-z, A-Z, _, - symbols only" if val.match(/^[0-9a-zA-Z_\-]+$/).nil?
  end

  def check_provider provider=self.provider
    unless ::Version2_0::Provider::ProviderFactory.providers.include?(provider) or provider == "static"
      raise InvalidRecord.new "Invalid provider '#{provider}'"
    end
  end

  # types - Hash
  #   key - param name
  #   value - Hash
  #     :type - param type
  #     :empty - can param be empty? (false)
  #     :nil - can param be nil? (false)
  #     :value_type - type of array element (String)
  def self.types types
    define_method :validate do
      t = types.keys
      e = types.keys
      n = types.keys
      types.each do |name, value|
        if value[:nil]
          n.delete(name)
          if self.send(name).nil?
            e.delete(name)
            t.delete(name)
            next
          end
        else
          n.delete(name) unless self.send(name).nil?
        end
        if self.send(name).is_a? value[:type]
          t.delete(name)
          self.send(name).strip! if value[:type] == String
          if value[:type] == Array
            unless value[:value_type] == false
              type = value[:value_type] || String
              self.send(name).each do |e|
                unless e.is_a?(type)
                  t.push(name)
                  break
                end
              end
            end
          end
          e.delete(name) if value[:empty] or !self.send(name).empty?
        end
      end
      raise InvalidRecord.new "Parameter(s) '#{n.join("', '")}' can not be undefined" unless n.empty?
      raise InvalidRecord.new "Parameter(s) '#{t.join("', '")}' have invalid type(s)" unless t.empty?
      raise InvalidRecord.new "Parameter(s) '#{e.join("', '")}' can not be empty" unless e.empty?
      if types.has_key? :provider
        self.send("check_provider")
      end
      true
    end
  end

  def validate!
    self.validate
  end

end
