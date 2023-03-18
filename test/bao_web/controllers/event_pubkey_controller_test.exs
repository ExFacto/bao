defmodule BaoWeb.EventPubkeyControllerTest do
  use BaoWeb.ConnCase

  import Bao.EventsFixtures

  alias Bao.Events.EventPubkey

  @create_attrs %{
    pubkey: "some pubkey"
  }
  @update_attrs %{
    pubkey: "some updated pubkey"
  }
  @invalid_attrs %{pubkey: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all event_pubkeys", %{conn: conn} do
      conn = get(conn, Routes.event_pubkey_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create event_pubkey" do
    test "renders event_pubkey when data is valid", %{conn: conn} do
      conn = post(conn, Routes.event_pubkey_path(conn, :create), event_pubkey: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.event_pubkey_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "pubkey" => "some pubkey"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.event_pubkey_path(conn, :create), event_pubkey: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update event_pubkey" do
    setup [:create_event_pubkey]

    test "renders event_pubkey when data is valid", %{
      conn: conn,
      event_pubkey: %EventPubkey{id: id} = event_pubkey
    } do
      conn =
        put(conn, Routes.event_pubkey_path(conn, :update, event_pubkey),
          event_pubkey: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.event_pubkey_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "pubkey" => "some updated pubkey"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, event_pubkey: event_pubkey} do
      conn =
        put(conn, Routes.event_pubkey_path(conn, :update, event_pubkey),
          event_pubkey: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete event_pubkey" do
    setup [:create_event_pubkey]

    test "deletes chosen event_pubkey", %{conn: conn, event_pubkey: event_pubkey} do
      conn = delete(conn, Routes.event_pubkey_path(conn, :delete, event_pubkey))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.event_pubkey_path(conn, :show, event_pubkey))
      end
    end
  end

  defp create_event_pubkey(_) do
    event_pubkey = event_pubkey_fixture()
    %{event_pubkey: event_pubkey}
  end
end
