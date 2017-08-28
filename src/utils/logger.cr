require "logger"

module Utils::Logger
  @@logger_progname : String = ""

  getter logger : ::Logger { ::Logger.new(STDOUT).tap { |l| l.progname = @@logger_progname; l.level = logger_level; l.formatter = logger_formatter } }

  def logger_level
    ENV["APP_ENV"] == "production" ? ::Logger::INFO : ::Logger::DEBUG
  end

  def logger_formatter
    ::Logger::Formatter.new do |severity, datetime, progname, message, io|
      label = severity.unknown? ? "ANY" : severity.to_s
      io << label.rjust(5) << " -- " << progname << ": " << message
    end
  end
end
