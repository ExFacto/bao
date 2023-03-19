defmodule Bao.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bao.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        point: "some point",
        pubkey_ct: 42,
        scalar: "some scalar",
        state: "some state"
      })
      |> Bao.Events.create_event()

    event
  end

  @doc """
  Generate a event_pubkey.
  """
  def event_pubkey_fixture(attrs \\ %{}) do
    {:ok, event_pubkey} =
      attrs
      |> Enum.into(%{
        pubkey: "some pubkey",
        signature: "some signature",
        signed: true
      })
      |> Bao.Events.create_event_pubkey()

    event_pubkey
  end
end
