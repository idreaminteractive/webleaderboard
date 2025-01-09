import app/chat_actor/chat
import gleam/erlang/process

pub type Context {
  Context(
    static_directory: String,
    subject: process.Subject(chat.Message(String)),
  )
}
