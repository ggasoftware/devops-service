require "mongo"
require "db/exceptions/record_not_found"

class MongoUser

  def initialize(db, host, port=27017)
    @mongo_client = MongoClient.new(host, port)
    @db = @mongo_client.db(db)
    @users = @db.collection("users")
  end

  def user username, password
    u = @users.find("_id" => username, "password" => password).to_a[0]
    raise RecordNotFound.new("User '#{username}' does not exist") if u.nil?
    u
  end

end
