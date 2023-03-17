defmodule Bao.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Bao.Repo

  alias Bao.Events.Event

  alias Bitcoinex.Secp256k1

  # @doc """
  # Returns the list of events.

  # ## Examples

  #     iex> list_events()
  #     [%Event{}, ...]

  # """
  # def list_events do
  #   Repo.all(Event)
  # end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  # def get_event!(id), do: Repo.get!(Event, id)

  def get_event_pubkey_by_point!(point) do
    Repo.get_by(EventPubkey, [point: point])
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs) do
    # create all pubkey entries
    # put len(pubkeys) in attrs
    # generate new event
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  alias Bao.Events.EventPubkey

  @doc """
  Returns the list of event_pubkeys.

  ## Examples

      iex> list_event_pubkeys()
      [%EventPubkey{}, ...]

  """
  def list_event_pubkeys do
    Repo.all(EventPubkey)
  end

  @doc """
  Gets a single event_pubkey.

  Raises `Ecto.NoResultsError` if the Event pubkey does not exist.

  ## Examples

      iex> get_event_pubkey!(123)
      %EventPubkey{}

      iex> get_event_pubkey!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event_pubkey!(id), do: Repo.get!(EventPubkey, id)

  @doc """
  Creates a event_pubkey.

  ## Examples

      iex> create_event_pubkey(%{field: value})
      {:ok, %EventPubkey{}}

      iex> create_event_pubkey(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event_pubkey(attrs \\ %{}) do
    %EventPubkey{}
    |> EventPubkey.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event_pubkey.

  ## Examples

      iex> update_event_pubkey(event_pubkey, %{field: new_value})
      {:ok, %EventPubkey{}}

      iex> update_event_pubkey(event_pubkey, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event_pubkey(%EventPubkey{} = event_pubkey, attrs) do
    event_pubkey
    |> EventPubkey.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event_pubkey.

  ## Examples

      iex> delete_event_pubkey(event_pubkey)
      {:ok, %EventPubkey{}}

      iex> delete_event_pubkey(event_pubkey)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event_pubkey(%EventPubkey{} = event_pubkey) do
    Repo.delete(event_pubkey)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event_pubkey changes.

  ## Examples

      iex> change_event_pubkey(event_pubkey)
      %Ecto.Changeset{data: %EventPubkey{}}

  """
  def change_event_pubkey(%EventPubkey{} = event_pubkey, attrs \\ %{}) do
    EventPubkey.changeset(event_pubkey, attrs)
  end

  def verify_event_signature(event_point, user_point, signature) do
    sighash =
      event_point
      |> Base.decode16!( case: :lower)
      |> :binary.decode_unsigned()
    {:ok, user_pk} = Secp256k1.Point.lift_x(user_point)
    {:ok, sig} = Secp256k1.Signature.parse_signature(signature)
    Secp256k1.Schnorr.verify_signature(user_pk, sighash, sig)
  end
end
