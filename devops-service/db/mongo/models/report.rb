require "db/exceptions/invalid_record"
require "db/mongo/models/mongo_model"

class Report < MongoModel

  DEPLOY_TYPE = 1
  SERVER_TYPE = 2
  BOOTSTRAP_TYPE = 3
  PROJECT_TEST_TYPE = 4

  attr_accessor :id, :file, :created_at, :created_by, :project, :deploy_env, :type

  def initialize r
    self.id = r["_id"]
    self.file = r["file"]
    self.created_by = r["created_by"]
    self.project = r["project"]
    self.deploy_env = r["deploy_env"]
    self.type = r["type"]
    self.created_at = r["created_at"]
  end

  def to_hash_without_id
    {
      "file" => self.file,
      "created_at" => self.created_at,
      "created_by" => self.created_by,
      "project" => self.project,
      "deploy_env" => self.deploy_env,
      "type" => self.type
    }
  end

end
