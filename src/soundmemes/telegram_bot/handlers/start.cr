require "./helpers/user_state"
require "./new_sound"
require "../../orm/models/user"

module Soundmemes
  module TelegramBot
    module Handlers
      class Start < Tele::Handlers::Message
        include UserState
        include Utils::Logger

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

            user = User.find_or_create(message.from.not_nil!.id)
            first_name = message.from.not_nil!.first_name

            user.telegram_first_name = first_name
            user.telegram_last_name = message.from.not_nil!.last_name
            user.telegram_username = message.from.not_nil!.username

            changeset = User.changeset(user)
            if changeset.valid?
              Repo.update(changeset)
            else
              logger.error("Invalid User changeset: #{changeset.errors}")
            end

            text = "Hello, %{username}" % {username: first_name}
            send_message(text: text, reply_markup: Keyboards::MainMenu.new.to_type)
          end
        end
      end
    end
  end
end
