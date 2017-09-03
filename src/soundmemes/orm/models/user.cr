require "../repo"

module Soundmemes
  class User < Crecto::Model
    schema "users" do
      field :telegram_id, PkeyValue
      field :telegram_first_name, String
      field :telegram_last_name, String
      field :telegram_username, String
      set_updated_at_field nil
      has_many :sounds, Sound
      has_many :posts, SoundPost
    end

    validate_required :telegram_id

    def self.find_or_create(telegram_id : PkeyValue)
      result = Repo.get_by(self, telegram_id: telegram_id).try &.as(self) || self.new.tap { |u| u.telegram_id = telegram_id }.try { |i| Repo.insert(i).instance }
    end

    def update_telegram_info(first_name : String, last_name : String?, username : String?)
    end
  end
end
