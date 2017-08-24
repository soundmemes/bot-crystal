require "logger"

module Utils::Logger
  getter logger : ::Logger do
    ::Logger.new(STDOUT).tap do |l|
      l.level = ENV["APP_ENV"] == "production" ? ::Logger::INFO : ::Logger::DEBUG
    end
  end

  class_getter logger : ::Logger do
    ::Logger.new(STDOUT).tap { |l| l.level = logger_level }
  end

  def self.logger_level
    ENV["APP_ENV"] == "production" ? ::Logger::INFO : ::Logger::DEBUG
  end
end
