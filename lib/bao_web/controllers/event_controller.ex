defmodule BaoWeb.EventController do
  use BaoWeb, :controller

  alias Bao.Events
  alias Bao.Events.Event

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
        # |> put_resp_header("location", Routes.event_path(conn, :show, event))
        |> display_event(event)

      {:error, msg} ->
        msg
    end
  end

  def show(conn, _) do
    point = Map.fetch!(conn.query_params, "point")
    event = Events.get_event_by_point!(point)
    display_event(conn, event)
  end

  def update(conn, %{
        "event_point" => event_point,
        "point" => user_point,
        "signature" => signature
      }) do
    event =
      case Events.get_event_by_point(event_point) do
        nil ->
          # TODO return 404
          nil

        event ->
          event
      end

    # check that the provided user_point is party to this event
    user_pk_idx =
      case Enum.find_index(event.event_pubkeys, &(&1.pubkey == user_point)) do
        nil ->
          # TODO return 404
          nil

        idx ->
          idx
      end

    event_hash =
      event.event_pubkeys
      |> Enum.map(fn epk -> epk.pubkey end)
      |> Event.calculate_event_hash()

    # TODO error if this fails
    true = Events.verify_event_signature(event_hash, user_point, signature)

    with {:ok, user_pubkey} <-
           Events.update_event_pubkey(Enum.at(event.event_pubkeys, user_pk_idx), %{
             "signature" => signature,
             "signed" => true
           }) do
      # instead, just replace the updated event_pubkey in this list
      event_pubkeys = List.replace_at(event.event_pubkeys, user_pk_idx, user_pubkey)
      event = %{event | event_pubkeys: event_pubkeys}
      event = Events.maybe_reveal_event(event)
      display_event(conn, event)
    end
  end

  def display_event(conn, event) do
    pk_ct = length(event.event_pubkeys)

    case Events.get_signature_count(event) do
      ^pk_ct ->
        render(conn, "revealed_event.json", event: event)

      sig_ct ->
        render(conn, "event.json", %{event: event, sig_ct: sig_ct})
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   event = Events.get_event!(id)

  #   with {:ok, %Event{}} <- Events.delete_event(event) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
