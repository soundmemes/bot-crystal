require "../repo"

module Soundmemes
  class User < Crecto::Model
    schema "users" do
      field :telegram_id, PkeyValue
      set_updated_at_field nil
    end

    validate_required :telegram_id

    def self.find_or_create(telegram_id : PkeyValue)
      result = Repo.get_by(self, telegram_id: telegram_id).try &.as(self) || self.new.tap { |u| u.telegram_id = telegram_id }.try { |i| Repo.insert(i).instance }
    end
  end
end
