defmodule Bao do
  @moduledoc """
  Bao keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Bao.Utils

  alias Bitcoinex.Secp256k1
  alias Bitcoinex.Secp256k1.PrivateKey

  # point = get_point()

  # scalar = get_scalar()

  # TODO get once from env and store in memory
  def get_scalar() do
    {:ok, scalar} =
      Application.get_env(:bao, :private_key)
      |> Utils.hex_to_int()
      |> PrivateKey.new()

    Secp256k1.force_even_y(scalar)
  end

  def get_point() do
    PrivateKey.to_point(get_scalar())
  end

  def sign_event_point(event_point) do
    sighash =
      Secp256k1.Point.sec(event_point)
      |> Utils.hash()
      |> :binary.decode_unsigned()

    {:ok, sig} = Secp256k1.Schnorr.sign(Bao.get_scalar(), sighash, Utils.new_rand_int())
    Secp256k1.Signature.to_hex(sig)
  end
end
