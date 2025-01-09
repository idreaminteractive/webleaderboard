import gleam/erlang/process.{type Subject}

import gleam/list
import gleam/otp/actor

// First step of implementing the stack Actor is to define the message type that
// it can receive.
//
// The type of the elements in the stack is not fixed so a type parameter is used
// for it instead of a concrete type such as `String` or `Int`.
pub type Message(element) {
  // The `Shutdown` message is used to tell the actor to stop.
  // It is the simplest message type, it contains no data.
  Shutdown

  // The `Push` message is used to add a new element to the stack.
  // It contains the item to add, the type of which is the `element`
  // parameterised type.
  Push(push: element)

  // The `Pop` message is used to remove an element from the stack.
  // It contains a `Subject`, which is used to send the response back to the
  // message sender. In this case the reply is of type `Result(element, Nil)`.
  All(reply_with: Subject(List(element)))
}

// The last part is to implement the `handle_message` callback function.
//
// This function is called by the Actor for each message it receives.
// Actor is single threaded and only does one thing at a time, so it handles
// messages sequentially and one at a time, in the order they are received.
//
// The function takes the message and the current state, and returns a data
// structure that indicates what to do next, along with the new state.
pub fn handle_message(
  message: Message(e),
  stack: List(e),
) -> actor.Next(Message(e), List(e)) {
  case message {
    // For the `Shutdown` message we return the `actor.Stop` value, which causes
    // the actor to discard any remaining messages and stop.
    Shutdown -> actor.Stop(process.Normal)

    // For the `Push` message we add the new element to the stack and return
    // `actor.continue` with this new stack, causing the actor to process any
    // queued messages or wait for more.
    Push(value) -> {
      let new_state = [value, ..stack]
      actor.continue(new_state)
    }

    // For the `Pop` message we attempt to remove an element from the stack,
    // sending it or an error back to the caller, before continuing.
    All(client) -> {
      process.send(client, list.take(stack, 20) |> list.reverse)
      actor.continue(stack)
    }
  }
}
