defmodule BaoWeb.EventView do
  use BaoWeb, :view
  alias BaoWeb.EventView

  # def render("index.json", %{events: events}) do
  #   %{data: render_many(events, EventView, "event.json")}
  # end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, EventView, "event.json")}
  end

  def render("event.json", %{event: event, sig_ct: sig_ct}) do
    %{
      id: event.id,
      pubkeys: event.pubkeys,
      sig_ct: sig_ct
    }
  end
end
