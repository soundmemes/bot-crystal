require "./_sound_list"
require "../../../orm/models/favorite"

module Soundmemes
  module TelegramBot
    module Handlers::Lists
      class Favorites < SoundList
        @@list_name = "favorites"

        private def preload_data(page = 0)
          @total_number = Repo.aggregate(Favorite, :count, :id, Query.where(user_id: @user.id)).as(Int64)
          @sounds = Sound.favorites(@user, @@limit, page * @@limit)
        end

        private def no_sounds_message : String
          "You don't have any favorites yet.\nFind some cool sounds in 🔥 <b>Populars</b> section!"
        end
      end
    end
  end
end
