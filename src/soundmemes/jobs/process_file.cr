require "shell"
require "tempfile"
require "../repositories/sound"
require "tele/requests/send_voice"

module Soundmemes
  module Jobs
    class ProcessFile
      include Dispatchable

      # In seconds
      MAXIMUM_SOUND_DURATION = 30

      def perform(telegram_user_id : Int32,
                  telegram_file_id : String,
                  sound_name : String,
                  sound_tags : String | Nil)
        input = Tele::Client.new(ENV["BOT_API_TOKEN"], Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG }).download_file(file_id: telegram_file_id)

        if input && (converted = convert_to_ogg(input))
          send_message(telegram_user_id, "This is your recently added sound. Share it and have fun!")
          begin
            response = send_voice(telegram_user_id, converted).not_nil!.as(Tele::Types::Message)
            if voice = response.voice
              file_id = voice.file_id
              Repositories::Sound.create(telegram_user_id, sound_name, sound_tags, file_id)
            else
              Log.error("Did not receive voice in response message!")
            end
          ensure
            File.delete(converted.path)
          end
        else
          send_message(telegram_user_id, "Sorry, couldn't process your file. Please, try again with another one.")
        end
      end

      private def convert_to_ogg(input : IO) : File | Nil
        temp = Tempfile.new("processed")
        path = temp.path
        File.write(path, input.to_slice)
        output_path = path + ".output.ogg"

        Log.debug("Converting #{path} (#{to_kb(File.size(path))})...")
        started_at = Time.now

        begin
          Shell.run("ffmpeg -v quiet -t #{MAXIMUM_SOUND_DURATION} -i #{path} -ar 48000 -ac 1 -acodec libopus -ab 128k #{output_path}")
          Log.debug("Converted #{path} to #{output_path} (#{to_kb(File.size(path))} to #{to_kb(File.size(output_path))}) in #{TimeFormat.to_s(Time.now - started_at)}")
          File.open(output_path)
        rescue ex : Exception
          Log.error("Could not convert file #{path}!")
          nil
        ensure
          temp.unlink
        end
      end

      private def to_kb(bytes : UInt64)
        "#{(bytes.to_f / 10 ** 3).round(1)} KB"
      end

      private def send_message(chat_id, text)
        Tele::Requests::SendMessage.new(chat_id: chat_id, text: text).send(ENV["BOT_API_TOKEN"])
      end

      private def send_voice(chat_id, voice)
        Tele::Requests::SendVoice.new(chat_id: chat_id, voice: voice).send(ENV["BOT_API_TOKEN"])
      end
    end
  end
end
