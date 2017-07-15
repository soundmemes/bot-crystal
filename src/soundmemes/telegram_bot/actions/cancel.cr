require "./basic"
require "../reply_markups/main_menu"

module Soundmemes
  module TelegramBot
    module Actions
      class Cancel < Basic
        def call
          case user_state.get
          when US::State::AddSoundSetName, US::State::AddSoundSetTags, US::State::AddSoundUploadFile
            user_state.set(US::State::MainMenu)
            bot.send_message user_id, "Got you back to the main menu.", reply_markup: ReplyMarkups::MainMenu.new.markup
          end
        end
      end
    end
  end
end
