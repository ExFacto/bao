defmodule Bao.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Bao.Repo

  alias Bao.Events.Event
  alias Bao.Events.EventPubkey
  alias Bao.Utils

  alias Bitcoinex.Secp256k1

  # @spec get_event_pubkey_by_point!(String.t()) :: EventPubkey.t()
  def get_event_pubkey_by_point!(point) do
    Repo.get_by(EventPubkey, point: point)
  end

  # @spec get_event_by_point!(String.t()) :: Event.t()
  def get_event_by_point!(point) do
    Repo.get_by!(Event, point: point)
    |> Repo.preload(:event_pubkeys)
  end

  # @spec get_event_by_point(String.t()) :: Event.t()
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
    uniq_pubkeys = Enum.uniq(pubkeys)
    pubkey_ct = length(pubkeys)

    if length(uniq_pubkeys) != pubkey_ct do
      {:error, "event cannot contain duplicate pubkeys"}
    else
      # create all pubkey entries
      # put len(pubkeys) in attrs
      # generate new event
      {:ok, event_hash, point} = Event.calculate_event_point(pubkeys)
      event_hash_hex = Utils.encode16(event_hash)
      point_hex = Secp256k1.Point.serialize_public_key(point)

      event_sig_hex = Bao.sign_event_point(point)
      # pubkeys = Enum.reduce(pubkeys, [], fn pk, pks -> [%{"pubkey" => pk} | pks] end)
      event =
        Event.changeset(%Event{}, %{
          "point" => point_hex,
          "hash" => event_hash_hex,
          "pubkey_ct" => pubkey_ct,
          "signature" => event_sig_hex
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
        pubkeys
        |> Event.calculate_event_scalar()
        |> Utils.int_to_hex()

      update_event(event, %{"scalar" => scalar})
    else
      event
    end
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

  # can only be called with event_pubkeys preloaded
  def get_signature_count(event), do: Enum.count(event.event_pubkeys, & &1.signed)

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

  def handle_event_signature(event_point, user_pubkey, signature) do
    # lookup event
    case get_event_by_point(event_point) do
      # event not found
      nil ->
        nil

      event ->
        # check that the provided user_pubkey is party to this event
        case Enum.find_index(event.event_pubkeys, &(&1.pubkey == user_pubkey)) do
          # user pubkey not in event. return not found
          nil ->
            nil

          user_idx ->
            verify_user_signature(event, user_pubkey, signature, user_idx)
        end
    end
  end

  defp verify_user_signature(event, user_pubkey, signature, user_idx) do
    if verify_user_event_signature(event.hash, user_pubkey, signature) do
      do_update_event(event, signature, user_idx)
    else
      {:error, "invalid signature"}
    end
  end

  defp do_update_event(event, signature, user_idx) do
    with {:ok, user_pubkey} <-
           update_event_pubkey(Enum.at(event.event_pubkeys, user_idx), %{
             "signature" => signature,
             "signed" => true
           }) do
      # instead, just replace the updated event_pubkey in this list
      event_pubkeys = List.replace_at(event.event_pubkeys, user_idx, user_pubkey)

      %{event | event_pubkeys: event_pubkeys}
      |> maybe_reveal_event()
    end
  end

  def verify_user_event_signature(event_hash, user_point, signature) do
    event_hash = Utils.hex_to_int(event_hash)
    {:ok, user_pk} = Secp256k1.Point.lift_x(user_point)
    {:ok, sig} = Secp256k1.Signature.parse_signature(signature)
    Secp256k1.Schnorr.verify_signature(user_pk, event_hash, sig)
  end
end
