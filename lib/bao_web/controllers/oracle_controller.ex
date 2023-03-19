defmodule BaoWeb.OracleController do
  use BaoWeb, :controller

  alias Bitcoinex.Secp256k1

  def index(conn, _assigns) do
    render(conn, "oracle.json", pubkey: Bao.get_point() |> Secp256k1.Point.x_hex())
  end
end
