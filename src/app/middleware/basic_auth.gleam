import gleam/bit_array

import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import wisp.{type Request, type Response}

pub fn basic_auth_middleware(
  req: Request,
  username: String,
  password: String,
  handler: fn() -> Response,
) -> Response {
  let response = handler()
  let hashed =
    extract_basic_auth_from_headers(req.headers)
    |> validate_basic_auth(username, password)

  //   nothing found 
  case hashed {
    False ->
      wisp.response(401)
      |> wisp.set_header(
        "WWW-Authenticate",
        "Basic realm=\"restricted\", charset=\"UTF-8\"",
      )
    True -> response
  }
}

fn validate_basic_auth(
  auth_header: String,
  username: String,
  password: String,
) -> Bool {
  let valid = {
    use b64_encoded <- result.try(string.split_once(auth_header, on: " "))
    use uname_pw <- result.try(
      b64_encoded
      |> pair.second
      |> bit_array.base64_decode,
    )

    use s <- result.try(uname_pw |> bit_array.to_string)
    use #(u, p) <- result.try(string.split_once(s, on: ":"))

    Ok(u == username && p == password)
  }

  case valid {
    Ok(True) -> True
    _ -> False
  }
}

fn extract_basic_auth_from_headers(headers: List(#(String, String))) -> String {
  headers
  |> list.key_find("authorization")
  |> result.unwrap("")
}
