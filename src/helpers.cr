def hash_from_redis_array(array : Array(Redis::RedisValue)) : Hash(String, String)
  keys = Array(String).new
  values = Array(String).new
  array.each_with_index { |e, i| i % 2 == 0 ? keys << e.to_s : values << e.to_s }
  Hash(String, String).zip(keys, values)
end
