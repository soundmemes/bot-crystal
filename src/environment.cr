ENV["APP_ENV"] ||= "development"

require "dotenv"
Dotenv.load ".env.#{ENV["APP_ENV"]}" rescue nil
