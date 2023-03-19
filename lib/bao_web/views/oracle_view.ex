defmodule BaoWeb.OracleView do
  use BaoWeb, :view

  def render("oracle.json", %{pubkey: pubkey}) do
    %{pubkey: pubkey}
  end
end
