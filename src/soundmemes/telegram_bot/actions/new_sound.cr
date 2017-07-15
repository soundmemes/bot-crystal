require "./basic"

module Soundmemes
  module TelegramBot
    module Actions
      class NewSound < Basic
        def call
          case user_state.get
          when US::State::MainMenu
            init_adding
            bot.send_message(user_id, "Let's add a new sound... Please specify the sound's name:", reply_markup: ::TelegramBot::ReplyKeyboardRemove.new)
          when US::State::AddSoundSetName, US::State::AddSoundSetTags, US::State::AddSoundUploadFile
            init_adding
            bot.send_message(user_id, "Let's start over... Please specify the sound's name:", reply_markup: ::TelegramBot::ReplyKeyboardRemove.new)
          end
        end

        def init_adding
          user_state.set(US::State::AddSoundSetName)
          user_state.clear_params
        end
      end
    end
  end
end
