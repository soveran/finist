Finist
======

Redis based Finite State Machine.

Description
-----------

Finist is a finite state machine that is defined and persisted in
[Redis][redis].

Community
---------

Meet us on IRC: [#lesscode](irc://chat.freenode.net/#lesscode) on
[freenode.net](http://freenode.net/).

Related projects
----------------

There's an [alternative implementation for Lua][finist.lua].

Getting started
---------------

Install [Redis][redis]. On most platforms it's as easy as grabbing
the sources, running make and then putting the `redis-server` binary
in the PATH.

Once you have it installed, you can execute `redis-server` and it
will run on `localhost:6379` by default. Check the `redis.conf`
file that comes with the sources if you want to change some settings.

Usage
-----

Finist requires a [Redic][redic] compatible client. To make things
easier, `redic` is listed as a runtime dependency so the examples
in this document will work.

```ruby
require "finist"

# Initialize with a Redis client, the name of the machine and the
# initial state. In this example, the machine is called "order" and
# the initial status is "pending". The Redis client is connected to
# the default host (127.0.0.1:6379).
machine = Finist.new(Redic.new, "order", "pending")

# Available transitions are defined with the `on` method
# `machine.on(<event>, <initial_state>, <final_state>)`
machine.on("approve", "pending", "approved")
machine.on("cancel", "pending", "cancelled")
machine.on("cancel", "approved", "cancelled")
machine.on("reset", "cancelled", "pending")
```

Now that the possible transitions are defined, we can check the
current state:

```ruby
machine.state
# => "pending"
```

And we can trigger an event:

```ruby
machine.trigger("approve")
# => [true, "approved"]
```

The `trigger` method returns an array of two values: the first
represents whether a transition occurred, and the second represents
the current state.

Here's what happens if an event doesn't cause a transition:

```ruby
machine.trigger("reset")
# => [false, "approved"]
```

Here's a convenient way to use this flag:

```ruby
changed, state = machine.trigger("reset")

if changed
  printf("State changed to %s\n", state)
end
```

If you need to remove all the transitions for a given event, you
can use `rm`:

```ruby
machine.rm("reset")
```

Note that every change is persisted in Redis.

Installation
------------

```
$ gem install finist
```

[redis]: http://redis.io
[redic]: https://github.com/amakawa/redic
[finist.lua]: https://github.com/soveran/finist.lua
