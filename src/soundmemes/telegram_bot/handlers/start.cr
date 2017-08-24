require "./helpers/user_state"
require "./new_sound"
require "../../repositories/user"

module Soundmemes
  module TelegramBot
    module Handlers
      class Start < Tele::Handlers::Message
        include UserState

        TOKEN_ADD_NEW_SOUND = "add_new_sound"

        def call
          token = /\/start (\w+)/.match(message.text.not_nil!).try &.[1]
          case token
          when TOKEN_ADD_NEW_SOUND
            NewSound.call(update)
          else
            case user_state.get
            when US::State::AddSoundSetName, US::State::AddSoundSetTags, US::State::AddSoundUploadFile
              user_state.set(US::State::MainMenu)
            end

            new_user = Repositories::User.new(db).create?(message.from.not_nil!.id)
            first_name = message.from.not_nil!.first_name
            text = if new_user
                     "Welcome, %{username}!" % {username: first_name}
                   else
                     "Hello, %{username}" % {username: first_name}
                   end

            send_message(text: text, reply_markup: Keyboards::MainMenu.new.to_type)
          end
        end
      end
    end
  end
end
