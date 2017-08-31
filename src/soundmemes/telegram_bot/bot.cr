require "tele"
require "./handlers/**"
require "./keyboards/main_menu"

module Soundmemes
  module TelegramBot
    class Bot < Tele::Bot
      @@name = "Soundmemesbot"
      @@color = :cyan

      def handle(update)
        if message = update.message
          text = update.message.not_nil!.text
          if text
            case text
            when /\/start(.+)?/
              Handlers::Start
            when "/new", Keyboards::MainMenu::BUTTON_NEW_SOUND
              Handlers::NewSound
            when "/cancel"
              Handlers::Cancel
            when Handlers::SoundById::REGEXPS.find &.match(text)
              Handlers::SoundById
            when Keyboards::MainMenu::BUTTON_FAVORITES
              Handlers::Lists::Favorites
            when Keyboards::MainMenu::BUTTON_POPULAR
              Handlers::Lists::Popular
            when Keyboards::MainMenu::BUTTON_MY_SOUNDS
              Handlers::Lists::My
            when Keyboards::MainMenu::BUTTON_MORE
              Handlers::AdditionalInformation
            when Keyboards::MainMenu::BUTTON_DONATE, "/donate"
              Handlers::Donate
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
        elsif callback_query = update.callback_query
          case callback_query.data
          when Keyboards::SoundManagementMenu::FAVORITE_REGEX
            Handlers::CallbackQuery::SwitchFavorite
          when Handlers::Lists::Favorites.regex
            Handlers::Lists::Favorites
          when Handlers::Lists::Popular.regex
            Handlers::Lists::Popular
          when Handlers::Lists::My.regex
            Handlers::Lists::My
          end
        end
      end
    end
  end
end
