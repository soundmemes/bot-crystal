require "tele/src/tele/requests/updating_messages/edit_message_text"
require "../helpers/sound_information"
require "../../keyboards/inline_pagination"

module Soundmemes
  module TelegramBot
    module Handlers::Lists
      # This one handles both text messages & callback queries
      abstract class SoundList < Tele::Handler
        include Utils::Logger
        include Helpers::SoundInformation

        # MUST be set per class
        @@list_name = uninitialized String

        def self.regex
          @@regex ||= /#{@@list_name}:page(\d+)/
        end

        # CAN be changed per class
        @@limit = 3

        @user = uninitialized User
        @sounds = uninitialized Array(Sound)
        @total_number = uninitialized Int64

        # MUST load @sounds & @total_number; @user is already loaded
        private abstract def preload_data(page : Int32 = 0)

        def call
          if message = update.message
            @user = User.find_or_create(telegram_id: message.from.not_nil!.id)
            preload_data

            R::SendMessage.new(
              chat_id: message.from.not_nil!.id,
              text: @sounds.any? ? render_sounds : no_sounds_message,
              parse_mode: "HTML",
              reply_markup: reply_markup,
            )
          elsif callback_query = update.callback_query
            page = self.class.regex.match(callback_query.data.not_nil!).try &.[1].to_i
            raise MalformedQueryError.new unless page

            @user = User.find_or_create(callback_query.from.id)
            preload_data(page)

            [
              R::AnswerCallbackQuery.new(
                callback_query_id: callback_query.id,
              ),
              R::UpdatingMessages::EditMessageText.new(
                chat_id: callback_query.from.id,
                message_id: callback_query.message.not_nil!.message_id,
                text: render_sounds,
                parse_mode: "HTML",
                reply_markup: reply_markup(page),
              ),
            ]
          end
        rescue MalformedQueryError
          logger.warn("Malformed callback query: #{callback_query.not_nil!.data}")
          nil
        end

        private def no_sounds_message : String
          "There are currently no sounds right here."
        end

        private def render_sounds : String
          @sounds.map { |s| "- " + short_sound_information(s) }.join("\n\n")
        end

        private def reply_markup(page : Int32 = 0)
          Keyboards::InlinePagination.new(@@list_name, page, @total_number > (page + 1) * @@limit).to_type
        end

        private class MalformedQueryError < Exception; end
      end
    end
  end
end
