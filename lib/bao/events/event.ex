defmodule Bao.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bao.Events.EventPubkey
  alias Bao

  alias Bitcoinex.Script
  alias Bitcoinex.Utils, as: BtcUtils
  alias Bitcoinex.Secp256k1

  @bao_scalar Bao.get_scalar().d

  schema "events" do
    field :pubkey_ct, :integer
    field :point, :string
    field :scalar, :string
    has_many :event_pubkeys, EventPubkey

    timestamps()
  end

  @doc false
  def changeset(event, attrs = %{"pubkeys" => pubkeys}) do
    attrs =
      attrs
      |> Map.put("pubkey_ct", length(pubkeys))
      |> Map.put("point", calculate_event_point(pubkeys))

    event
    |> cast(attrs, [:pubkey_ct, :point])
    |> validate_required([:pubkey_ct, :point])
    |> validate_length(:point, is: 33)
    |> validate_number(:pubkey_ct, greater_than: 0)
  end

  def calculate_event_hash(pubkeys) do
    # sort pubkeys, concatenate them, hash them, convert to point
    {:ok, scalar} =
      pubkeys
      |> Enum.map(fn pk -> {:ok, point} = Secp256k1.Point.lift_x(pk); point end)
      |> Script.lexicographical_sort_pubkeys()
      |> Enum.reduce(<<>>, fn pk, acc -> acc <> Secp256k1.Point.x_bytes(pk) end)
      |> BtcUtils.double_sha256()
      |> :binary.decode_unsigned()
      |> Secp256k1.PrivateKey.new()
    scalar
  end

  def calculate_event_scalar(pubkeys) do
    # the event_scalar is just the event_hash tweaked with the Bao's scalar
    event_hash = calculate_event_hash(pubkeys)
    {:ok, scalar} = PrivateKey.new(event_hash + @bao_scalar)
    Secp256k1.force_even_y(scalar)
  end

  def calculate_event_point(pubkeys) do
    # TODO don't recalc this every time
    bao_point = Secp256k1.PrivateKey.to_point(@bao_scalar)
    event_hash = calculate_event_hash(pubkeys)
    point = Secp256k1.PrivateKey.to_point(event_hash)
    # tweak event_hash_point with bao pubkey
    Secp256k1.Math.add(point, bao_point)
    # force even
    |> Secp256k1.Point.x_bytes()
    |> Secp256k1.Point.lift_x()
  end
end
