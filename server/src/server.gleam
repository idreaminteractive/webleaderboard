import common/counter

import gleam/bytes_tree
import gleam/erlang
import gleam/erlang/process.{type Selector, type Subject}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}

import youid/uuid

import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/otp/actor
import lustre
import lustre/attribute
import lustre/element.{element}
import lustre/element/html.{html}
import lustre/server_component
import lustre/ui

import mist.{
  type Connection, type ResponseData, type WebsocketConnection,
  type WebsocketMessage,
}

pub fn main() {
  // let assert Ok(my_actor) = actor.start(0, fetcher.handle_message)
  let assert Ok(lactor) = lustre.start_actor(counter.app(), Nil)
  let id = uuid.v4_string()

  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        // Set up the websocket connection to the client. This is how we send
        // DOM updates to the browser and receive events from the client.
        ["counter"] ->
          mist.websocket(
            request: req,
            on_init: socket_init(_, ComponentState(lactor, id)),
            on_close: socket_close,
            handler: socket_update,
          )

        ["lustre-server-component.mjs"] -> {
          let assert Ok(priv) = erlang.priv_directory("lustre")
          let path = priv <> "/static/lustre-server-component.mjs"
          let assert Ok(script) = mist.send_file(path, offset: 0, limit: None)

          response.new(200)
          |> response.prepend_header("content-type", "application/javascript")
          |> response.set_body(script)
        }

        // For all other requests we'll just serve some HTML that renders the
        // server component.
        _ ->
          response.new(200)
          |> response.prepend_header("content-type", "text/html")
          |> response.set_body(
            html([], [
              html.head([], [
                html.link([
                  attribute.rel("stylesheet"),
                  attribute.href(
                    "https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.min.css",
                  ),
                ]),
                html.script(
                  [
                    attribute.type_("module"),
                    attribute.src("/lustre-server-component.mjs"),
                  ],
                  "",
                ),
              ]),
              html.body([], [
                ui.box([], [
                  ui.sequence([], [
                    ui.stack([], [
                      html.h2([], [html.text("Server Component:")]),
                      server_component.component([
                        server_component.route("/counter"),
                      ]),
                    ]),
                  ]),
                ]),
              ]),
            ])
            |> element.to_document_string_builder
            |> bytes_tree.from_string_tree
            |> mist.Bytes,
          )
      }
    }
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}

//
pub type ComponentState {
  ComponentState(component: Counter, id: String)
}

type Counter =
  Subject(lustre.Action(counter.Msg, lustre.ServerComponent))

fn socket_init(
  _conn: WebsocketConnection,
  state: ComponentState,
) -> #(ComponentState, Option(Selector(lustre.Patch(counter.Msg)))) {
  let self = process.new_subject()
  let selector = process.selecting(process.new_selector(), self, fn(a) { a })
  let id = uuid.v4_string()
  process.send(
    state.component,
    server_component.subscribe(id, process.send(self, _)),
  )
  #(state, Some(selector))
}

fn socket_update(
  state: ComponentState,
  conn: WebsocketConnection,
  msg: WebsocketMessage(lustre.Patch(counter.Msg)),
) {
  case msg {
    mist.Text(json) -> {
      // we attempt to decode the incoming text as an action to send to our
      // server component runtime.
      let action = json.decode(json, server_component.decode_action)
      case action {
        Ok(action) -> process.send(state.component, action)
        Error(_) -> Nil
      }

      actor.continue(state)
    }

    mist.Binary(_) -> actor.continue(state)
    mist.Custom(patch) -> {
      let assert Ok(_) =
        patch
        |> server_component.encode_patch
        |> json.to_string
        |> mist.send_text_frame(conn, _)

      actor.continue(state)
    }
    mist.Closed | mist.Shutdown -> actor.Stop(process.Normal)
  }
}

fn socket_close(state: ComponentState) {
  process.send(state.component, lustre.shutdown())
}
