require "logger"

module Utils::Logger
  getter logger : ::Logger { ::Logger.new(STDOUT).tap &.level = logger_level }

  def logger_level
    ENV["APP_ENV"] == "production" ? ::Logger::INFO : ::Logger::DEBUG
  end
end
