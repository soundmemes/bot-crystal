require "telegram_bot"
require "colorize"
require "./actions/**"

module Soundmemes
  module TelegramBot
    class Bot < ::TelegramBot::Bot
      def initialize
        super(ENV["BOT_USERNAME"], ENV["BOT_API_TOKEN"], allowed_updates: ["message", "inline_query", "chosen_inline_result", "callback_query"])
      end

      def handle_update(u)
        Log.debug("Incoming update: #{u.to_json}")
        if msg = u.message
          return if !allowed_user?(msg)
          handle msg
        elsif query = u.inline_query
          return if !allowed_user?(query)
          handle query
        elsif chosen = u.chosen_inline_result
          return if !allowed_user?(chosen)
          handle chosen
        else
          logger.warn("Unsupported update type!")
        end
      end

      def handle(message : ::TelegramBot::Message)
        log_message(message)

        started_at = Time.now

        res = case message.text
              when /\/start(.+)?/
                Actions::Start.new(self, message: message).call
              when "/new"
                Actions::NewSound.new(self, message: message).call
              when "/cancel"
                Actions::Cancel.new(self, message: message).call
              when String
                Actions::GenericText.new(self, message: message).call
              else
                if message.audio || message.voice || message.document || message.photo || message.video || message.video_note
                  Actions::FileMessage.new(self, message: message).call
                else
                  send_message message.chat.id, "I don't understand you..."
                end
              end

        Log.info("Handled in #{TimeFormat.to_ms(Time.now - started_at).colorize.mode(:bold)}")

        res
      end

      def handle(query : ::TelegramBot::InlineQuery)
        log_inline_query(query)
        started_at = Time.now
        res = Actions::InlineQuery.new(self, inline_query: query).call
        Log.info("Handled in #{TimeFormat.to_ms(Time.now - started_at).colorize.mode(:bold)}")
        res
      end

      def handle(result : ::TelegramBot::ChosenInlineResult)
        log_chosen_inline_result(result)
        started_at = Time.now
        Actions::ChosenInlineResult.new(self, result: result).call
        Log.info("Handled in #{TimeFormat.to_ms(Time.now - started_at).colorize.mode(:bold)}")
        "ok"
      end

      # TODO: add "game" (see https://github.com/hangyas/telegram_bot/issues/22)
      MESSAGE_TYPES = %w(audio document photo sticker video voice contact location venue text)
      MESSAGE_COLOR = :light_blue

      def log_message(message : ::TelegramBot::Message)
        message_type = nil

        {% for mtype in MESSAGE_TYPES %}
          message_type ||= {{mtype}} if message.{{mtype.id}}
        {% end %}

        contents = ": #{message.text.colorize(MESSAGE_COLOR).mode(:bold)}" if message_type == "text"

        logger.info("Incoming #{message_type.colorize(MESSAGE_COLOR).mode(:bold)} message from #{sender_name(message.from.not_nil!, MESSAGE_COLOR)} (#{message.chat.id})#{contents}")
      end

      INLINE_QUERY_COLOR = :light_green

      def log_inline_query(query : ::TelegramBot::InlineQuery)
        contents = if query.query.size > 0
                     query.query.colorize(INLINE_QUERY_COLOR).mode(:bold)
                   else
                     "empty".colorize(:dark_gray)
                   end

        logger.info("Incoming #{"inline query".colorize(INLINE_QUERY_COLOR).mode(:bold)} from #{sender_name(query.from, INLINE_QUERY_COLOR)} (#{query.from.id}): #{contents}")
      end

      CHOSEN_INLINE_RESULT_COLOR = :cyan

      def log_chosen_inline_result(result : ::TelegramBot::ChosenInlineResult)
        contents = if result.query.size > 0
                     "result_id #{result.result_id.colorize(CHOSEN_INLINE_RESULT_COLOR).mode(:bold)} from query #{"\"#{result.query}\"".colorize(CHOSEN_INLINE_RESULT_COLOR).mode(:bold)}"
                   else
                     "result_id #{result.result_id.colorize(CHOSEN_INLINE_RESULT_COLOR).mode(:bold)} from #{"empty query".colorize(:dark_gray)}"
                   end

        logger.info("Incoming #{"chosen result".colorize(CHOSEN_INLINE_RESULT_COLOR).mode(:bold)} from #{sender_name(result.from, CHOSEN_INLINE_RESULT_COLOR)} (#{result.from.id}): #{contents}")
      end

      private def sender_name(from : ::TelegramBot::User, color : Symbol = :light_blue) : String
        if username = from.username
          "@#{username}"
        elsif last_name = from.last_name
          "#{from.first_name}#{(" " + last_name)}"
        else
          "#{from.first_name}"
        end.colorize(color).mode(:bold).to_s
      end
    end
  end
end
