require "dispatch"

Dispatch.configure do |config|
  config.num_workers = 5
  config.queue_size = 10
  config.logger = ::Logger.new(STDOUT).tap do |l|
    l.level = ENV["APP_ENV"] == "production" ? ::Logger::INFO : ::Logger::DEBUG
  end
end
