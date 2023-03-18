defmodule Bao do
  @moduledoc """
  Bao keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Bitcoinex.Secp256k1
  alias Bitcoinex.Secp256k1.PrivateKey

  # point = get_point()

  # scalar = get_scalar()

  # TODO get once from env and store in memory
  def get_scalar() do
    {:ok, scalar} =
      Application.fetch_env!(:bao, :private_key)
      |> Base.decode16!(case: :lower)
      |> :binary.decode_unsigned()
      |> PrivateKey.new()


    Secp256k1.force_even_y(scalar)
  end

  def get_point() do
    {:ok, point} = PrivateKey.to_point(get_scalar())
    point
  end
end
