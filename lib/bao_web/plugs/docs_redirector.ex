defmodule BaoWeb.Plugs.DocsRedirector do
  alias BaoWeb.Router.Helpers, as: Routes

  def init(default), do: default

  def call(conn, _opts) do
    docs_path = Routes.docs_path(conn, :index)

    conn
    |> Phoenix.Controller.redirect(to: docs_path)
    |> Plug.Conn.halt()
  end
end
