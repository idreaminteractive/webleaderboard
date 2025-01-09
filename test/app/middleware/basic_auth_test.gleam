import app/chat_actor/chat
import app/context/ctx
import app/router
import gleam/bit_array

import gleam/list
import gleam/otp/actor
import gleam/string

import gleeunit/should
import wisp/testing

pub fn get_basic_auth_fail_test() {
  let assert Ok(my_actor) = actor.start([], chat.handle_message)
  let ctx = ctx.Context("", my_actor)
  let request = testing.get("/", [])
  let response = router.handle_request(request, ctx)

  response.status
  |> should.equal(401)

  response.headers
  |> list.key_find("www-authenticate")
  |> should.be_ok
}

pub fn get_basic_auth_with_bad_creds_test() {
  let assert Ok(my_actor) = actor.start([], chat.handle_message)
  let ctx = ctx.Context("", my_actor)

  let request = testing.get("/", [#("authorization", "")])
  let response = router.handle_request(request, ctx)

  response.status
  |> should.equal(401)

  let creds =
    "invalid:credentials"
    |> bit_array.from_string
    |> bit_array.base64_encode(True)
    |> string.append(to: "Basic ")

  let request = testing.get("/", [#("authorization", creds)])
  let response = router.handle_request(request, ctx)

  response.status
  |> should.equal(401)
}

pub fn get_basic_auth_with_good_creds_test() {
  let assert Ok(my_actor) = actor.start([], chat.handle_message)
  let ctx = ctx.Context("", my_actor)

  let creds =
    "dave:dave"
    |> bit_array.from_string
    |> bit_array.base64_encode(True)
    |> string.append(to: "Basic ")

  let request = testing.get("/", [#("authorization", creds)])
  let response = router.handle_request(request, ctx)

  response.status
  |> should.equal(200)
}
