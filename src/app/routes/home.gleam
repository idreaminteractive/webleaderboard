import gleam/string
import lustre/attribute.{class, name}
import lustre/element.{type Element, text}

import lustre/element/html.{button, div, h1, input}

pub fn root(msg: List(String)) -> Element(t) {
  div([class("app")], [
    h1([class("app-title")], [text("Gleam Chat")]),
    div([], [html.textarea([attribute.rows(30)], string.join(msg, "\n"))]),
    div([], [
      html.form([attribute.method("POST"), attribute.action("/submit")], [
        input([
          name("message"),
          attribute.autofocus(True),
          attribute.placeholder("hey"),
          attribute.type_("text"),
        ]),
        button([], [text("Send")]),
      ]),
    ]),
  ])
}
