require "./basic"
require "../../jobs/process_file"
require "../reply_markups/main_menu"

module Soundmemes
  module TelegramBot
    module Actions
      class FileMessage < Basic
        def call
          case user_state.get
          when US::State::AddSoundSetName, US::State::AddSoundSetTags
            bot.send_message user_id, "A text must be sent, not attachment."
          when US::State::AddSoundUploadFile
            # TODO: If the file is Voice, process immideately
            if file = message.audio || message.voice || message.document
              params = user_state.get_params

              tags = params["new_sound_tags"]
              tags = nil unless tags.size > 0

              Jobs::ProcessFile.dispatch(user_id, file, params["new_sound_name"], tags)

              user_state.set(US::State::MainMenu)
              bot.send_message user_id, "Your file is being processed.", reply_markup: ReplyMarkups::MainMenu.new.markup
            else
              bot.send_message user_id, "This attachment type is not supported yet."
            end
          else
            # TODO: Search sound by file_id?
            bot.send_message user_id, "It's not a right time to send an attachment."
          end
        end
      end
    end
  end
end
