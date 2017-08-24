require "./environment"
require "uri"
require "./utils/logger"
require "../initializers/dispatch/schedule_jobs"
require "../soundmemes/telegram_bot/bot"
require "../soundmemes/version"

logger = Logger.new(STDOUT).tap { |l| l.level = Utils::Logger.logger_level }
logger.info "Launching Soundmemes version #{Soundmemes::VERSION}"

begin
  schedule_jobs

  uri = URI.new(scheme: "https", host: ENV["BOT_WEBHOOK_HOST"])

  bot = Soundmemes::TelegramBot::Bot.new(
    token: ENV["BOT_API_TOKEN"],
    host: "0.0.0.0",
    port: ENV["PORT"].to_i,
    logger: logger,
  )
  bot.set_webhook(uri, allowed_updates: %w(message inline_query chosen_inline_result callback_query))
  bot.listen
ensure
  db.close
end
