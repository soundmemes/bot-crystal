require "../../orm/models/sound"

module Soundmemes
  module TelegramBot
    module Handlers
      class Donate < Tele::Handlers::Message
        def call
          r = [] of R::SendMessage | R::SendVoice

          # Just for lulz
          if sound_id = ENV["DONATE_SOUND_ID"]?.try &.to_i
            sound = Repo.get(Sound, sound_id).as(Sound).not_nil!

            r << R::SendVoice.new(
              chat_id: message.from.not_nil!.id,
              voice: sound.telegram_file_id.not_nil!,
            )
          end

          r << send_message(
            text: "Glad you've pressed this button! My name is [Vlad](tg://user?id=#{ENV["DEVELOPER_TELEGRAM_ID"]}), I'm the *Developer* and I love coffee! ❤️\n\nIf you are thankful for some moments of joy the bot has brought to you, feel free to donate:\n\n*-* Via [Yandex](#{ENV["DONATE_YANDEX_URL"]})\n*-* Via [PayPal](#{ENV["DONATE_PAYPAL_URL"]})\n*-* With [QIWI Vouchers](https://qiwi.com/payment/form.action?provider=22496) at my e-mail #{ENV["DONATE_QIWI_EMAIL"]}\n*-* By sending Bitcoins to `#{ENV["DONATE_BITCOIN_ADDRESS"]}`\n*-* By sending Ethereum to `#{ENV["DONATE_ETHEREUM_ADDRESS"]}`\n\nFor donations over *$10* you'll be granted with one 👑 crown next to your username in sounds lists; *$50+* = two crowns, *$100+* = three crowns. Contact [me](tg://user?id=#{ENV["DEVELOPER_TELEGRAM_ID"]}) after you've made a donation to get your crowns!",
            parse_mode: "Markdown",
            disable_web_page_preview: true,
          )

          r
        end
      end
    end
  end
end
