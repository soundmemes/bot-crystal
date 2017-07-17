require "./basic"

module Soundmemes
  module TelegramBot
    module Actions
      class GenericText < Basic
        def call
          # It's guaranteed that text's not nil
          text = message.text.not_nil!

          case user_state.get
          when US::State::AddSoundSetName
            # Assume the message text is the new sound's name
            #
            if name = validate_new_sound_name(text)
              user_state.merge_params_with({"new_sound_name" => name})
              pp user_state.get_params
              user_state.set(US::State::AddSoundSetTags)
              bot.send_message user_id, "Okay, now enter some comma-separated tags:"
            else
              bot.send_message user_id, "This name doesn't seem to be valid. Its length has to be #{NEW_SOUND_NAME_LENGTH} symbols and it can not contain quotes. Please, try again:"
            end
          when US::State::AddSoundSetTags
            # Assume the message text is a list of the new sound tags
            #
            if tags = validate_new_sound_tags(text)
              user_state.merge_params_with({"new_sound_tags" => tags})
              pp user_state.get_params
              user_state.set(US::State::AddSoundUploadFile)
              bot.send_message user_id, "Okay. Finally, send me the sound:"
            else
              bot.send_message user_id, "These tags don't seem to be valid. Their total length has to be #{NEW_SOUND_TAGS_LENGTH} symbols and they can not contain quotes.Please, try again:"
            end
          when US::State::AddSoundUploadFile
            # The apps awaits for a sound file, but got text
            # TODO: Maybe generate a sound from text?
            #
            bot.send_message user_id, "A file must be sent, not a text!"
          else
            bot.send_message user_id, "Sorry, I don't understand you."
          end
        end

        private NEW_SOUND_NAME_LENGTH = 3..30

        private def validate_new_sound_name(text : String) : String | Nil
          return unless NEW_SOUND_NAME_LENGTH.covers?(text.size)
          return if /'/.match(text)
          text
        end

        private NEW_SOUND_TAGS_LENGTH = 1..50

        private def validate_new_sound_tags(text : String) : String | Nil
          return unless NEW_SOUND_TAGS_LENGTH.covers?(text.size)
          return if /'/.match(text)
          text
        end
      end
    end
  end
end
