# encoding: UTF-8

require "redic"

class Finist
  SCRIPT = <<-EOS
    local curr = redis.call("GET", KEYS[1])
    local next = redis.call("HGET", KEYS[2], curr)

    if next then
      redis.call("SET", KEYS[1], next)
      return { next, true }
    else
      return { curr, false }
    end
  EOS

  def initialize(redis, name, init)
    @name = sprintf("finist:%s", name)
    @redis = redis
    @redis.call("SET", @name, init, "NX")
  end

  def event_key(ev)
    sprintf("%s:%s", @name, ev)
  end

  def on(ev, curr_state, next_state)
    @redis.call("HSET", event_key(ev), curr_state, next_state)
  end

  def rm(ev)
    @redis.call("DEL", event_key(ev))
  end

  def state
    @redis.call("GET", @name)
  end

  def send_event(ev)
    @redis.call("EVAL", SCRIPT, "2", @name, event_key(ev))
  end

  def trigger(ev)
    result = send_event(ev)
    return result[0], result[1] != nil
  end
end
