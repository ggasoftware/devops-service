root = File.join(File.dirname(__FILE__), "..")
$LOAD_PATH.push root unless $LOAD_PATH.include? root

require "sidekiq"
require "sidekiq/api"

require "fileutils"

require "db/mongo/mongo_connector"
require "providers/provider_factory"

class Worker
  include Sidekiq::Worker

  module STATUS
    INIT = "init"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
  end

  def convert_config conf
    config = {}
    conf.each {|k,v| config[k.is_a?(String) ? k.to_sym : k] = v}
    logger.debug "Config: #{config.inspect}"
    config
  end

  def mongo_connector config
    mongo = MongoConnector.new(config[:mongo_db], config[:mongo_host], config[:mongo_port], config[:mongo_user], config[:mongo_password])
    logger.debug "Mongo connector: #{mongo.inspect}"
    mongo
  end

  def set_status id, status
    Sidekiq.redis {|con| con.hset "devops", id, status}
  end

  def call conf, e_provider, dir
    FileUtils.mkdir_p(dir) unless File.exists?(dir)
    set_status jid, "init"
    config = convert_config(conf)
    file = File.join(dir, jid)
    error = nil
    mongo = nil
    provider = nil
    begin
      mongo = mongo_connector(config)
      unless e_provider.nil?
        ::Provider::ProviderFactory.init(config)
        provider = ::Provider::ProviderFactory.get(e_provider)
      end
    rescue Exception => e
      error = e
    end
    File.open(file, "w") do |out|
      begin
        set_status jid, STATUS::RUNNING
        raise error unless error.nil?
        status = yield(mongo, provider, out, file)
        status = (status == 0 ? STATUS::COMPLETED : STATUS::FAILED)
        set_status jid, status
        mongo.set_report_status(jid, status)
        status
      rescue Exception => e
        out << "\n"
        out << e.message
        out << "\n"
        out << e.backtrace.join("\n")
        set_status jid, STATUS::FAILED
        mongo.set_report_status(jid, STATUS::FAILED) unless mongo.nil?
      end
    end
  end

end
