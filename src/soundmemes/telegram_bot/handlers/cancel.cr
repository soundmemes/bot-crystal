require "./helpers/user_state"
require "../keyboards/main_menu"

module Soundmemes
  module TelegramBot
    module Handlers
      class Cancel < Tele::Handlers::Message
        include UserState

        def call
          case user_state.get
          when US::State::AddSoundSetName, US::State::AddSoundSetTags, US::State::AddSoundUploadFile
            user_state.set(US::State::MainMenu)
            send_message(
              text: "Got you back to the main menu.",
              reply_markup: Keyboards::MainMenu.new.to_type,
            )
          end
        end
      end
    end
  end
end
