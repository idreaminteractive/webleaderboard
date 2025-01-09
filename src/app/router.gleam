import app/chat_actor/chat
import app/components/layout
import app/context/ctx
import gleam/erlang/process

import gleam/list
import gleam/result

import app/routes/home
import app/web
import gleam/http.{Get}

import lustre/element

import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: ctx.Context) -> Response {
  use req <- web.middleware(req, ctx)

  // Wisp doesn't have a special router abstraction, instead we recommend using
  // regular old pattern matching. This is faster than a router, is type safe,
  // and means you don't have to learn or be limited by a special DSL.
  //
  case wisp.path_segments(req) {
    // This matches `/`.
    [] -> home_page(req, ctx)
    ["submit"] -> submit(req, ctx)

    ["internal-server-error"] -> wisp.internal_server_error()
    ["unprocessable-entity"] -> wisp.unprocessable_entity()
    ["method-not-allowed"] -> wisp.method_not_allowed([])
    ["entity-too-large"] -> wisp.entity_too_large()
    ["bad-request"] -> wisp.bad_request()

    // This matches all other paths.
    _ -> wisp.not_found()
  }
}

fn submit(req: Request, context: ctx.Context) -> Response {
  use <- wisp.require_method(req, http.Post)
  // let's figure out our form data
  use form_data <- wisp.require_form(req)
  let msg = {
    use message <- result.try(list.key_find(form_data.values, "message"))
    Ok(message)
  }
  case msg {
    Ok(val) -> process.send(context.subject, chat.Push(val))
    Error(_) -> Nil
  }

  wisp.redirect(to: "/")
}

fn home_page(req: Request, ctx: ctx.Context) -> Response {
  // The home page can only be accessed via GET requests, so this middleware is
  // used to return a 405: Method Not Allowed response for all other methods.
  use <- wisp.require_method(req, Get)
  let msgs = process.call(ctx.subject, chat.All, 50)
  let res =
    [home.root(msgs)]
    |> layout.layout
    |> element.to_document_string_builder

  wisp.ok()
  |> wisp.html_body(res)
}
