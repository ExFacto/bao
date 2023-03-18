defmodule Bao.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bao.Events.EventPubkey
  alias Bao

  alias Bitcoinex.Script
  alias Bitcoinex.Utils, as: BtcUtils
  alias Bitcoinex.Secp256k1

  @bao_scalar Bao.get_scalar()

  schema "events" do
    field :pubkey_ct, :integer
    field :point, :string
    field :scalar, :string
    has_many :event_pubkeys, EventPubkey

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:pubkey_ct, :point, :scalar])
    # |> cast_assoc(:event_pubkeys, with: &Bao.Events.EventPubkey.changeset/2)
    |> validate_required([:pubkey_ct, :point])
    |> validate_scalar()
    |> validate_length(:point, is: 66)
    |> unique_constraint(:point)
    |> validate_number(:pubkey_ct, greater_than: 0)
  end

  def validate_scalar(changeset) do
    validate_change(changeset, :scalar, fn :scalar, scalar ->
      case scalar do
        nil ->
          []

        scalar when is_binary(scalar) ->
          if String.length(scalar) == 64 do
            []
          else
            [scalar: "invalid scalar"]
          end
      end
    end)
  end

  def calculate_event_hash(pubkeys) do
    # sort pubkeys, concatenate them, hash them, convert to point
      pubkeys
      |> Enum.map(fn pk ->
        {:ok, point} = Secp256k1.Point.lift_x(pk)
        point
      end)
      |> Script.lexicographical_sort_pubkeys()
      |> Enum.reduce(<<>>, fn pk, acc -> acc <> Secp256k1.Point.x_bytes(pk) end)
      # TODO Maybe tagged_hash this instead with custom tag
      |> BtcUtils.double_sha256()
      |> :binary.decode_unsigned()
  end

  def calculate_event_hash_and_nonce(pubkeys) do
    event_hash = calculate_event_hash(pubkeys)
    event_nonce = Secp256k1.Ecdsa.deterministic_k(@bao_scalar, event_hash)
    {event_hash, event_nonce}
  end

  def calculate_event_scalar(pubkeys) do
    {event_hash, event_nonce} = calculate_event_hash_and_nonce(pubkeys)

    # use Schnorr not ECDSA, even though RFC6979 is only standard for ECDSA it is ok to use for Schnorr
    signature = Secp256k1.Schnorr.sign_with_nonce(@bao_scalar, event_nonce, event_hash)
    # users were given event_point (see below). s is the scalar corresponding to that point.
    signature.s
  end

  def calculate_event_point(pubkeys) do
    # TODO don't recalc this every time
    {event_hash, event_nonce} = calculate_event_hash_and_nonce(pubkeys)
    event_nonce_point = Secp256k1.PrivateKey.to_point(event_nonce)
    bao_point = Secp256k1.PrivateKey.to_point(@bao_scalar)

    {:ok,
     Secp256k1.Schnorr.calculate_signature_point(
       event_nonce_point,
       bao_point,
       :binary.encode_unsigned(event_hash)
     )}
  end
end
