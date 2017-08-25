require "crecto"
require "../../services/db"

Query = Crecto::Repo::Query

module Soundmemes
  module Repo
    extend Crecto::Repo

    config do |conf|
      conf.adapter = Crecto::Adapters::Postgres
      conf.uri = ENV["DATABASE_URL"]
    end
  end
end
