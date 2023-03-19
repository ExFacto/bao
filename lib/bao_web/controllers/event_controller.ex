defmodule BaoWeb.EventController do
  use BaoWeb, :controller

  alias Bao.Events
  alias Bao.Events.Event
  alias BaoWeb.ErrorView

  action_fallback BaoWeb.FallbackController

  # def index(conn, _params) do
  #   events = Events.list_events()
  #   render(conn, "index.json", events: events)
  # end

  def create(conn, attrs = %{"pubkeys" => _}) do
    # TODO: Just return pubkeys & event_point
    case Events.create_event(attrs) do
      %Event{} = event ->
        conn
        |> put_status(:created)
        # TODO FIXME
        # |> put_resp_header("location", Routes.event_path(conn, :show, event))
        |> display_event(event)

      {:error, msg} ->
        msg
    end
  end

  def show(conn, _) do
    point = Map.fetch!(conn.query_params, "point")

      case Events.get_event_by_point(point) do
        nil ->
          render(conn, "404.json")

        event ->
          display_event(conn, event)
      end
  end

  def update(conn, %{
        "event_point" => event_point,
        "pubkey" => user_pubkey,
        "signature" => signature
      }) do
    case Events.handle_event_signature( event_point, user_pubkey, signature) do
      nil ->
        IO.puts("HERE1")
        ErrorView.render(conn, "404.json")

      {:error, msg} ->
        IO.puts("HERE2")
        ErrorView.render(conn, "400.json", msg: msg)

      event ->
        display_event(conn, event)
    end
  end

  def display_event(conn, event) do
    pk_ct = length(event.event_pubkeys)

    case Events.get_signature_count(event) do
      ^pk_ct ->
        IO.puts("HERE3")

        render(conn, "revealed_event.json", event: event)

      sig_ct ->
        IO.puts("HERE4")

        render(conn, "event.json", %{event: event, sig_ct: sig_ct})
    end
  end
end
