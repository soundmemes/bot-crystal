require "./helpers/user_state"

module Soundmemes
  module TelegramBot
    module Handlers
      class NewSound < Tele::Handlers::Message
        include UserState

        def call
          case user_state.get
          when US::State::MainMenu
            init_adding
            send_message(
              text: "Let's add a new sound... Please specify the sound's name:",
              reply_markup: Tele::Types::ReplyKeyboardRemove.new,
            )
          when US::State::AddSoundSetName, US::State::AddSoundSetTags, US::State::AddSoundUploadFile
            init_adding
            send_message(
              text: "Let's start over... Please specify the sound's name:",
              reply_markup: Tele::Types::ReplyKeyboardRemove.new,
            )
          end
        end

        private def init_adding
          user_state.set(US::State::AddSoundSetName)
          user_state.clear_params
        end
      end
    end
  end
end
