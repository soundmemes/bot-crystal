require "../../services/redis"

module Soundmemes
  module TelegramBot
    class UserState
      enum State
        MainMenu
        AddSoundSetName
        AddSoundSetTags
        AddSoundUploadFile
      end

      def initialize(@telegram_id : Int32)
      end

      def set(state new_state : State) : Nil
        redis &.set("soundmemes:telegram_bot:user_state:#{@telegram_id}", new_state.value) rescue nil
      end

      def get : State
        value = redis &.get("soundmemes:telegram_bot:user_state:#{@telegram_id}").try &.to_i rescue nil
        value ? State.new(value) : State::MainMenu
      end

      def get_params : Hash(String, String)
        array = redis &.hgetall("soundmemes:telegram_bot:user_state:#{@telegram_id}:params") rescue nil
        array ? hash_from_redis_array(array) : Hash(String, String).new
      end

      def merge_params_with(other_params : Hash) : Hash(String, String)
        existing_params = get_params
        merged_params = existing_params.merge(other_params)
        set_params(merged_params)
        merged_params
      end

      def set_params(params : Hash)
        redis &.hmset("soundmemes:telegram_bot:user_state:#{@telegram_id}:params", params) rescue nil
      end

      def clear_params : Nil
        redis &.del("soundmemes:telegram_bot:user_state:#{@telegram_id}:params") rescue nil
      end

      private def hash_from_redis_array(array : Array(Redis::RedisValue)) : Hash(String, String)
        keys = Array(String).new
        values = Array(String).new
        array.each_with_index { |e, i| i % 2 == 0 ? keys << e.to_s : values << e.to_s }
        Hash(String, String).zip(keys, values)
      end
    end
  end
end
