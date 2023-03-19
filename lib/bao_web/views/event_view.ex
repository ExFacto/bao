defmodule BaoWeb.EventView do
  use BaoWeb, :view
  # alias BaoWeb.EventView
  alias BaoWeb.EventPubkeyView

  def render("500.json", _assigns) do
    %{error: "internal server error"}
  end

  def render("404.json", _assigns) do
    %{error: "event not found"}
  end

  def render("400.json", %{msg: msg}) do
    %{error: "bad request: #{msg}"}
  end

  def render("event.json", %{event: event, sig_ct: sig_ct}) do
    %{
      event_point: event.point,
      event_signature: event.signature,
      event_hash: event.hash,
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
