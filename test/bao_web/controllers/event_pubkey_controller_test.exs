defmodule BaoWeb.EventPubkeyControllerTest do
  use BaoWeb.ConnCase

  import Bao.EventsFixtures

  alias Bao.Events.EventPubkey

  @create_attrs %{
    event_id: 1,
    pubkey: "645b4c27b03cf5c019f9a310ca914b4632cb2f3fd9f56f6807b30227ddf6f726"
  }
  @update_attrs %{
    event_point: "02b4606d8fa38cf0e076fe9edc502e8627c9a63cd3221fecd3298b19d969653261",
    pubkey: "645b4c27b03cf5c019f9a310ca914b4632cb2f3fd9f56f6807b30227ddf6f726",
    signature:
      "b999e7e39dc41a8c4f041618fe642ac73bdaaf3ffd4e413c0e87210eb9397f33b735a52359b5dd6a89583b8521c5d6f736f7c8d5d1b47ee7d8c994dcf5c4bc5e"
  }
  @invalid_attrs %{pubkey: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
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

      # assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.event_pubkey_path(conn, :show, id))

      assert %{
               #  "id" => ^id,
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

  defp create_event_pubkey(_) do
    event_pubkey = event_pubkey_fixture()
    %{event_pubkey: event_pubkey}
  end
end
