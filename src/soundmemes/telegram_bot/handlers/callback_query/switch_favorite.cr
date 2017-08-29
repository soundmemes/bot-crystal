require "tele/src/tele/requests/updating_messages/edit_message_reply_markup"
require "../../../orm/models/favorite"
require "../../keyboards/sound_management_menu"

module Soundmemes
  module TelegramBot
    module Handlers
      class CallbackQuery::SwitchFavorite < Tele::Handlers::CallbackQuery
        include Utils::Logger

        def call
          match = Keyboards::SoundManagementMenu::FAVORITE_REGEX.match(callback_query.data.not_nil!)
          raise MailformedQueryError.new unless match

          sound = Repo.get(Sound, match[1].to_i)

          # A valid callback query always contains existing sound id
          raise MailformedQueryError.new unless sound

          user = User.find_or_create(callback_query.from.id)
          favorite = Repo.get_by(Favorite, user_id: user.id, sound_id: sound.id)

          if favorite
            Repo.delete(favorite)

            [
              answer_callback_query(text: "❌ Removed from favorites"),
              R::UpdatingMessages::EditMessageReplyMarkup.new(
                chat_id: callback_query.from.id,
                message_id: callback_query.message.not_nil!.message_id,
                reply_markup: Keyboards::SoundManagementMenu.new(sound.id.as(Int32), false).to_type,
              ),
            ]
          else
            favorite = Favorite.new.tap { |f| f.user = user; f.sound = sound }
            changeset = Favorite.changeset(favorite)

            if changeset.valid?
              Repo.insert(changeset)
              [
                answer_callback_query(text: "⭐️ Added to favorites"),
                R::UpdatingMessages::EditMessageReplyMarkup.new(
                  chat_id: callback_query.from.id,
                  message_id: callback_query.message.not_nil!.message_id,
                  reply_markup: Keyboards::SoundManagementMenu.new(sound.id.as(Int32), true).to_type,
                ),
              ]
            else
              logger.error("Invalid Favorite changeset: #{changeset.errors}")
              answer_callback_query(text: "⚠️ Oops! Server-side error occured!", show_alert: true)
            end
          end
        rescue MailformedQueryError
          logger.warn("Mailformed callback query: #{callback_query.message}")
          nil
        end

        class MailformedQueryError < Exception
        end
      end
    end
  end
end
