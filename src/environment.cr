ENV["APP_ENV"] ||= "development"

require "dotenv"
Dotenv.load ".env.#{ENV["APP_ENV"]}" rescue nil

require "./initializers/db"
require "./initializers/dispatch/dispatch"
