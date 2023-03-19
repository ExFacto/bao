defmodule BaoWeb.EventController do
  use BaoWeb, :controller

  alias Bao.Events
  alias Bao.Events.Event
  # alias BaoWeb.ErrorView
  alias Bao.Utils

  action_fallback BaoWeb.FallbackController

  @event_point_len 66
  @pubkey_len 64
  @signature_len 128
  @pubkey_byte_size 32

  def create(conn, attrs = %{"pubkeys" => pubkeys})
      when is_list(pubkeys) and length(pubkeys) > 0 do
    # we must first check each pubkey is 32 bytes of hex to control error handling
    if Enum.any?(pubkeys, fn pk ->
         try do
           {res, pk} = Utils.decode16(pk)
           res != :ok || byte_size(pk) != @pubkey_byte_size
         rescue
           _ ->
             true
         end
       end) do
      bad_request(conn, "pubkeys must be x-only, 32-bytes of lowercase hex")
    else
      # TODO: Just return pubkeys & event_point
      case Events.create_event(attrs) do
        %Event{} = event ->
          conn
          |> put_status(:created)
          # TODO FIXME
          # |> put_resp_header("location", Routes.event_path(conn, :show, event))
          |> display_event(event)

        {:error, msg} ->
          bad_request(conn, msg)
      end
    end
  end

  def create(conn, _) do
    bad_request(conn, "missing or invalid pubkeys field")
  end

  def show(conn = %Plug.Conn{query_params: %{"point" => point}}, _)
      when byte_size(point) == @event_point_len do
    case Events.get_event_by_point(point) do
      nil ->
        event_not_found(conn)

      event ->
        display_event(conn, event)
    end
  end

  def show(conn, _) do
    bad_request(conn, "missing or invalid point param")
  end

  defguard is_valid_update_call(event_point, user_pubkey, signature)
           when is_binary(event_point) and byte_size(event_point) == @event_point_len and
                  is_binary(user_pubkey) and byte_size(user_pubkey) == @pubkey_len and
                  is_binary(signature) and byte_size(signature) == @signature_len

  def update(conn, %{
        "event_point" => event_point,
        "pubkey" => user_pubkey,
        "signature" => signature
      })
      when is_valid_update_call(event_point, user_pubkey, signature) do
    case Events.handle_event_signature(event_point, user_pubkey, signature) do
      nil ->
        event_not_found(conn)

      {:error, msg} ->
        bad_request(conn, msg)

      event ->
        display_event(conn, event)
    end
  end

  def update(conn, _) do
    bad_request(conn, "missing or invalid required fields [event_point, pubkey, signature]")
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

  def bad_request(conn, msg) do
    conn
    |> put_status(:bad_request)
    |> render("400.json", %{msg: msg})
  end

  def event_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> render("404.json")
  end
end
