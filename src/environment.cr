ENV["APP_ENV"] ||= "development"

require "dotenv"
Dotenv.load ".env.#{ENV["APP_ENV"]}" rescue nil

require "./helpers"

require "./initializers/db"
require "./initializers/dispatch/dispatch"

Log = Logger.new(STDOUT)
Log.level = ENV["APP_ENV"] == "production" ? Logger::INFO : Logger::DEBUG
