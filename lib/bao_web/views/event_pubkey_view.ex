defmodule BaoWeb.EventPubkeyView do
  use BaoWeb, :view

  # def render("index.json", %{event_pubkeys: event_pubkeys}) do
  #   %{data: render_many(event_pubkeys, EventPubkeyView, "event_pubkey.json")}
  # end

  # def render("show.json", %{event_pubkey: event_pubkey}) do
  #   %{data: render_one(event_pubkey, EventPubkeyView, "event_pubkey.json")}
  # end

  def render("event_pubkey.json", %{event_pubkey: event_pubkey}) do
    event_pubkey.pubkey
  end
end
