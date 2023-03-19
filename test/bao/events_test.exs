defmodule Bao.EventsTest do
  use Bao.DataCase

  alias Bao.Events

  describe "events" do
    alias Bao.Events.Event

    import Bao.EventsFixtures

    @invalid_attrs %{point: nil, pubkey_ct: nil, scalar: nil, state: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{
        point: "some point",
        pubkey_ct: 42,
        scalar: "some scalar",
        state: "some state"
      }

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.point == "some point"
      assert event.pubkey_ct == 42
      assert event.scalar == "some scalar"
      assert event.state == "some state"
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()

      update_attrs = %{
        point: "some updated point",
        pubkey_ct: 43,
        scalar: "some updated scalar",
        state: "some updated state"
      }

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.point == "some updated point"
      assert event.pubkey_ct == 43
      assert event.scalar == "some updated scalar"
      assert event.state == "some updated state"
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end

  describe "event_pubkeys" do
    alias Bao.Events.EventPubkey

    import Bao.EventsFixtures

    @invalid_attrs %{pubkey: nil, signature: nil, signed: nil}

    test "list_event_pubkeys/0 returns all event_pubkeys" do
      event_pubkey = event_pubkey_fixture()
      assert Events.list_event_pubkeys() == [event_pubkey]
    end

    test "get_event_pubkey!/1 returns the event_pubkey with given id" do
      event_pubkey = event_pubkey_fixture()
      assert Events.get_event_pubkey!(event_pubkey.id) == event_pubkey
    end

    test "create_event_pubkey/1 with valid data creates a event_pubkey" do
      valid_attrs = %{
        pubkey: "645b4c27b03cf5c019f9a310ca914b4632cb2f3fd9f56f6807b30227ddf6f726",
        signature:
          "b999e7e39dc41a8c4f041618fe642ac73bdaaf3ffd4e413c0e87210eb9397f33b735a52359b5dd6a89583b8521c5d6f736f7c8d5d1b47ee7d8c994dcf5c4bc5e",
        signed: true
      }

      assert {:ok, %EventPubkey{} = event_pubkey} = Events.create_event_pubkey(valid_attrs)
      assert event_pubkey.pubkey == "some pubkey"
      assert event_pubkey.signature == "some signature"
      assert event_pubkey.signed == true
    end

    test "create_event_pubkey/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event_pubkey(@invalid_attrs)
    end

    test "update_event_pubkey/2 with valid data updates the event_pubkey" do
      event_pubkey = event_pubkey_fixture()

      update_attrs = %{
        pubkey: "some updated pubkey",
        signature: "some updated signature",
        signed: false
      }

      assert {:ok, %EventPubkey{} = event_pubkey} =
               Events.update_event_pubkey(event_pubkey, update_attrs)

      assert event_pubkey.pubkey == "some updated pubkey"
      assert event_pubkey.signature == "some updated signature"
      assert event_pubkey.signed == false
    end

    test "update_event_pubkey/2 with invalid data returns error changeset" do
      event_pubkey = event_pubkey_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Events.update_event_pubkey(event_pubkey, @invalid_attrs)

      assert event_pubkey == Events.get_event_pubkey!(event_pubkey.id)
    end

    test "delete_event_pubkey/1 deletes the event_pubkey" do
      event_pubkey = event_pubkey_fixture()
      assert {:ok, %EventPubkey{}} = Events.delete_event_pubkey(event_pubkey)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event_pubkey!(event_pubkey.id) end
    end

    test "change_event_pubkey/1 returns a event_pubkey changeset" do
      event_pubkey = event_pubkey_fixture()
      assert %Ecto.Changeset{} = Events.change_event_pubkey(event_pubkey)
    end
  end
end
