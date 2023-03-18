defmodule Bao.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Bao.Repo

  alias Bao.Events.Event

  alias Bitcoinex.Secp256k1
  alias Bitcoinex.Utils, as: BtcUtils

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
    Repo.get_by(EventPubkey, point: point)
  end

  def get_event_by_point!(point) do
    Repo.get_by!(Event, point: point)
    |> Repo.preload(:event_pubkeys)
  end

  def get_event_by_point(point) do
    case Repo.get_by(Event, point: point) do
      nil -> nil
      event -> Repo.preload(event, :event_pubkeys)
    end
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(%{"pubkeys" => pubkeys}) do
    # create all pubkey entries
    # put len(pubkeys) in attrs
    # generate new event
    {:ok, point} = Event.calculate_event_point(pubkeys)
    point_hex = Secp256k1.Point.serialize_public_key(point)
    # pubkeys = Enum.reduce(pubkeys, [], fn pk, pks -> [%{"pubkey" => pk} | pks] end)
    event =
      Event.changeset(%Event{}, %{
        "point" => point_hex,
        "pubkey_ct" => length(pubkeys)
      })

    insert_event_and_pubkeys(event, pubkeys)

    # TODO FIXME success or fail, we query again for the same event. FIXME
    get_event_by_point!(point_hex)

    # case insert_event_and_pubkeys(event, pubkeys, point_hex) do
    #   :exists ->
    #     get_event_by_point!(point_hex)
    #   event ->
    #     event
    #     |> Repo.preload(:event_pubkey)
    # end
  end

  # TODO this is not optimal
  defp insert_event_and_pubkeys(event, pubkeys) do
    Repo.transaction(fn ->
      event = Repo.insert!(event, on_conflict: :nothing, returning: true)

      try do
        Enum.each(pubkeys, fn pubkey ->
          Ecto.build_assoc(event, :event_pubkeys, pubkey: pubkey)
          |> Repo.insert!()
        end)
      catch
        _kind, %Postgrex.Error{postgres: %{code: :not_null_violation, column: "event_id"}} ->
          :exists
      end
    end)
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs = %{"scalar" => _scalar}) do
    event
    |> Event.changeset(attrs)
    |> Repo.update!()
  end

  def maybe_reveal_event(event) do
    if get_signature_count(event) == event.pubkey_ct do
      pubkeys = Enum.map(event.event_pubkeys, & &1.pubkey)

      scalar =
        Event.calculate_event_scalar(pubkeys)
        # TODO simplify to int_to_hex
        |> :binary.encode_unsigned()
        |> BtcUtils.pad(32, :leading)
        |> Base.encode16(case: :lower)
        update_event(event, %{"scalar" => scalar})
      end
    end

  # @doc """
  # Deletes a event.

  # ## Examples

  #     iex> delete_event(event)
  #     {:ok, %Event{}}

  #     iex> delete_event(event)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_event(%Event{} = event) do
  #   Repo.delete(event)
  # end

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

  # can only be called with event_pubkeys loaded
  def get_signature_count(event), do: Enum.count(event.event_pubkeys, & &1.signed)

  @doc """
  Creates a event_pubkey.

  ## Examples

      iex> create_event_pubkey(%{field: value})
      {:ok, %EventPubkey{}}

      iex> create_event_pubkey(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event_pubkey(_attrs) do
    # Handled by create_event
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

  def verify_event_signature(event_hash, user_point, signature) do
    {:ok, user_pk} = Secp256k1.Point.lift_x(user_point)
    {:ok, sig} = Secp256k1.Signature.parse_signature(signature)
    Secp256k1.Schnorr.verify_signature(user_pk, event_hash, sig)
  end
end
