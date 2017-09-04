require "crecto"
require "../../services/db"

Query = Crecto::Repo::Query

module Soundmemes
  module Repo
    extend Crecto::Repo

    config do |conf|
      conf.crecto_db = db
    end
  end
end

Crecto::DbLogger.set_handler(STDOUT) unless ENV["APP_ENV"] == "production"
