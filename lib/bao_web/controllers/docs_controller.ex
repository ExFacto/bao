defmodule BaoWeb.DocsController do
  use BaoWeb, :controller

  action_fallback BaoWeb.FallbackController

  def index(conn, _assigns) do
    render(conn, "docs.html")
  end
end
