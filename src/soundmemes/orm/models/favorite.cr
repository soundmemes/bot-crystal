require "../repo"
require "./user"
require "./sound"

module Soundmemes
  class Favorite < Crecto::Model
    schema "favorites" do
      belongs_to :user, User
      belongs_to :sound, Sound
      set_updated_at_field nil
    end

    validate_required [:user_id, :sound_id]
  end
end
