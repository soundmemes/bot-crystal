module Utils::TimeFormat
  extend self

  SECONDS_TEMPLATE      = "%ds"
  MILLISECONDS_TEMPLATE = "%dms"
  MICROSECONDS_TEMPLATE = "%dμs"

  def to_seconds(time : Float | Time::Span, round : Int32 = 3) : String
    SECONDS_TEMPLATE % (time.to_f).round(round)
  end

  def to_s(time, round = 3)
    to_seconds(time, round)
  end

  def to_milliseconds(time : Float | Time::Span, round : Int32 = 1) : String
    MILLISECONDS_TEMPLATE % (time.to_f * 1_000.0).round(round)
  end

  def to_ms(time : Float | Time::Span)
    to_milliseconds(time)
  end

  def to_microseconds(time : Float | Time::Span) : String
    MICROSECONDS_TEMPLATE % (time.to_f * 1_000_000.0).to_i
  end

  def to_μs(time : Float | Time::Span)
    to_microseconds(time)
  end
end
