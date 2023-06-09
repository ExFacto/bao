defmodule Bao.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bao.Events.Event
  alias Bao.Events.EventPubkey
  alias Bao.Utils
  alias Bao

  alias Bitcoinex.Script
  alias Bitcoinex.Secp256k1

  @signature_len 128
  @hash_len 64
  @scalar_len 64
  @sec_pubkey_len 66

  schema "events" do
    field :pubkey_ct, :integer
    field :hash, :string
    field :signature, :string
    field :point, :string
    field :scalar, :string
    has_many :event_pubkeys, EventPubkey

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:pubkey_ct, :point, :hash, :scalar, :signature])
    # |> cast_assoc(:event_pubkeys, with: &Bao.Events.EventPubkey.changeset/2)
    |> validate_required([:pubkey_ct, :point, :hash, :signature])
    |> validate_scalar()
    |> validate_length(:signature, is: @signature_len)
    |> validate_length(:hash, is: @hash_len)
    |> validate_length(:point, is: @sec_pubkey_len)
    |> unique_constraint(:point)
    |> validate_number(:pubkey_ct, greater_than: 0)
  end

  def validate_scalar(changeset) do
    validate_change(changeset, :scalar, fn :scalar, scalar ->
      case scalar do
        nil ->
          []

        scalar when is_binary(scalar) ->
          if String.length(scalar) == @scalar_len do
            []
          else
            [scalar: "invalid scalar"]
          end
      end
    end)
  end

  # @spec calculate_event_hash(list(String.t()) | Event.t()) :: integer
  def calculate_event_hash(event = %Event{}) do
    event.event_pubkeys
    |> Enum.map(fn epk -> epk.pubkey end)
    |> calculate_event_hash()
  end

  def calculate_event_hash(pubkeys) when is_list(pubkeys) and length(pubkeys) > 0 do
    # sort pubkeys, concatenate them, hash them, convert to point
    pubkeys
    |> Enum.map(fn pk ->
      {:ok, point} = Secp256k1.Point.lift_x(pk)
      point
    end)
    |> Script.lexicographical_sort_pubkeys()
    |> Enum.reduce(<<>>, fn pk, acc -> acc <> Secp256k1.Point.x_bytes(pk) end)
    # TODO Maybe tagged_hash this instead with custom tag
    |> Utils.hash()
  end

  def calculate_event_hash_and_nonce(pubkeys) do
    event_hash = calculate_event_hash(pubkeys)

    event_nonce =
      Secp256k1.Ecdsa.deterministic_k(Bao.get_scalar(), :binary.decode_unsigned(event_hash))

    {event_hash, event_nonce}
  end

  def calculate_event_scalar(pubkeys) do
    {event_hash, event_nonce} = calculate_event_hash_and_nonce(pubkeys)

    # use Schnorr not ECDSA, even though RFC6979 is only standard for ECDSA it is ok to use for Schnorr
    signature =
      Secp256k1.Schnorr.sign_with_nonce(
        Bao.get_scalar(),
        event_nonce,
        :binary.decode_unsigned(event_hash)
      )

    # users were given event_point (see below). s is the scalar corresponding to that point.
    signature.s
  end

  def calculate_event_point(pubkeys) do
    # TODO don't recalc this every time
    {event_hash, event_nonce} = calculate_event_hash_and_nonce(pubkeys)
    event_nonce_point = Secp256k1.PrivateKey.to_point(event_nonce)
    bao_point = Secp256k1.PrivateKey.to_point(Bao.get_scalar())

    {:ok, event_hash,
     Secp256k1.Schnorr.calculate_signature_point(
       event_nonce_point,
       bao_point,
       event_hash
     )}
  end
end
