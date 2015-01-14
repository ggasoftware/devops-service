require "db/mongo/models/mongo_model"
require "db/exceptions/invalid_record"
require "commands/deploy_env"

class DeployEnvMulti < MongoModel

  include DeployEnvCommands

  attr_accessor :identifier, :servers, :expires, :users

  types :identifier => {:type => String, :empty => false},
        :expires => {:type => String, :empty => false, :nil => true},
        :users => {:type => Array, :empty => true},
        :servers => {:type => Array, :empty => false, :value_type => Hash}

  def initialize d={}
    self.identifier = d["identifier"]
    self.expires = d["expires"]
    self.servers = d["servers"]
    b = d["users"] || []
    self.users = (b.is_a?(Array) ? b.uniq : b)
  end

  def validate!
    super
    e = []
    check_users!(self.users)
    unless self.expires.nil?
      check_expires!(self.expires)
    end
    self.servers.each_with_index do |server, i|
      begin
        if server["priority"].nil?
          server["priority"] = 100
        else
          begin
            Integer(server["priority"])
          rescue ArgumentError, TypeError
            raise InvalidRecord.new("Parameter 'priority' should be an integer")
          end
        end

        if !server["subprojects"].is_a?(Array) or server["subprojects"].empty?
          raise InvalidRecord.new("Parameter 'subprojects' must be a not empty array")
        end
        if server["subprojects"].size > 1
          check_provider(server["provider"])
          # strings
          %w{image flavor provider}.each do |p|
            begin
              check_string!(server[p])
            rescue ArgumentError
              raise InvalidRecord.new("Parameter '#{p}' must be a not empty string")
            end
          end
          # arrays
          %w{subnets groups}.each do |p|
            begin
              raise ArgumentError if !server[p].is_a?(Array) or server[p].empty?
              server[p].each do |v|
                raise ArgumentError unless v.is_a?(String)
              end
            rescue ArgumentError
              raise InvalidRecord.new("Parameter '#{p}' must be a not empty array of strings")
            end
          end

          p = ::Provider::ProviderFactory.get(server["provider"])
          check_flavor!(p, server["flavor"])
          check_image!(p, server["image"])
          check_subnets_and_groups!(p, server["subnets"], server["groups"])
        end
        names = {}
        server["subprojects"].each_with_index do |sp, spi|
          begin
            raise InvalidRecord.new("Parameter 'subprojects' must contains objects only") unless sp.is_a?(Hash)
            %w{name env}.each do |p|
              begin
                check_string!(sp[p])
              rescue ArgumentError
                raise InvalidRecord.new("Parameter '#{p}' must be a not empty string")
              end
            end
          rescue  InvalidRecord => e
            raise InvalidRecord.new("Subproject '#{spi}'. #{e.message}")
          end
        end
        pdb = DevopsService.mongo.project_names_with_envs(server["subprojects"].map{|sp| sp["name"]})
        server["subprojects"].each_with_index do |sp, spi|
          raise InvalidRecord.new("Subproject '#{spi}'. Project '#{sp["name"]}' with env '#{sp["env"]}' does not exist") if pdb[sp["name"]].nil? or !pdb[sp["name"]].include?(sp["env"])
        end
      rescue InvalidRecord => e
        raise InvalidRecord.new("Server '#{i}'. #{e.message}")
      end
    end
    true
  rescue InvalidRecord => e
    raise InvalidRecord.new "Deploy environment '#{self.identifier}'. " + e.message
  end

  def to_hash
    {
      "identifier" => self.identifier,
      "expires" => self.expires,
      "users" => self.users,
      "servers" => self.servers
    }
  end

  def self.create_from_bson d
    DeployEnvMulti.new(d)
  end

  def self.create hash
    DeployEnvMulti.new(hash)
  end

end
