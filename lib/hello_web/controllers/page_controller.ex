defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  def index(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def redirect_test(conn, _params) do
    conn
    |> put_flash(:error, "EORRROR")
    |> redirect(to: ~p"/")
  end
end
