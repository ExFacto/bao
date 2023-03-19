defmodule BaoWeb.ErrorView do
  use BaoWeb, :view

  def render("500.json", _assigns) do
    %{error: "internal server error"}
  end

  def render("404.json", _assigns) do
    %{error: "event not found"}
  end

  def render("400.json", %{msg: msg}) do
    %{error: "bad request: #{msg}"}
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def template_not_found(_template, _assigns) do
    # %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
    render("500.json", %{})
  end
end
