require "dispatch"

Dispatch.configure do |config|
  config.num_workers = 5
  config.queue_size = 10
  config.logger = ::Logger.new(STDOUT).tap do |l|
    l.progname = "JOB"
    l.level = ENV["APP_ENV"] == "production" ? ::Logger::INFO : ::Logger::DEBUG
    l.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
      label = severity.unknown? ? "ANY" : severity.to_s
      io << label.rjust(5) << " -- " << progname << ": " << message
    end
  end
end
