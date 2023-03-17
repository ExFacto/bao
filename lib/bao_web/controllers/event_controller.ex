defmodule BaoWeb.EventController do
  use BaoWeb, :controller

  alias Bao.Events
  alias Bao.Events.Event

  action_fallback BaoWeb.FallbackController

  # def index(conn, _params) do
  #   events = Events.list_events()
  #   render(conn, "index.json", events: events)
  # end

  def create(conn, attrs = %{"pubkeys" => pubkeys}) do
    # TODO: Just return pubkeys & event_point
    with {:ok, %Event{} = event} <- Events.create_event(attrs) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.event_path(conn, :show, event))
      |> render("show.json", event: event)
    end
  end

  def show(conn, %{"point" => point}) do
    # TODO:
    event = Events.get_event_by_point!(point)
    render(conn, "show.json", event: event)
  end

  def update(conn, %{"point" => user_point, "signature" => signature}) do
    event = Events.get_event_by_point!(user_point)

    # TODO error if this fails
    true = Events.verify_event_signature(event.point, user_point, signature)

    event_pk = Events.get_event_pubkey!(user_point)

    with {:ok, _} <- EventPubkeys.update_event_pubkey(event_pk, %{"signature" => signature}) do
      # If successfully verified sig
      render(conn, "show.json", event: event)
    end
  end

  # def delete(conn, %{"id" => id}) do
  #   event = Events.get_event!(id)

  #   with {:ok, %Event{}} <- Events.delete_event(event) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
