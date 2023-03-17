defmodule Bao.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset


  alias Bitcoinex.Script
  alias Bitcoinex.Utils, as: BtcUtils
  alias Bitcoinex.Secp256k1

  schema "events" do
    field :point, :string
    field :pubkey_ct, :integer
    field :scalar, :string
    field :state, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs = %{"pubkeys" => pubkeys}) do
    attrs = Map.put(attrs, "pubkey_ct", length(pubkeys))

    event
    |> cast(attrs, [:pubkey_ct, :state, :point, :scalar])
    |> validate_required([:pubkey_ct, :state, :point, :scalar])
    |> validate_length(:point, is: 33)
    |> validate_length(:scalar, is: 32)
    |> validate_number(:pubkey_ct, greater_than: 0)
  end

  defp calculate_event_hash(pubkeys) do
    # sort pubkeys, concatenate them, hash them, convert to point
    {:ok, scalar} =
      pubkeys
      |> Script.lexicographical_sort_pubkeys()
      |> Enum.reduce(<<>>, fn pk, acc -> acc <> Secp256k1.Point.x_bytes(pk) end)
      |> BtcUtils.double_sha256()
      |> :binary.decode_unsigned()
      |> Secp256k1.PrivateKey.new()
  end

  defp calculate_event_scalar(%Secp256k1.PrivateKey{d: bao_scalar}, pubkeys) do
    # the event_scalar is just the event_hash tweaked with the Bao's scalar
    event_hash = calculate_event_hash(pubkeys)
    PrivateKey.new(event_hash + bao_scalar)
  end

  defp calculate_event_point(bao_point, pubkeys) do
    event_hash = calculate_event_hash(pubkeys)
    {:ok, point} = Secp256k1.PrivateKey.to_point(event_hash)
    Secp256k1.Math.add(point, bao_point)
  end
end
