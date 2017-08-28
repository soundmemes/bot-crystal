require "./environment"
require "uri"
require "./utils/logger"
require "./initializers/dispatch/schedule_jobs"
require "../soundmemes/telegram_bot/bot"
require "../soundmemes/version"

class Server
  include Utils::Logger
  @@logger_progname = "SERVER"

  def initialize(bot_api_token token, host, port, @webhook_host : URI)
    @bot = Soundmemes::TelegramBot::Bot.new(token, port, logger, host: host)
  end

  def run
    logger.info "Running Soundmemes Bot version %s" % Soundmemes::VERSION
    @bot.set_webhook(@webhook_host, allowed_updates: %w(message inline_query chosen_inline_result callback_query))
    @bot.listen
  end
end

server = Server.new(
  bot_api_token: ENV["BOT_API_TOKEN"],
  host: "0.0.0.0",
  port: ENV["PORT"].to_i,
  webhook_host: URI.new(scheme: "https", host: ENV["BOT_WEBHOOK_HOST"]),
)

schedule_jobs
server.run
