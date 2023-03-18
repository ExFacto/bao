defmodule BaoWeb.EventView do
  use BaoWeb, :view
  # alias BaoWeb.EventView
  alias BaoWeb.EventPubkeyView

  # def render("index.json", %{events: events}) do
  #   %{data: render_many(events, EventView, "event.json")}
  # end

  # def render("show.json", %{event: event}) do
  #   %{data: render_one(event, EventView, "event.json")}
  # end

  def render("event.json", %{event: event, sig_ct: sig_ct}) do
    %{
      event_point: event.point,
      pubkeys: render_many(event.event_pubkeys, EventPubkeyView, "event_pubkey.json"),
      signature_count: sig_ct
    }
  end

  def render("revealed_event.json", %{event: event}) do
    %{
      event_point: event.point,
      pubkeys: render_many(event.event_pubkeys, EventPubkeyView, "event_pubkey.json"),
      event_scalar: event.scalar
    }
  end
end
