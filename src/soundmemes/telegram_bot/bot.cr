require "tele"
require "./handlers/**"

module Soundmemes
  module TelegramBot
    class Bot < Tele::Bot
      @@name = "Soundmemesbot"
      @@color = :yellow

      def handle(update)
        if message = update.message
          text = update.message.not_nil!.text
          if text
            case text
            when /\/start(.+)?/
              Handlers::Start
            when "/new"
              Handlers::NewSound
            when "/cancel"
              Handlers::Cancel
            else
              Handlers::GenericText
            end
          elsif message.audio || message.voice || message.document || message.photo || message.video || message.video_note
            Handlers::FileMessage
          else
            Handlers::DontUnderstand
          end
        elsif inline_query = update.inline_query
          Handlers::InlineQuery
        elsif chosen_inline_result = update.chosen_inline_result
          Handlers::ChosenInlineResult
        end
      end
    end
  end
end
