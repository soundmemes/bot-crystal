require "../environment"
require "uri"
require "../initializers/dispatch/schedule_jobs"
require "../soundmemes/telegram_bot/bot"
require "../soundmemes/version"

Log.info("Launching Soundmemes version #{Soundmemes::VERSION}")

begin
  schedule_jobs

  uri = URI.new(scheme: "https", host: ENV["BOT_WEBHOOK_HOST"])

  bot = Soundmemes::TelegramBot::Bot.new(
    token: ENV["BOT_API_TOKEN"],
    port: ENV["PORT"].to_i,
    logger: Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG },
  )
  bot.set_webhook(uri)
  bot.listen
ensure
  db.close
end
