require "./base"

module Soundmemes
  module Repositories
    class SoundPosting < Base
      def create(telegram_user_id : Int32, sound_id : Int32)
        user_id = User.new(db).by_telegram_id!(telegram_user_id).id

        data = {
          "user_id"    => user_id,
          "sound_id"   => sound_id,
          "created_at" => Time.now,
        }

        db.exec(builder.table("sound_postings").insert(data))
      end
    end
  end
end
