require "./_sound_list"

module Soundmemes
  module TelegramBot
    module Handlers::Lists
      class My < SoundList
        @@list_name = "my"

        private def preload_data(page = 0)
          @total_number = Repo.aggregate(Sound, :count, :id, Query.where(user_id: @user.id)).as(Int64)
          @sounds = Repo.all(Sound, Query.where(user_id: @user.id).preload(:user).limit(@@limit).offset(page * @@limit)).as(Array(Sound))
        end
      end
    end
  end
end
