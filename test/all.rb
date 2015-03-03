require_relative "helper"

setup do
  Redic.new.tap do |c|
    c.call("FLUSHDB")
  end
end

test do |c|
  fsm = Finist.new(c, "myfsm", "pending")

  fsm.on("approve", "pending", "approved")
  fsm.on("cancel", "pending", "cancelled")
  fsm.on("cancel", "approved", "cancelled")
  fsm.on("reset", "cancelled", "pending")

  # Verify initial state
  assert_equal("pending", fsm.state)

  # Send an event
  fsm.trigger("approve")

  # Verify transition to "approved"
  assert_equal("approved", fsm.state)

  # Send an event
  fsm.trigger("cancel")

  # Verify transition to "cancelled"
  assert_equal("cancelled", fsm.state)

  # Send an event
  fsm.trigger("approve")

  # Verify state remains as "cancelled"
  assert_equal("cancelled", fsm.state)

  # Create a different fsm with client
  fsm2 = Finist.new(c, "myfsm", "pending")

  # Verify state remains as "cancelled"
  assert_equal("cancelled", fsm2.state)

  # A successful event returns true
  state, changed = fsm.trigger("reset")

  assert_equal(true, changed)
  assert_equal("pending", state)

  # An unsuccessful event returns false
  state, changed = fsm.trigger("reset")

  assert_equal(false, changed)
  assert_equal("pending", state)

  # Delete an event
  fsm.rm("approve")

  # Non existent events return false
  state, changed = fsm.trigger("approve")

  assert_equal(false, changed)
  assert_equal("pending", state)
end
