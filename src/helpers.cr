def hash_from_redis_array(array : Array(Redis::RedisValue)) : Hash(String, String)
  keys = Array(String).new
  values = Array(String).new
  array.each_with_index { |e, i| i % 2 == 0 ? keys << e.to_s : values << e.to_s }
  Hash(String, String).zip(keys, values)
end

module TimeFormat
  extend self

  MICROSECONDS_TEMPLATE = "%{micro}μs"

  def to_microseconds(time : Float | Time::Span) : String
    MICROSECONDS_TEMPLATE % {micro: (time.to_f * 1_000_000.0).to_i}
  end

  def to_μs(time : Float | Time::Span)
    to_microseconds(time)
  end

  MILLISECONDS_TEMPLATE = "%{milli}ms"

  def to_milliseconds(time : Float | Time::Span, round : Int32 = 1) : String
    MILLISECONDS_TEMPLATE % {milli: (time.to_f * 1_000.0).round(round)}
  end

  def to_ms(time : Float | Time::Span)
    to_milliseconds(time)
  end

  SECONDS_TEMPLATE = "%{sec}s"

  def to_seconds(time : Float | Time::Span, round : Int32 = 3) : String
    SECONDS_TEMPLATE % {sec: (time.to_f).round(round)}
  end

  def to_s(time, round = 3)
    to_seconds(time, round)
  end
end
