require "../repo"
require "./user"
require "./sound"

module Soundmemes
  class SoundPost < Crecto::Model
    schema "sound_postings" do
      belongs_to :user, User
      belongs_to :sound, Sound
      field :telegram_message_id, PkeyValue
    end

    validate_required [:user, :sound]
  end
end
