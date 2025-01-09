import birl
import gleam/dynamic/decode
import gleam/option.{type Option}

import sqlight

pub type GetUserById {
  GetUserById(id: Int, email: String)
}

fn get_user_by_id_decoder() {
  use id <- decode.field(0, decode.int)
  use email <- decode.field(1, decode.string)
  decode.success(GetUserById(id:, email:))
}

fn get_user_by_id_sql() {
  let sql =
    "
  SELECT
    id,
    email
FROM
    user
WHERE
    id = ?;
  "

  sql
}

pub fn get_user_by_id(conn: sqlight.Connection, id: Int) {
  sqlight.query(
    get_user_by_id_sql(),
    on: conn,
    with: [sqlight.int(id)],
    expecting: get_user_by_id_decoder(),
  )
}

pub type ListUsersRow {
  ListUsersRow(
    id: Int,
    name: String,
    optional_example: Option(Int),
    email: String,
    created_at: birl.Time,
    updated_at: birl.Time,
  )
}

pub type ListUsers =
  List(ListUsersRow)

fn decode_birl_time_from_string() -> decode.Decoder(birl.Time) {
  decode.string
  |> decode.then(fn(v: String) {
    case birl.parse(v) {
      Ok(time) -> decode.success(time)
      Error(_err) -> decode.success(birl.now())
    }
  })
}

fn list_users_decoder() {
  use id <- decode.field(0, decode.int)
  use name <- decode.field(1, decode.string)
  use optional_example <- decode.field(2, decode.optional(decode.int))
  use email <- decode.field(3, decode.string)
  use created_at <- decode.field(4, decode_birl_time_from_string())

  use updated_at <- decode.field(5, decode_birl_time_from_string())
  decode.success(ListUsersRow(
    id:,
    name:,
    optional_example:,
    email:,
    created_at:,
    updated_at:,
  ))
  // decode.success(GetUserById(id:, email:))
}

fn list_users_sql() {
  let sql =
    "
SELECT
    id,
    name, 
    optional_example,
    email,
    created_at,
    updated_at
FROM
    user;
  "

  sql
}

pub fn list_users(conn: sqlight.Connection) {
  sqlight.query(
    list_users_sql(),
    on: conn,
    with: [],
    expecting: list_users_decoder(),
  )
}
