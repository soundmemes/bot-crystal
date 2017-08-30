require "./helpers/user_state"

module Soundmemes
  module TelegramBot
    module Handlers
      class AdditionalInformation < Tele::Handlers::Message
        def call
          send_message(
            text: "Join the *channel* @soundmemes to stay updated.\nJoin our *chat* @soundmemeschat if you want to talk.\n\nBe sure to [rate the bot](https://t.me/storebot?start=soundmemesbot):",
            parse_mode: "Markdown",
          )
        end
      end
    end
  end
end
