defmodule HelloWeb.HelloHTML do
  use HelloWeb, :html

  embed_templates("hello_html/*")

  attr(:messenger, :string, required: true)
  attr(:potato, :string, required: true)

  def greet(assigns) do
    ~H"""
    <section>
      <h2>Hello World, from {@messenger} and {@potato}!</h2>
    </section>
    """
  end
end
