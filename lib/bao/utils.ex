defmodule Bao.Utils do
  alias Bitcoinex.Utils, as: BtcUtils

  def hash(data) do
    BtcUtils.double_sha256(data)
  end

  def new_rand_int() do
    32
    |> :crypto.strong_rand_bytes()
    |> :binary.decode_unsigned()
  end

  # Bao uses all lowercase hex
  def encode16(data), do: Base.encode16(data, case: :lower)
  def decode16(data), do: Base.decode16(data, case: :lower)
  def decode16!(data), do: Base.decode16!(data, case: :lower)

  def hex_to_int(data), do: decode16!(data) |> :binary.decode_unsigned()

  def int_to_hex(data, sz \\ 32) do
    data
    |> :binary.encode_unsigned()
    |> BtcUtils.pad(sz, :leading)
    |> encode16()
  end
end
