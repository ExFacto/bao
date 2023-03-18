defmodule BaoWeb.EventPubkeyController do
  use BaoWeb, :controller

  alias Bao.Events
  alias Bao.Events.EventPubkey

  action_fallback BaoWeb.FallbackController

  # def index(conn, _params) do
  #   event_pubkeys = Events.list_event_pubkeys()
  #   render(conn, "index.json", event_pubkeys: event_pubkeys)
  # end

  # def create(conn, %{"event_pubkey" => event_pubkey_params}) do
  #   with {:ok, %EventPubkey{} = event_pubkey} <- Events.create_event_pubkey(event_pubkey_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", Routes.event_pubkey_path(conn, :show, event_pubkey))
  #     |> render("show.json", event_pubkey: event_pubkey)
  #   end
  # end

  # def show(conn, %{"id" => id}) do
  #   event_pubkey = Events.get_event_pubkey!(id)
  #   render(conn, "event_pubkey.json", event_pubkey: event_pubkey)
  # end

  # def update(conn, %{"id" => id, "event_pubkey" => event_pubkey_params}) do
  #   event_pubkey = Events.get_event_pubkey!(id)

  #   with {:ok, %EventPubkey{} = event_pubkey} <- Events.update_event_pubkey(event_pubkey, event_pubkey_params) do
  #     render(conn, "show.json", event_pubkey: event_pubkey)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   event_pubkey = Events.get_event_pubkey!(id)

  #   with {:ok, %EventPubkey{}} <- Events.delete_event_pubkey(event_pubkey) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
