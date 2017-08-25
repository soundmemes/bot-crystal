require "../orm/models/sound_post"

module Soundmemes::Interactors
  class CreateSoundPost
    def initialize(telegram_id @posting_user_telegram_id : Int32, @sound_id : Int32)
    end

    def call
      user = User.find_or_create(@posting_user_telegram_id)
      sound = Repo.get!(Sound, @sound_id)
      post = SoundPost.new.tap { |p| p.user = user; p.sound = sound }
      post = Repo.insert(post).instance.as(SoundPost)
    end
  end
end
