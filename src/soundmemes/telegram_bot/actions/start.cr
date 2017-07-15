require "./basic"
require "../../repositories/user"

module Soundmemes
  module TelegramBot
    module Actions
      class Start < Basic
        TOKEN_ADD_NEW_SOUND = "add_new_sound"

        def call
          token = /\/start (\w+)/.match(message.text.not_nil!).try &.[1]
          case token
          when TOKEN_ADD_NEW_SOUND
            NewSound.new(bot, message: message).call
          else
            case user_state.get
            when US::State::AddSoundSetName, US::State::AddSoundSetTags, US::State::AddSoundUploadFile
              user_state.set(US::State::MainMenu)
            end

            new_user = Repositories::User.create?(user_id)
            first_name = message.from.not_nil!.first_name
            text = if new_user
                     "Welcome, %{username}!" % {username: first_name}
                   else
                     "Hello, %{username}" % {username: first_name}
                   end

            bot.send_message(user_id, text, reply_markup: ReplyMarkups::MainMenu.new.markup)
          end
        end
      end
    end
  end
end
